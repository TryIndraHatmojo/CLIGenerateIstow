#pragma once
#include <QString>
#include <stdexcept>
namespace istow {
class Error : public std::runtime_error {
public:
    int exitCode;
    QString code;
    QString message;
    Error(int status, QString key, QString text)
        : std::runtime_error(text.toStdString()), exitCode(status), code(std::move(key)), message(std::move(text)) {}
};
inline void require(bool valid, int status, const QString &key, const QString &text) {
    if (!valid) throw Error(status, key, text);
}
}
