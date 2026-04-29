#include "roleservice.h"

// services/RoleService.cpp
// #include "RoleService.h"
#include "../repositories/RepositoryFactory.h"
#include "AuditLogService.h"
#include <QDateTime>

using namespace Repository;
using namespace LEDDB;

RoleService::RoleService() = default;
bool RoleService::createRole(const Role& role, const QString& operatorUser)
{
    auto roleRepo = RepositoryFactory::createRoleRepository();
    bool success = roleRepo->insert(role);
    // 获取操作者的 userId
    int userId = getUserIdByUserName(operatorUser);
    AuditLogService audit;
    audit.logOperation(userId, "创建角色",
                       success ? "成功" : "失败",
                       QString("创建角色 %1").arg(role.roleName()),
                       "sys_role", 0,   // 新建角色，targetId 未知，传 0
                       "");             // clientIp 暂缺，可由上层传入，此处留空
    return success;
}

bool RoleService::updateRole(const Role& role, const QString& operatorUser)
{
    auto roleRepo = RepositoryFactory::createRoleRepository();
    bool success = roleRepo->update(role);
    int userId = getUserIdByUserName(operatorUser);
    AuditLogService audit;
    audit.logOperation(userId, "更新角色",
                       success ? "成功" : "失败",
                       QString("更新角色 ID=%1").arg(role.roleId()),
                       "sys_role", role.roleId(),
                       "");
    return success;
}

bool RoleService::deleteRole(int roleId, const QString& operatorUser)
{
    auto roleRepo = RepositoryFactory::createRoleRepository();
    auto role = roleRepo->findById(roleId);
    if (!role) {
        int userId = getUserIdByUserName(operatorUser);
        AuditLogService().logOperation(userId, "删除角色",
                                       "失败",
                                       QString("角色 ID=%1 不存在").arg(roleId),
                                       "sys_role", roleId,
                                       "");
        return false;
    }

    auto& dbMgr = DatabaseManager::instance();
    if (!dbMgr.beginTransaction()) {
        int userId = getUserIdByUserName(operatorUser);
        AuditLogService().logOperation(userId, "删除角色",
                                       "失败",
                                       QString("开启事务失败，无法删除角色 %1").arg(role->roleName()),
                                       "sys_role", roleId,
                                       "");
        return false;
    }

    // 删除角色前，先删除其下所有权限
    auto permRepo = RepositoryFactory::createPermissionRepository();
    bool permDeleted = permRepo->deleteByRoleId(roleId);
    if (!permDeleted) {
        dbMgr.rollbackTransaction();
        int userId = getUserIdByUserName(operatorUser);
        AuditLogService().logOperation(userId, "删除角色",
                                       "失败",
                                       QString("删除角色 %1 的权限失败，已回滚").arg(role->roleName()),
                                       "sys_role", roleId,
                                       "");
        return false;
    }

    bool success = roleRepo->deleteById(roleId);
    int userId = getUserIdByUserName(operatorUser);
    if (success) {
        dbMgr.commitTransaction();
        AuditLogService().logOperation(userId, "删除角色",
                                       "成功",
                                       QString("删除角色 %1").arg(role->roleName()),
                                       "sys_role", roleId,
                                       "");
        return true;
    } else {
        dbMgr.rollbackTransaction();
        AuditLogService().logOperation(userId, "删除角色",
                                       "失败",
                                       QString("删除角色 %1 失败，已回滚").arg(role->roleName()),
                                       "sys_role", roleId,
                                       "");
        return false;
    }
}

std::optional<Role> RoleService::getRoleById(int roleId) const
{
    auto roleRepo = RepositoryFactory::createRoleRepository();
    return roleRepo->findById(roleId);
}

QList<Role> RoleService::getAllRoles() const
{
    auto roleRepo = RepositoryFactory::createRoleRepository();
    return roleRepo->findAll();
}

// ---------- 私有辅助函数 ----------
int RoleService::getUserIdByUserName(const QString& userName) const
{
    if (userName.isEmpty()) return 0;
    UserService userSvc;
    auto user = userSvc.getUserByName(userName);
    if (user) {
        return user->userId();
    }
    return 0;  // 未找到时返回 0（系统或未知用户）
}