// entities/permission.cpp
#include "permission.h"
#include <QSqlRecord>
#include "../../utils/datetimehelper.h"
namespace LEDDB {

Permission::Permission(int permId, int roleId, const QString& permCode, const QString& permDesc)
    : m_permId(permId), m_roleId(roleId), m_permCode(permCode), m_permDesc(permDesc) {}

Permission Permission::fromSqlRecord(const QSqlRecord& rec)
{
    Permission p;
    p.setPermId(rec.value("perm_id").toInt());
    p.setRoleId(rec.value("role_id").toInt());
    p.setPermCode(rec.value("perm_code").toString());
    p.setPermDesc(rec.value("perm_desc").toString());
    return p;
}

} // namespace LEDDB