#pragma once
#include <QString>
#include <QSet>
namespace istow {
class PathValidator {
public:
    static void relative(const QString &path);
    static QString root(const QString &path);
    static QString inputFile(const QString &root, const QString &path);
    static QString outputFile(const QString &path, const QString &inputRoot);
    static bool contained(const QString &root, const QString &path);
    static void noLinks(const QString &absolutePath);
};
class ArchiveTargets {
    QSet<QString> files, directories;
public:
    void add(const QString &relativePath, int exitCode = 3);
};
}
