#include "ShipDatabaseValidator.h"
#include "domain/Error.h"
#include <QFile>
#include <QJsonDocument>
#include <QJsonArray>
#include <QJsonObject>
#include <QSqlQuery>
#include <QSet>
static void initializeProfiles() { Q_INIT_RESOURCE(profiles); }
namespace istow {
void ShipDatabaseValidator::validate(QSqlDatabase &db) {
    QSqlQuery check(db);
    require(check.exec("PRAGMA integrity_check") && check.next() && check.value(0).toString() == "ok" && !check.next(), 4, "DB_INTEGRITY_FAILED", "SQLite integrity check failed.");
    initializeProfiles();
    QFile profile(":/profiles/ship-configure-schema.json");
    require(profile.open(QIODevice::ReadOnly), 10, "SCHEMA_PROFILE_MISSING", "Built-in schema profile is unavailable.");
    const auto schema = QJsonDocument::fromJson(profile.readAll()).object();
    const auto tables = db.tables(QSql::Tables);
    for (auto it = schema.begin(); it != schema.end(); ++it) {
        // Legacy installations may omit infotbl; version is optional.
        if (it.key() == "infotbl" && !tables.contains(it.key())) continue;
        require(tables.contains(it.key()), 4, "DB_SCHEMA_MISMATCH", "Required ship-configure table is missing: " + it.key());
        QSqlQuery columns(db);
        require(columns.exec("PRAGMA table_info(\"" + it.key() + "\")"), 4, "DB_SCHEMA_MISMATCH", "Cannot inspect SQLite schema.");
        QSet<QString> names;
        while (columns.next()) names.insert(columns.value(1).toString());
        for (const auto &column : it.value().toArray())
            require(names.contains(column.toString()), 4, "DB_SCHEMA_MISMATCH", "Required column is missing: " + it.key() + "." + column.toString());
    }
    QSqlQuery foreignKeys(db);
    require(foreignKeys.exec("PRAGMA foreign_key_check") && !foreignKeys.next(), 4, "DB_FOREIGN_KEY_FAILED", "SQLite foreign key check failed.");
}
}
