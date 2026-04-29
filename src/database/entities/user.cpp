// entities/user.cpp
#include "user.h"
#include "../../utils/datetimehelper.h"
#include <QSqlRecord>

namespace LEDDB {

User::User(int userId, const QString& userName, const QString& password,
           int roleId, int status, const QDateTime& createTime,
           const QDateTime& lastLoginTime, const QDateTime& updateTime)
    : m_userId(userId)
    , m_userName(userName)
    , m_password(password)
    , m_roleId(roleId)
    , m_status(status)
    , m_createTime(createTime)
    , m_lastLoginTime(lastLoginTime)
    , m_updateTime(updateTime)
{
}

User User::fromSqlRecord(const QSqlRecord& rec)
{
    User u;
    u.setUserId(rec.value("user_id").toInt());
    u.setUserName(rec.value("user_name").toString());
    u.setPassword(rec.value("password").toString());
    u.setRoleId(rec.value("role_id").toInt());
    u.setStatus(rec.value("status").toInt());
    u.setCreateTime(fromIsoString(rec.value("create_time").toString()));
    u.setLastLoginTime(fromIsoString(rec.value("last_login_time").toString()));
    u.setUpdateTime(fromIsoString(rec.value("update_time").toString()));
    return u;
}

} // namespace LEDDB