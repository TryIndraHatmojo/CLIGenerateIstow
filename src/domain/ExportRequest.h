#pragma once
#include "ArchiveProfile.h"
#include <QJsonValue>
#include <QVector>
namespace istow {
struct Asset { QString source; QString archivePath; };
struct ExportRequest {
    QJsonValue requestId = QJsonValue::Null;
    qint64 shipId = 0;
    QString shipName, database, inputDirectory, outputPath;
    QVector<Asset> assets;
    Limits limits;
};
struct ArchiveEntry { QString path, source; QByteArray bytes; bool inMemory = false; };
struct EntryDigest { QString path; qint64 size = 0; QByteArray sha256; };
}
