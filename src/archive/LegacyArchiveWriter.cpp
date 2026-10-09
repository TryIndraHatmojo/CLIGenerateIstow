#include "LegacyArchiveWriter.h"
#include "domain/Error.h"
#include <QCryptographicHash>
#include <QFile>
#include <QSaveFile>
#include <algorithm>
namespace istow {
QVector<EntryDigest> LegacyArchiveWriter::write(const QString &path, QVector<ArchiveEntry> entries, const Limits &limits) {
    require(entries.size() <= limits.maxEntries, 3, "ENTRY_LIMIT", "Too many archive entries.");
    std::sort(entries.begin(), entries.end(), [](const auto &a, const auto &b) { return a.path < b.path; });
    QSaveFile output(path); output.setDirectWriteFallback(false);
    require(output.open(QIODevice::WriteOnly), 5, "OUTPUT_OPEN_FAILED", "Cannot open atomic output file.");
    QDataStream stream(&output); ArchiveProfile::configure(stream);
    QVector<EntryDigest> digests; qint64 total = 0;
    for (const auto &entry : entries) {
        QByteArray bytes = entry.bytes;
        if (!entry.inMemory) {
            QFile file(entry.source);
            require(file.open(QIODevice::ReadOnly), 3, "INPUT_READ_FAILED", "Cannot read staged input.");
            require(file.size() <= limits.maxFileBytes, 3, "FILE_LIMIT", "Input exceeds per-file limit.");
            bytes = file.read(limits.maxFileBytes + 1);
            require(file.error() == QFileDevice::NoError && file.atEnd() && bytes.size() == file.size(), 3, "INPUT_READ_FAILED", "Snapshot changed or input read failed.");
        }
        require(bytes.size() <= limits.maxFileBytes, 3, "FILE_LIMIT", "Entry exceeds per-file limit.");
        total += bytes.size(); require(total <= limits.maxTotalBytes, 3, "TOTAL_LIMIT", "Input exceeds total payload limit.");
        const QByteArray compressed = qCompress(bytes, ArchiveProfile::compressionLevel);
        require(compressed.size() >= 4 && compressed.size() <= limits.compressedLimit(), 6, "COMPRESSION_FAILED", "Compression failed or exceeds limit.");
        stream << entry.path << compressed;
        require(stream.status() == QDataStream::Ok && output.error() == QFileDevice::NoError, 5, "OUTPUT_WRITE_FAILED", "Cannot write archive stream.");
        require(output.pos() <= limits.archiveLimit(), 3, "ARCHIVE_LIMIT", "Compressed archive exceeds limit.");
        digests.append({entry.path, bytes.size(), QCryptographicHash::hash(bytes, QCryptographicHash::Sha256).toHex()});
    }
    require(!QFile::exists(path), 5, "OUTPUT_EXISTS", "Output appeared before commit; overwrite is forbidden.");
    require(output.commit(), 5, "OUTPUT_COMMIT_FAILED", "Atomic output commit failed.");
    return digests;
}
}
