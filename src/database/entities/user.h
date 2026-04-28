#ifndef USER_H
#define USER_H

// entities/user.h
#pragma once
#include <QString>
#include <QDateTime>
#include <QSqlRecord>
namespace LEDDB {

class User {
public:
    User() = default;
    User(int userId, const QString& userName, const QString& password,
         int roleId, int status, const QDateTime& createTime,
         const QDateTime& lastLoginTime);

    // Getter / Setter
    int userId() const { return m_userId; }
    void setUserId(int id) { m_userId = id; }

    QString userName() const { return m_userName; }
    void setUserName(const QString& name) { m_userName = name; }

    QString password() const { return m_password; }        // 已加密
    void setPassword(const QString& pwd) { m_password = pwd; }

    int roleId() const { return m_roleId; }
    void setRoleId(int id) { m_roleId = id; }

    int status() const { return m_status; }
    void setStatus(int status) { m_status = status; }      // 0-禁用 1-正常

    QDateTime createTime() const { return m_createTime; }
    void setCreateTime(const QDateTime& dt) { m_createTime = dt; }

    QDateTime lastLoginTime() const { return m_lastLoginTime; }
    void setLastLoginTime(const QDateTime& dt) { m_lastLoginTime = dt; }

    // 从数据库记录构建
    static User fromSqlRecord(const QSqlRecord& record);

private:
    int m_userId = 0;
    QString m_userName;
    QString m_password;      // AES加密存储
    int m_roleId = 0;
    int m_status = 1;
    QDateTime m_createTime;
    QDateTime m_lastLoginTime;
};

} // namespace LEDDB

#endif // USER_H
