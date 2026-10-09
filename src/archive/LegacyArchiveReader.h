#pragma once
#include "domain/ExportRequest.h"
namespace istow {
struct ArchiveResult { QVector<EntryDigest> entries; QByteArray sha256; qint64 size = 0; };
class LegacyArchiveReader {
public:
    static ArchiveResult verify(const QString &path, const Limits &limits);
};
}
