#pragma once
#include "domain/ShipMetadata.h"
#include "domain/ExportRequest.h"
namespace istow {
class ShipMetadataReader {
public:
    static ShipMetadata read(const QString &databasePath, const ExportRequest &request);
};
}
