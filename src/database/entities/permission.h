#ifndef PERMISSION_H
#define PERMISSION_H

// entities/permission.h
#pragma once
#include <QString>
#include <QSqlRecord>
namespace LEDDB {

class Permission {
public:
    Permission() = default;
    Permission(int permId, int roleId, const QString& permCode, const QString& permDesc);

    int permId() const { return m_permId; }
    void setPermId(int id) { m_permId = id; }

    int roleId() const { return m_roleId; }
    void setRoleId(int id) { m_roleId = id; }

    QString permCode() const { return m_permCode; }
    void setPermCode(const QString& code) { m_permCode = code; }

    QString permDesc() const { return m_permDesc; }
    void setPermDesc(const QString& desc) { m_permDesc = desc; }

    static Permission fromSqlRecord(const QSqlRecord& record);

private:
    int m_permId = 0;
    int m_roleId = 0;
    QString m_permCode;
    QString m_permDesc;
};

} // namespace LEDDB

#endif // PERMISSION_H
