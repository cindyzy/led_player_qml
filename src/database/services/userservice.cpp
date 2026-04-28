#include "userservice.h"

// services/UserService.cpp

#include "../repositories/RepositoryFactory.h"
#include "../../utils/cryptohelper.h"
#include "../../utils/datetimehelper.h"
#include "AuditLogService.h"
#include <QDateTime>

using namespace Repository;
using namespace LEDDB;

UserService::UserService() = default;

bool UserService::createUser(const User& user, const QString& operatorUser) {
    auto userRepo = RepositoryFactory::createUserRepository();

    if (userRepo->exists(user.userName())) {
        logOperation(operatorUser, "创建用户", "用户已存在: " + user.userName(), false);
        return false;
    }

    User newUser = user;
    newUser.setCreateTime(QDateTime::currentDateTime());
    bool success = userRepo->insert(newUser);
    logOperation(operatorUser, "创建用户", QString("创建用户 %1").arg(user.userName()), success);
    return success;
}

bool UserService::updateUser(const User& user, const QString& operatorUser) {
    auto userRepo = RepositoryFactory::createUserRepository();
    bool success = userRepo->update(user);
    logOperation(operatorUser, "更新用户", QString("更新用户 ID=%1").arg(user.userId()), success);
    return success;
}

bool UserService::deleteUser(int userId, const QString& operatorUser) {
    auto userRepo = RepositoryFactory::createUserRepository();
    auto user = userRepo->findById(userId);
    if (!user) return false;
    bool success = userRepo->deleteById(userId);
    logOperation(operatorUser, "删除用户", QString("删除用户 %1").arg(user->userName()), success);
    return success;
}

std::optional<User> UserService::getUserById(int userId) {
    auto userRepo = RepositoryFactory::createUserRepository();
    return userRepo->findById(userId);
}

std::optional<User> UserService::getUserByName(const QString& userName) {
    auto userRepo = RepositoryFactory::createUserRepository();
    return userRepo->findByUserName(userName);
}

QList<User> UserService::getAllUsers(int offset, int limit) {
    auto userRepo = RepositoryFactory::createUserRepository();
    return userRepo->findAll(offset, limit);
}

bool UserService::authenticate(const QString& userName, const QString& password) {
    auto userRepo = RepositoryFactory::createUserRepository();
    bool success = userRepo->authenticate(userName, password);
    logOperation(userName, "登录认证", "用户登录", success);
    return success;
}

bool UserService::changePassword(int userId, const QString& oldPassword, const QString& newPassword, const QString& operatorUser) {
    auto userRepo = RepositoryFactory::createUserRepository();
    auto user = userRepo->findById(userId);
    if (!user) return false;

    if (!userRepo->authenticate(user->userName(), oldPassword)) {
        logOperation(operatorUser, "修改密码", QString("用户 %1 旧密码错误").arg(user->userName()), false);
        return false;
    }

    User updated = *user;
    updated.setPassword(newPassword);
    updated.setLastLoginTime(QDateTime::currentDateTime());
    bool success = userRepo->update(updated);
    logOperation(operatorUser, "修改密码", QString("修改用户 %1 密码").arg(user->userName()), success);
    return success;
}

void UserService::logOperation(const QString& operatorUser, const QString& type, const QString& content, bool success) {
    AuditLogService auditService;
    auditService.logOperation(operatorUser, type, content, success ? "成功" : "失败");
}