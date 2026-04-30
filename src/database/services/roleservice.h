#ifndef ROLESERVICE_H
#define ROLESERVICE_H

// services/RoleService.h
#pragma once
#include "../entities/role.h"
#include <optional>
#include <QList>
#include "userservice.h"
#include "../databasemanager.h"
class RoleService {
public:
    RoleService();

    bool createRole(const LEDDB::Role& role, const QString& operatorUser);
    bool updateRole(const LEDDB::Role& role, const QString& operatorUser);
    bool deleteRole(int roleId, const QString& operatorUser);  // 同时删除关联权限
    std::optional<LEDDB::Role> getRoleById(int roleId) const;
    std::optional<LEDDB::Role> getRoleByName(const QString& roleName) const;
    QList<LEDDB::Role> getAllRoles() const;
private:
    int getUserIdByUserName(const QString& userName) const;
};

#endif // ROLESERVICE_H