#include "permissionservice.h"

// services/PermissionService.cpp
// #include "PermissionService.h"
#include "../repositories/RepositoryFactory.h"
#include "AuditLogService.h"

using namespace Repository;
using namespace LEDDB;

PermissionService::PermissionService() = default;

bool PermissionService::assignPermission(int roleId, const QString& permCode, const QString& permDesc, const QString& operatorUser) {
    auto permRepo = RepositoryFactory::createPermissionRepository();
    Permission perm;
    perm.setRoleId(roleId);
    perm.setPermCode(permCode);
    perm.setPermDesc(permDesc);
    bool success = permRepo->insert(perm);
    AuditLogService().logOperation(operatorUser, "分配权限",
                                   QString("给角色 %1 分配权限 %2").arg(roleId).arg(permCode), success ? "成功" : "失败");
    return success;
}

bool PermissionService::revokePermission(int permId, const QString& operatorUser) {
    auto permRepo = RepositoryFactory::createPermissionRepository();
    bool success = permRepo->deleteById(permId);
    AuditLogService().logOperation(operatorUser, "撤销权限",
                                   QString("撤销权限 ID=%1").arg(permId), success ? "成功" : "失败");
    return success;
}

QList<Permission> PermissionService::getPermissionsByRole(int roleId) {
    auto permRepo = RepositoryFactory::createPermissionRepository();
    return permRepo->findByRoleId(roleId);
}

bool PermissionService::hasPermission(int roleId, const QString& permCode) {
    auto perms = getPermissionsByRole(roleId);
    for (const auto& p : perms) {
        if (p.permCode() == permCode) return true;
    }
    return false;
}