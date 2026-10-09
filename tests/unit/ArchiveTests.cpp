#include "archive/LegacyArchiveReader.h"
#include "archive/LegacyArchiveWriter.h"
#include "database/ShipMetadataReader.h"
#include "domain/Error.h"
#include "filesystem/PathValidator.h"
#include <QFile>
#include <QTemporaryDir>
#include <QtTest>
using namespace istow;
class ArchiveTests : public QObject {
    Q_OBJECT
private slots:
    void prefixMatchesExisting() {
        QCOMPARE(shipPrefix(12, QString::fromUtf8("MV Pranala! é中")), QString("12_MVPranala_"));
        QVERIFY_EXCEPTION_THROWN(shipPrefix(12, QString::fromUtf8("中!")), Error);
    }
    void fileDirectoryCollision() {
        ArchiveTargets names; names.add("assets/12_Test_image");
        QVERIFY_EXCEPTION_THROWN(names.add("assets/12_Test_image/12_Test_logo.png"), Error);
        ArchiveTargets reverse; reverse.add("assets/12_Test_image/12_Test_logo.png");
        QVERIFY_EXCEPTION_THROWN(reverse.add("assets/12_Test_image"), Error);
    }
    void legacyImporterReadsCli() {
        QTemporaryDir dir;
        const QString output = dir.filePath("ship.istow");
        QVector<ArchiveEntry> entries{{"/12_Test.db", {}, QByteArray("DB\0bytes", 8), true},
            {"/assets/images/12_Test_empty.png", {}, QByteArray(""), true},
            {"/tmp/12_Test_ship.details", {}, QByteArray("{}"), true}};
        const auto expected = LegacyArchiveWriter::write(output, entries, Limits{});
        // Verbatim format-reading operations from Tools::unCompressShip; safe
        // internal fixture only. Default desktop stream version is intentional.
        QFile file(output); QVERIFY(file.open(QIODevice::ReadOnly)); QDataStream stream(&file);
        int count = 0;
        while (!stream.atEnd()) {
            QString name; QByteArray compressed; stream >> name >> compressed;
            QCOMPARE(stream.status(), QDataStream::Ok);
            const auto found = std::find_if(entries.begin(), entries.end(), [&](const auto &e) { return e.path == name; });
            QVERIFY(found != entries.end()); QCOMPARE(qUncompress(compressed), found->bytes); ++count;
        }
        QCOMPARE(count, 3);
        QCOMPARE(LegacyArchiveReader::verify(output, Limits{}).entries.size(), expected.size());
    }
    void cliReadsExistingFormat() {
        QTemporaryDir dir; QFile file(dir.filePath("legacy.istow"));
        QVERIFY(file.open(QIODevice::WriteOnly)); QDataStream stream(&file);
        // Mirrors Tools::compressShipFromId, including its unpinned version.
        stream << QString("/12_Test.db") << qCompress(QByteArray("database"));
        stream << QString("/tmp/12_Test_ship.details") << qCompress(QByteArray("{}"));
        file.close();
        QCOMPARE(LegacyArchiveReader::verify(file.fileName(), Limits{}).entries.size(), 2);
    }
    void atomicWriteFailureLeavesNoOutput() {
        QTemporaryDir dir; Limits limits; limits.maxFileBytes = 1;
        const auto output = dir.filePath("failed.istow");
        QVERIFY_EXCEPTION_THROWN(LegacyArchiveWriter::write(output, {{"/x.db", {}, QByteArray("long"), true}}, limits), Error);
        QVERIFY(!QFile::exists(output));
        QCOMPARE(QDir(dir.path()).entryList(QDir::Files | QDir::Hidden).size(), 0);
    }
};
QTEST_GUILESS_MAIN(ArchiveTests)
#include "ArchiveTests.moc"
