#pragma once
#include "domain/ExportRequest.h"
namespace istow {
class LegacyArchiveWriter {
public:
    static QVector<EntryDigest> write(const QString &path, QVector<ArchiveEntry> entries, const Limits &limits);
};
}
