#include "PathValidator.h"
#include "domain/Error.h"
#include <QDir>
#include <QFileInfo>
#include <QRegularExpression>
#ifdef Q_OS_WIN
#include <qt_windows.h>
#endif
namespace istow {
void ArchiveTargets::add(const QString &path, int exitCode) {
    const QString key = path.normalized(QString::NormalizationForm_C).toCaseFolded();
    require(!files.contains(key) && !directories.contains(key), exitCode, "DUPLICATE_ENTRY", "Archive target collides with a file or directory.");
    for (qsizetype i = key.indexOf('/'); i >= 0; i = key.indexOf('/', i + 1)) {
        const QString parent = key.left(i);
        require(!files.contains(parent), exitCode, "DUPLICATE_ENTRY", "Archive target collides with a parent file.");
        directories.insert(parent);
    }
    files.insert(key);
}
void PathValidator::relative(const QString &path) {
    require(!path.isEmpty() && path.size() <= 2048 && !path.startsWith('/') && !path.contains('\\'), 3, "INVALID_PATH", "Path must be relative and use forward slashes.");
    static const QRegularExpression device("^(CON|PRN|AUX|NUL|COM[1-9¹²³]|LPT[1-9¹²³])(?:\\.|$)", QRegularExpression::CaseInsensitiveOption);
    for (const QString &part : path.split('/')) {
        require(!part.isEmpty() && part != "." && part != ".." && part.size() <= 255 && !part.endsWith('.') && !part.endsWith(' ') && !device.match(part).hasMatch(), 3, "INVALID_PATH", "Path contains an unsafe filename component.");
        for (QChar c : part)
            require(c.unicode() >= 32 && !QString("<>:\"|?*").contains(c) && !c.isHighSurrogate() && !c.isLowSurrogate(), 3, "INVALID_PATH", "Path contains characters unsupported by the legacy importer.");
    }
}
bool PathValidator::contained(const QString &root, const QString &path) {
#ifdef Q_OS_WIN
    constexpr auto mode = Qt::CaseInsensitive;
#else
    constexpr auto mode = Qt::CaseSensitive;
#endif
    return path.compare(root, mode) == 0 || path.startsWith(root + '/', mode);
}
void PathValidator::noLinks(const QString &absolutePath) {
    QString current = QDir::cleanPath(QDir::fromNativeSeparators(absolutePath));
    while (!current.isEmpty()) {
        QFileInfo info(current);
        require(!info.isSymbolicLink(), 3, "LINK_NOT_ALLOWED", "Symlinks are not allowed in staging paths.");
#ifdef Q_OS_WIN
        const DWORD attributes = GetFileAttributesW(reinterpret_cast<LPCWSTR>(current.utf16()));
        require(attributes == INVALID_FILE_ATTRIBUTES || !(attributes & FILE_ATTRIBUTE_REPARSE_POINT), 3, "LINK_NOT_ALLOWED", "Reparse points are not allowed in staging paths.");
#endif
        const QString parent = info.absolutePath();
        if (parent == current) break;
        current = parent;
    }
}
QString PathValidator::root(const QString &path) {
    require(QDir::isAbsolutePath(path), 3, "ABSOLUTE_PATH_REQUIRED", "Input directory must be absolute.");
    noLinks(path);
    QFileInfo info(path);
    require(info.isDir() && !info.canonicalFilePath().isEmpty(), 3, "INPUT_DIRECTORY_INVALID", "Input directory must exist.");
    return QDir::fromNativeSeparators(info.canonicalFilePath());
}
QString PathValidator::inputFile(const QString &root, const QString &path) {
    relative(path);
    const QString candidate = QDir(root).filePath(path);
    noLinks(candidate);
    QFileInfo info(candidate);
    const QString canonical = QDir::fromNativeSeparators(info.canonicalFilePath());
    require(info.isFile() && info.isReadable() && !canonical.isEmpty() && contained(root, canonical), 3, "INPUT_FILE_INVALID", "Input file is missing, unreadable, or outside staging: " + path);
    return canonical;
}
QString PathValidator::outputFile(const QString &path, const QString &inputRoot) {
    require(QDir::isAbsolutePath(path) && path.endsWith(".istow", Qt::CaseInsensitive), 3, "OUTPUT_PATH_INVALID", "Output must be an absolute .istow path.");
    noLinks(path);
    QFileInfo info(path);
    relative(info.fileName());
    QFileInfo parent(info.absolutePath());
    require(parent.isDir() && !parent.canonicalFilePath().isEmpty(), 5, "OUTPUT_DIRECTORY_INVALID", "Output parent directory must exist.");
    const QString output = QDir(parent.canonicalFilePath()).filePath(info.fileName());
    require(!contained(inputRoot, QDir::fromNativeSeparators(output)), 3, "OUTPUT_INSIDE_INPUT", "Output must be outside the input directory.");
    require(!info.exists(), 5, "OUTPUT_EXISTS", "Output already exists; overwrite is forbidden.");
    return output;
}
}
