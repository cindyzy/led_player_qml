#ifndef PERMISSIONSERVICE_H
#define PERMISSIONSERVICE_H

// services/PermissionService.h
#pragma once
#include "../entities/permission.h"
#include <QList>

class PermissionService {
public:
    PermissionService();

    bool assignPermission(int roleId, const QString& permCode, const QString& permDesc, const QString& operatorUser);
    bool revokePermission(int permId, const QString& operatorUser);
    QList<LEDDB::Permission> getPermissionsByRole(int roleId);
    bool hasPermission(int roleId, const QString& permCode);
};

#endif // PERMISSIONSERVICE_H
