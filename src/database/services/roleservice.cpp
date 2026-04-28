#include "roleservice.h"

// services/RoleService.cpp
// #include "RoleService.h"
#include "../repositories/RepositoryFactory.h"
#include "AuditLogService.h"
#include <QDateTime>

using namespace Repository;
using namespace LEDDB;

RoleService::RoleService() = default;

bool RoleService::createRole(const Role& role, const QString& operatorUser) {
    auto roleRepo = RepositoryFactory::createRoleRepository();
    bool success = roleRepo->insert(role);
    AuditLogService().logOperation(operatorUser, "创建角色",
                                   QString("创建角色 %1").arg(role.roleName()), success ? "成功" : "失败");
    return success;
}

bool RoleService::updateRole(const Role& role, const QString& operatorUser) {
    auto roleRepo = RepositoryFactory::createRoleRepository();
    bool success = roleRepo->update(role);
    AuditLogService().logOperation(operatorUser, "更新角色",
                                   QString("更新角色 ID=%1").arg(role.roleId()), success ? "成功" : "失败");
    return success;
}

bool RoleService::deleteRole(int roleId, const QString& operatorUser) {
    auto roleRepo = RepositoryFactory::createRoleRepository();
    auto role = roleRepo->findById(roleId);
    if (!role) return false;

    // 删除角色前，先删除其下所有权限
    auto permRepo = RepositoryFactory::createPermissionRepository();
    permRepo->deleteByRoleId(roleId);

    bool success = roleRepo->deleteById(roleId);
    AuditLogService().logOperation(operatorUser, "删除角色",
                                   QString("删除角色 %1").arg(role->roleName()), success ? "成功" : "失败");
    return success;
}

std::optional<Role> RoleService::getRoleById(int roleId) {
    auto roleRepo = RepositoryFactory::createRoleRepository();
    return roleRepo->findById(roleId);
}

QList<Role> RoleService::getAllRoles() {
    auto roleRepo = RepositoryFactory::createRoleRepository();
    return roleRepo->findAll();
}