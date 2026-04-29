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
         const QDateTime& lastLoginTime, const QDateTime& updateTime);

    // ---------- getters ----------
    int userId() const { return m_userId; }
    QString userName() const { return m_userName; }
    QString password() const { return m_password; }        // 已加密
    int roleId() const { return m_roleId; }
    int status() const { return m_status; }
    QDateTime createTime() const { return m_createTime; }
    QDateTime lastLoginTime() const { return m_lastLoginTime; }
    QDateTime updateTime() const { return m_updateTime; }   // 新增

    // ---------- setters ----------
    void setUserId(int id) { m_userId = id; }
    void setUserName(const QString& name) { m_userName = name; }
    void setPassword(const QString& pwd) { m_password = pwd; }
    void setRoleId(int id) { m_roleId = id; }
    void setStatus(int status) { m_status = status; }
    void setCreateTime(const QDateTime& dt) { m_createTime = dt; }
    void setLastLoginTime(const QDateTime& dt) { m_lastLoginTime = dt; }
    void setUpdateTime(const QDateTime& dt) { m_updateTime = dt; }   // 新增

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
    QDateTime m_updateTime;   // 新增：记录最后更新时间

};

} // namespace LEDDB

#endif // USER_H
