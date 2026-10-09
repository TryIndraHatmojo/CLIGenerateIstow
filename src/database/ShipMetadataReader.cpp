#include "ShipMetadataReader.h"
#include "ShipDatabaseValidator.h"
#include "filesystem/PathValidator.h"
#include "domain/Error.h"
#include <QDateTime>
#include <QRegularExpression>
#include <QSqlQuery>
#include <QSqlRecord>
#include <QUuid>
namespace istow {
QString shipPrefix(qint64 id, QString name) {
    name.remove(QRegularExpression("[^a-zA-Z0-9\\d\\s]")).remove(QRegularExpression("\\s"));
    require(id > 0 && !name.isEmpty(), 4, "SHIP_NAME_INVALID", "Ship ID/name does not produce a valid legacy prefix.");
    return QString::number(id) + '_' + name + '_';
}
QJsonObject ShipMetadata::details() const {
    return {{"idship", id}, {"tipe", type}, {"nama", name}, {"company", company},
            {"dbid", databaseName}, {"fileprefix", prefix}, {"version", version},
            {"lastupdate", QDateTime::currentSecsSinceEpoch()}};
}
ShipMetadata ShipMetadataReader::read(const QString &path, const ExportRequest &request) {
    require(QSqlDatabase::isDriverAvailable("QSQLITE"), 4, "SQLITE_DRIVER_MISSING", "Qt QSQLITE plugin is unavailable.");
    const QString connection = QUuid::createUuid().toString(QUuid::WithoutBraces);
    ShipMetadata result;
    try {
        auto db = QSqlDatabase::addDatabase("QSQLITE", connection);
        db.setDatabaseName(path);
        db.setConnectOptions("QSQLITE_OPEN_READONLY;QSQLITE_BUSY_TIMEOUT=1000");
        require(db.open(), 4, "DB_OPEN_FAILED", "Cannot open SQLite snapshot read-only.");
        ShipDatabaseValidator::validate(db);
        QSqlQuery query(db);
        require(query.exec("SELECT s.id,s.name,t.name,o.name,s.owner_id,s.operator_id,s.class_id FROM shiptbl s LEFT JOIN shiptypetbl t ON s.shiptype_id=t.id LEFT JOIN operatortbl o ON s.operator_id=o.id") && query.next(), 4, "SHIP_METADATA_INVALID", "Ship metadata is missing.");
        result.id = query.value(0).toLongLong(); result.name = query.value(1).toString();
        result.type = query.value(2).toString(); result.company = query.value(3).toString();
        const QVector<QPair<QString, qint64>> logos = {{"ownertbl", query.value(4).toLongLong()}, {"operatortbl", query.value(5).toLongLong()}, {"classtbl", query.value(6).toLongLong()}};
        require(!query.next(), 4, "MULTIPLE_SHIPS", "Snapshot must contain exactly one ship.");
        require(result.id == request.shipId, 4, "SHIP_ID_MISMATCH", "Manifest ship ID does not match SQLite.");
        require(result.name == request.shipName, 4, "SHIP_NAME_MISMATCH", "Manifest ship name does not match SQLite.");
        require(result.type.compare("Container", Qt::CaseInsensitive) == 0 || result.type.compare("Ferry / RoRo", Qt::CaseInsensitive) == 0, 4, "SHIP_TYPE_UNSUPPORTED", "Supported schema profiles: Container, Ferry / RoRo.");
        result.prefix = shipPrefix(result.id, result.name);
        result.databaseName = result.prefix.chopped(1) + ".db";
        require(request.database == result.databaseName, 4, "DB_NAME_MISMATCH", "Snapshot basename must match canonical ship identity.");
        if (db.tables().contains("infotbl")) {
            query.prepare("SELECT val FROM infotbl WHERE ship_id=:ship AND param='version'");
            query.bindValue(":ship", result.id);
            require(query.exec(), 4, "VERSION_QUERY_FAILED", "Cannot read ship version.");
            if (query.next()) result.version = query.value(0).toString();
            require(!query.next(), 4, "VERSION_AMBIGUOUS", "Ship version has multiple rows.");
        }
        // These consumers call Tools::convertNameToPathQML(..., basename), which
        // resolves assets/images/<prefix><basename>. Do not accept arbitrary URLs.
        for (const auto &logo : logos) {
            query.prepare("SELECT pathlogo FROM " + logo.first + " WHERE id=:id"); query.bindValue(":id", logo.second);
            require(query.exec(), 4, "ASSET_QUERY_FAILED", "Cannot read logo references.");
            if (query.next() && !query.value(0).toString().isEmpty()) {
                const QString name = query.value(0).toString(); PathValidator::relative(name);
                require(!name.contains('/'), 4, "ASSET_REFERENCE_INVALID", "Legacy logo reference must be a basename.");
                result.requiredAssets.append("assets/images/" + result.prefix + name);
            }
        }
        // Container bay/tier consumers use the same basename mapping.
        for (const QString &table : {QString("baystbl"), QString("tierstbl")}) {
            query.prepare("SELECT path FROM " + table + " WHERE ship_id=:ship"); query.bindValue(":ship", result.id);
            require(query.exec(), 4, "ASSET_QUERY_FAILED", "Cannot read container image references.");
            while (query.next()) {
                const QString name = query.value(0).toString(); if (name.isEmpty()) continue;
                PathValidator::relative(name);
                require(!name.contains('/'), 4, "ASSET_REFERENCE_INVALID", "Legacy image reference must be a basename.");
                result.requiredAssets.append("assets/images/" + result.prefix + name);
            }
        }
        // Fail closed for asset columns whose consumers are not present/audited
        // in this checkout. Never imply that a missing model/image is complete.
        const QVector<QPair<QString, QStringList>> unmapped = {
            {"shiptbl", {"pathconfig"}}, {"cargoview", {"image"}},
            {"containertypetbl", {"path"}}, {"decktbl", {"image", "object3d"}},
            {"shiploadtypetbl", {"image"}}, {"tank3dtbl", {"filename"}},
            {"kendaraantypetbl", {"image", "model3d"}}, {"muatantypetbl", {"image", "model3d"}}
        };
        for (const auto &item : unmapped) {
            for (const QString &column : item.second) {
                require(query.exec("SELECT \"" + column + "\" FROM \"" + item.first + "\" WHERE \"" + column + "\" IS NOT NULL"), 4, "ASSET_QUERY_FAILED", "Cannot inspect additional asset references.");
                while (query.next()) {
                    const QString reference = query.value(0).toString();
                    require(reference.isEmpty() || reference.startsWith("qrc:/") || reference.startsWith(":/"), 4, "ASSET_MAPPING_UNSUPPORTED", "External asset mapping requires an audited profile: " + item.first + "." + column);
                }
            }
        }
        db.close();
    } catch (...) { QSqlDatabase::removeDatabase(connection); throw; }
    QSqlDatabase::removeDatabase(connection);
    return result;
}
}
