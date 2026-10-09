#pragma once
#include <QSqlDatabase>
namespace istow {
class ShipDatabaseValidator {
public:
    static void validate(QSqlDatabase &db);
};
}
