#include "JsonResponse.h"
#include <QJsonDocument>
#include <cstdio>
namespace istow {
void writeJson(const QJsonObject &object) {
    const auto bytes = QJsonDocument(object).toJson(QJsonDocument::Compact) + '\n';
    std::fwrite(bytes.constData(), 1, size_t(bytes.size()), stdout); std::fflush(stdout);
}
}
