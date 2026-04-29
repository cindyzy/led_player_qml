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
    int userId = 0;
    auto userRepo = RepositoryFactory::createUserRepository();
    auto userOpt = userRepo->findByUserName(operatorUser);
    if (userOpt.has_value()) {
        userId = userOpt.value().userId();
    }

    AuditLogService().logOperation(userId, "分配权限",
                                   success ? "成功" : "失败",
                                   QString("给角色 %1 分配权限 %2").arg(roleId).arg(permCode),
                                   "sys_permission", perm.permId());
    return success;
}

bool PermissionService::revokePermission(int permId, const QString& operatorUser) {
    auto permRepo = RepositoryFactory::createPermissionRepository();
    bool success = permRepo->deleteById(permId);

    int userId = 0;
    auto userRepo = RepositoryFactory::createUserRepository();
    auto userOpt = userRepo->findByUserName(operatorUser);
    if (userOpt.has_value()) {
        userId = userOpt.value().userId();
    }

    AuditLogService().logOperation(userId, "撤销权限",
                                   success ? "成功" : "失败",
                                   QString("撤销权限 ID=%1").arg(permId),
                                   "sys_permission", permId);
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