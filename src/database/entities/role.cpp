// entities/role.cpp
#include "role.h"
#include "../../utils/datetimehelper.h"
#include <QSqlRecord>
namespace LEDDB {

Role::Role(int roleId, const QString& roleName, const QString& roleDesc)
    : m_roleId(roleId), m_roleName(roleName), m_roleDesc(roleDesc) {}

Role Role::fromSqlRecord(const QSqlRecord& rec)
{
    Role r;
    r.setRoleId(rec.value("role_id").toInt());
    r.setRoleName(rec.value("role_name").toString());
    r.setRoleDesc(rec.value("role_desc").toString());
    return r;
}

} // namespace LEDDB