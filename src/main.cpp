#include "cli/CommandRouter.h"
#include <QCoreApplication>
#include <cstdio>
static void diagnostic(QtMsgType, const QMessageLogContext &, const QString &message) {
    const QByteArray bytes = message.toUtf8() + '\n';
    std::fwrite(bytes.constData(), 1, size_t(bytes.size()), stderr);
}
int main(int argc, char **argv) {
    QCoreApplication app(argc, argv);
    QCoreApplication::setApplicationName("istow-cli");
    qInstallMessageHandler(diagnostic);
    return istow::CommandRouter::run(app.arguments());
}
