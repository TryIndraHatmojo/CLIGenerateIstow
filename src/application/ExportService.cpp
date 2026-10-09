#include "ExportService.h"
#include "archive/LegacyArchiveReader.h"
#include "archive/LegacyArchiveWriter.h"
#include "database/ShipMetadataReader.h"
#include "filesystem/PathValidator.h"
#include "domain/Error.h"
#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QJsonArray>
#include <QJsonDocument>
#include <QLockFile>
#include <QSet>
#include <cmath>
namespace istow {
ExportRequest ExportService::manifest(const QString &path, QJsonValue &requestId) {
    require(QDir::isAbsolutePath(path), 2, "MANIFEST_PATH_INVALID", "Manifest path must be absolute.");
    PathValidator::noLinks(path);
    QFile file(path);
    require(file.open(QIODevice::ReadOnly) && file.size() <= 4 * 1024 * 1024, 2, "MANIFEST_READ_FAILED", "Manifest is unreadable or exceeds 4 MiB.");
    QJsonParseError parse;
    const auto document = QJsonDocument::fromJson(file.read(4 * 1024 * 1024 + 1), &parse);
    require(parse.error == QJsonParseError::NoError && document.isObject(), 2, "MANIFEST_INVALID", "Manifest must be a valid JSON object.");
    const auto obj = document.object();
    if (obj.value("request_id").isString()) requestId = obj.value("request_id");
    require(obj.value("schema_version").isDouble() && obj.value("schema_version").toDouble() == 1, 2, "SCHEMA_VERSION_UNSUPPORTED", "Supported manifest schema_version is 1.");
    require(requestId.isString() && !requestId.toString().trimmed().isEmpty() && requestId.toString().size() <= 128, 2, "REQUEST_ID_INVALID", "request_id must be a nonempty string up to 128 characters.");
    const auto ship = obj.value("ship").toObject(); const auto id = ship.value("id");
    require(id.isDouble() && id.toDouble() > 0 && id.toDouble() <= 9007199254740991.0 && std::floor(id.toDouble()) == id.toDouble() && ship.value("name").isString() && !ship.value("name").toString().isEmpty(), 2, "SHIP_INVALID", "ship.id must be a positive integer and ship.name a nonempty string.");
    ExportRequest request; request.requestId = requestId; request.shipId = qint64(id.toDouble()); request.shipName = ship.value("name").toString();
    require(obj.value("database").isObject() && obj.value("database").toObject().value("source").isString() && obj.value("assets").isArray(), 2, "MANIFEST_INVALID", "database.source and assets are required.");
    request.database = obj.value("database").toObject().value("source").toString();
    for (const auto &item : obj.value("assets").toArray()) {
        const auto asset = item.toObject();
        require(item.isObject() && asset.value("source").isString() && asset.value("archive_path").isString(), 2, "ASSET_INVALID", "Every asset needs source and archive_path strings.");
        request.assets.append({asset.value("source").toString(), asset.value("archive_path").toString()});
    }
    return request;
}
QJsonObject ExportService::run(ExportRequest request) {
    request.inputDirectory = PathValidator::root(request.inputDirectory);
    request.outputPath = PathValidator::outputFile(request.outputPath, request.inputDirectory);
    PathValidator::noLinks(request.outputPath + ".lock");
    QLockFile lock(request.outputPath + ".lock"); lock.setStaleLockTime(0);
    require(lock.tryLock(0), 5, "OUTPUT_LOCKED", "Another export holds the output lock.");
    require(!QFile::exists(request.outputPath), 5, "OUTPUT_EXISTS", "Output already exists.");
    require(request.assets.size() + 2 <= request.limits.maxEntries, 3, "ENTRY_LIMIT", "Too many manifest entries.");
    const QString databasePath = PathValidator::inputFile(request.inputDirectory, request.database);
    require(!QFileInfo::exists(databasePath + "-wal") && !QFileInfo::exists(databasePath + "-shm"), 4, "SNAPSHOT_ACTIVE", "Snapshot must not have WAL/SHM sidecars.");
    require(QFileInfo(databasePath).size() <= request.limits.maxFileBytes, 3, "FILE_LIMIT", "Database exceeds file limit.");
    const auto metadata = ShipMetadataReader::read(databasePath, request);
    QVector<ArchiveEntry> entries{{"/" + metadata.databaseName, databasePath, {}, false}};
    const QString detailPath = "tmp/" + metadata.prefix + "ship.details";
    PathValidator::relative(metadata.databaseName);
    PathValidator::relative(detailPath);
    ArchiveTargets names; names.add(metadata.databaseName); names.add(detailPath); QSet<QString> assets;
    qint64 total = QFileInfo(databasePath).size();
    for (const auto &asset : request.assets) {
        PathValidator::relative(asset.archivePath);
        names.add(asset.archivePath);
        const QString suffix = QFileInfo(asset.archivePath).suffix().toLower();
        require(!QStringList{"db", "details", "istow", "log", "license"}.contains(suffix) && !asset.archivePath.endsWith("-wal", Qt::CaseInsensitive) && !asset.archivePath.endsWith("-shm", Qt::CaseInsensitive) && !asset.archivePath.startsWith("license/", Qt::CaseInsensitive), 3, "ASSET_TYPE_INVALID", "Asset uses an excluded file type or directory.");
        require(QFileInfo(asset.archivePath).fileName().startsWith(metadata.prefix) && QFileInfo(asset.source).fileName().startsWith(metadata.prefix), 3, "ASSET_PREFIX_MISMATCH", "Asset source and target basenames must use the canonical ship prefix.");
        const QString source = PathValidator::inputFile(request.inputDirectory, asset.source);
        const qint64 size = QFileInfo(source).size(); total += size;
        require(size <= request.limits.maxFileBytes && total <= request.limits.maxTotalBytes, 3, "PAYLOAD_LIMIT", "Staging exceeds payload limits.");
        assets.insert(asset.archivePath); entries.append({"/" + asset.archivePath, source, {}, false});
    }
    for (const QString &required : metadata.requiredAssets)
        require(assets.contains(required), 3, "REFERENCED_ASSET_MISSING", "Manifest omits a required DB asset: " + required);
    entries.append({"/" + detailPath, {}, QJsonDocument(metadata.details()).toJson(QJsonDocument::Compact), true});
    bool committed = false;
    try {
        const auto expected = LegacyArchiveWriter::write(request.outputPath, entries, request.limits); committed = true;
        const auto actual = LegacyArchiveReader::verify(request.outputPath, request.limits);
        require(expected.size() == actual.entries.size(), 6, "VERIFICATION_FAILED", "Archive entry count differs from source.");
        for (qsizetype i = 0; i < expected.size(); ++i)
            require(expected[i].path == actual.entries[i].path && expected[i].size == actual.entries[i].size && expected[i].sha256 == actual.entries[i].sha256, 6, "VERIFICATION_FAILED", "Archive payload differs from source.");
        return {{"ship_id", metadata.id}, {"fileprefix", metadata.prefix}, {"archive_profile", ArchiveProfile::name},
                {"output", QJsonObject{{"filename", QFileInfo(request.outputPath).fileName()}, {"size_bytes", actual.size}, {"sha256", QString::fromLatin1(actual.sha256)}}},
                {"entries", actual.entries.size()}, {"verified", true}};
    } catch (...) { if (committed) QFile::remove(request.outputPath); throw; }
}
}
