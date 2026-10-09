#pragma once
#include <QJsonObject>
#include <QStringList>
namespace istow {
struct ShipMetadata {
    qint64 id = 0;
    QString name, type, company, version, prefix, databaseName;
    QStringList requiredAssets;
    QJsonObject details() const;
};
QString shipPrefix(qint64 id, QString name);
}
