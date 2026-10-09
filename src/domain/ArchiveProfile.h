#pragma once
#include <QDataStream>
namespace istow {
struct ArchiveProfile {
    static constexpr const char *name = "legacy-v1";
    static constexpr int streamVersion = QDataStream::Qt_5_15;
    static constexpr int compressionLevel = -1;
    static void configure(QDataStream &stream) {
        stream.setVersion(streamVersion);
        stream.setByteOrder(QDataStream::BigEndian);
    }
};
struct Limits {
    qint64 maxFileBytes = 256LL * 1024 * 1024;
    qint64 maxTotalBytes = 1024LL * 1024 * 1024;
    int maxEntries = 4096;
    // zlib compressBound overhead + a conservative margin, including the Qt header.
    qint64 compressedLimit() const { return maxFileBytes + maxFileBytes / 1000 + 65536; }
    qint64 archiveLimit() const { return maxTotalBytes + maxTotalBytes / 1000 + qint64(maxEntries) * 73728; }
};
}
