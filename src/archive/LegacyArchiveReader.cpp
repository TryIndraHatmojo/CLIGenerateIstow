#include "LegacyArchiveReader.h"
#include "filesystem/PathValidator.h"
#include "domain/Error.h"
#include <QCryptographicHash>
#include <QFile>
#include <QSet>
#include <QtEndian>
#include <zlib.h>
namespace istow {
static quint32 length(QDataStream &stream) {
    quint32 size = 0; stream >> size;
    require(stream.status() == QDataStream::Ok && size < 0xfffffffeU, 6, "ARCHIVE_LENGTH_INVALID", "Invalid or truncated legacy length field.");
    return size;
}
static QByteArray boundedRead(QFile &file, qint64 size, qint64 limit) {
    require(size <= limit && size <= file.size() - file.pos(), 6, "ARCHIVE_LENGTH_INVALID", "Entry length exceeds limit or remaining bytes.");
    const QByteArray bytes = file.read(size);
    require(bytes.size() == size && file.error() == QFileDevice::NoError, 6, "ARCHIVE_TRUNCATED", "Archive is truncated or unreadable.");
    return bytes;
}
static EntryDigest inflateDigest(const QString &path, const QByteArray &compressed, const Limits &limits, qint64 remaining) {
    require(compressed.size() >= 4, 6, "COMPRESSED_DATA_INVALID", "Missing qCompress length header.");
    const quint32 advertised = qFromBigEndian<quint32>(reinterpret_cast<const uchar *>(compressed.constData()));
    require(advertised <= quint64(limits.maxFileBytes) && advertised <= quint64(remaining), 3, "DECOMPRESSION_LIMIT", "Decompressed entry exceeds payload limits.");
    // Qt encodes a zero-byte payload as just its four-byte header.
    if (compressed.size() == 4) {
        require(advertised == 0, 6, "COMPRESSED_DATA_INVALID", "Missing zlib stream.");
        return {path, 0, QCryptographicHash::hash(QByteArray(""), QCryptographicHash::Sha256).toHex()};
    }
    z_stream inflater{};
    require(inflateInit(&inflater) == Z_OK, 10, "ZLIB_INIT_FAILED", "Cannot initialize zlib reader.");
    struct End { z_stream *s; ~End() { inflateEnd(s); } } end{&inflater};
    inflater.next_in = reinterpret_cast<Bytef *>(const_cast<char *>(compressed.constData() + 4));
    inflater.avail_in = uInt(compressed.size() - 4);
    QCryptographicHash hash(QCryptographicHash::Sha256); qint64 total = 0;
    char buffer[65536]; int status = Z_OK;
    while (status != Z_STREAM_END) {
        inflater.next_out = reinterpret_cast<Bytef *>(buffer); inflater.avail_out = sizeof(buffer);
        status = inflate(&inflater, Z_NO_FLUSH);
        require(status == Z_OK || status == Z_STREAM_END, 6, "COMPRESSED_DATA_INVALID", "Corrupt or incomplete zlib payload.");
        const qint64 produced = sizeof(buffer) - inflater.avail_out; total += produced;
        require(total <= limits.maxFileBytes && total <= remaining, 3, "DECOMPRESSION_LIMIT", "Actual decompressed data exceeds limits.");
        hash.addData(QByteArrayView(buffer, produced));
        require(produced > 0 || status == Z_STREAM_END, 6, "COMPRESSED_DATA_INVALID", "Zlib stream made no progress.");
    }
    require(total == advertised && inflater.avail_in == 0, 6, "COMPRESSED_DATA_INVALID", "qCompress size mismatch or trailing compressed bytes.");
    return {path, total, hash.result().toHex()};
}
ArchiveResult LegacyArchiveReader::verify(const QString &path, const Limits &limits) {
    QFile file(path);
    require(file.open(QIODevice::ReadOnly), 3, "ARCHIVE_OPEN_FAILED", "Cannot open archive.");
    require(file.size() > 0 && file.size() <= limits.archiveLimit(), 3, "ARCHIVE_LIMIT", "Archive is empty or exceeds compressed-size limit.");
    ArchiveResult result; result.size = file.size();
    QDataStream stream(&file); ArchiveProfile::configure(stream);
    ArchiveTargets paths; QString database; int details = 0; qint64 total = 0;
    while (!file.atEnd()) {
        require(result.entries.size() < limits.maxEntries, 3, "ENTRY_LIMIT", "Archive exceeds entry limit.");
        const auto pathSize = length(stream);
        require(pathSize > 0 && pathSize % 2 == 0, 6, "ARCHIVE_PATH_INVALID", "Invalid UTF-16 entry path.");
        const auto utf16 = boundedRead(file, pathSize, 4096);
        QString entry;
        for (qsizetype i = 0; i < utf16.size(); i += 2)
            entry.append(QChar(qFromBigEndian<quint16>(reinterpret_cast<const uchar *>(utf16.constData() + i))));
        require(entry.startsWith('/'), 6, "ARCHIVE_PATH_INVALID", "Legacy entry must have a leading slash.");
        PathValidator::relative(entry.mid(1));
        paths.add(entry.mid(1), 6);
        if (entry.endsWith(".db", Qt::CaseInsensitive)) {
            require(database.isEmpty() && !entry.mid(1).contains('/'), 6, "ARCHIVE_DB_INVALID", "Archive must have one root database."); database = entry;
        }
        if (entry.endsWith(".details", Qt::CaseInsensitive)) ++details;
        require(!entry.endsWith(".db-wal", Qt::CaseInsensitive) && !entry.endsWith(".db-shm", Qt::CaseInsensitive) && !entry.endsWith(".istow", Qt::CaseInsensitive), 6, "ARCHIVE_ENTRY_INVALID", "Archive contains an excluded file type.");
        const auto compressedSize = length(stream);
        const auto compressed = boundedRead(file, compressedSize, limits.compressedLimit());
        auto digest = inflateDigest(entry, compressed, limits, limits.maxTotalBytes - total);
        total += digest.size; result.entries.append(digest);
    }
    require(stream.status() == QDataStream::Ok && !database.isEmpty() && details == 1, 6, "ARCHIVE_STRUCTURE_INVALID", "Expected exactly one database and one .details entry.");
    require(file.seek(0), 6, "ARCHIVE_READ_FAILED", "Cannot rewind archive for checksum.");
    QCryptographicHash hash(QCryptographicHash::Sha256);
    require(hash.addData(&file), 6, "ARCHIVE_READ_FAILED", "Cannot calculate archive checksum.");
    result.sha256 = hash.result().toHex(); return result;
}
}
