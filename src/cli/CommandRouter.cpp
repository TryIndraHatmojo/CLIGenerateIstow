#include "CommandRouter.h"
#include "JsonResponse.h"
#include "application/ExportService.h"
#include "archive/LegacyArchiveReader.h"
#include "domain/Error.h"
#include <QCoreApplication>
#include <QDir>
#include <QJsonArray>
#include <QMap>
#include <QSet>
#include <cstdio>
namespace istow {
int CommandRouter::run(const QStringList &arguments) {
    const auto args = arguments.mid(1);
    if (args == QStringList{"--help"} || args == QStringList{"-h"}) {
        std::puts("istow-cli export --manifest <absolute.json> --input-dir <absolute-dir> --output <absolute.istow> --format legacy-v1 --json\nistow-cli verify --archive <absolute.istow> --format legacy-v1 --json\nResource options: --max-file-bytes N --max-total-bytes N --max-entries N\nistow-cli --version | --help"); return 0;
    }
    if (args == QStringList{"--version"}) {
        writeJson({{"cli_version", ISTOW_VERSION}, {"qt_runtime", qVersion()}, {"qt_build", QT_VERSION_STR}, {"archive_profiles", QJsonArray{ArchiveProfile::name}}, {"stream_version", "Qt_5_15"}}); return 0;
    }
    QString command = args.isEmpty() ? QString() : args.first();
    QJsonValue requestId = QJsonValue::Null;
    QJsonObject response{{"ok", false}, {"schema_version", 1}, {"request_id", requestId}, {"command", command}};
    try {
        require(command == "export" || command == "verify", 2, "COMMAND_INVALID", "Expected export or verify; use --help.");
        const QSet<QString> common{"--format", "--max-file-bytes", "--max-total-bytes", "--max-entries"};
        QSet<QString> allowed = common;
        allowed.unite(command == "export" ? QSet<QString>{"--manifest", "--input-dir", "--output"} : QSet<QString>{"--archive"});
        QMap<QString, QString> options; bool json = false;
        for (qsizetype i = 1; i < args.size(); ++i) {
            const QString option = args[i];
            if (option == "--json") { require(!json, 2, "ARGUMENT_INVALID", "Duplicate --json."); json = true; continue; }
            require(allowed.contains(option) && !options.contains(option) && i + 1 < args.size() && !args[i+1].startsWith("--"), 2, "ARGUMENT_INVALID", "Unknown, duplicate, or missing-value option: " + option);
            options.insert(option, args[++i]);
        }
        require(options.value("--format", ArchiveProfile::name) == ArchiveProfile::name, 2, "PROFILE_UNSUPPORTED", "Supported archive profile is legacy-v1.");
        Limits limits;
        auto number = [&](const QString &key, qint64 fallback, qint64 maximum) {
            if (!options.contains(key)) return fallback;
            bool valid = false; const qint64 n = options[key].toLongLong(&valid);
            require(valid && n > 0 && n <= maximum, 2, "LIMIT_INVALID", "Resource limit is outside supported range: " + key); return n;
        };
        limits.maxFileBytes = number("--max-file-bytes", limits.maxFileBytes, 1024LL * 1024 * 1024);
        limits.maxTotalBytes = number("--max-total-bytes", limits.maxTotalBytes, 1024LL * 1024 * 1024 * 1024);
        limits.maxEntries = int(number("--max-entries", limits.maxEntries, 100000));
        QJsonObject payload;
        if (command == "export") {
            for (const auto &key : {QString("--manifest"), QString("--input-dir"), QString("--output")})
                require(options.contains(key), 2, "ARGUMENT_MISSING", "Required option missing: " + key);
            auto request = ExportService::manifest(options["--manifest"], requestId);
            request.inputDirectory = options["--input-dir"]; request.outputPath = options["--output"]; request.limits = limits;
            payload = ExportService::run(request);
        } else {
            require(options.contains("--archive") && QDir::isAbsolutePath(options["--archive"]), 2, "ARGUMENT_MISSING", "verify requires an absolute --archive path.");
            const auto result = LegacyArchiveReader::verify(options["--archive"], limits);
            QJsonArray entries;
            for (const auto &entry : result.entries) entries.append(QJsonObject{{"path", entry.path}, {"size_bytes", entry.size}, {"sha256", QString::fromLatin1(entry.sha256)}});
            payload = {{"archive_profile", ArchiveProfile::name}, {"entries", entries}, {"size_bytes", result.size}, {"sha256", QString::fromLatin1(result.sha256)}, {"verified", true}};
        }
        for (auto it = payload.begin(); it != payload.end(); ++it) response.insert(it.key(), it.value());
        response["ok"] = true; response["request_id"] = requestId; writeJson(response); return 0;
    } catch (const Error &error) {
        response["request_id"] = requestId; response["error"] = QJsonObject{{"code", error.code}, {"message", error.message}};
        writeJson(response); return error.exitCode;
    } catch (const std::exception &) {
        response["request_id"] = requestId; response["error"] = QJsonObject{{"code", "INTERNAL_ERROR"}, {"message", "Unexpected internal error."}};
        writeJson(response); return 10;
    }
}
}
