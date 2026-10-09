#pragma once
#include "domain/ExportRequest.h"
#include <QJsonObject>
namespace istow {
class ExportService {
public:
    static ExportRequest manifest(const QString &path, QJsonValue &requestId);
    static QJsonObject run(ExportRequest request);
};
}
