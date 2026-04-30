#ifndef ROLE_H
#define ROLE_H

// entities/role.h
#pragma once
#include <QString>
#include <QSqlRecord>
namespace LEDDB {

class Role {
public:
    Role() = default;
    Role(int roleId, const QString& roleName, const QString& roleDesc);

    int roleId() const { return m_roleId; }
    void setRoleId(int id) { m_roleId = id; }

    QString roleName() const { return m_roleName; }
    void setRoleName(const QString& name) { m_roleName = name; }

    QString roleDesc() const { return m_roleDesc; }
    void setRoleDesc(const QString& desc) { m_roleDesc = desc; }

    static Role fromSqlRecord(const QSqlRecord& record);

private:
    int m_roleId = 0;          ///< 角色ID，数据库主键，0 表示未持久化
    QString m_roleName;        ///< 角色名称，应唯一且非空
    QString m_roleDesc;        ///< 角色描述，可选信息
};

} // namespace LEDDB

#endif // ROLE_H
