#include "userservice.h"

#include "../repositories/RepositoryFactory.h"
#include "../../utils/cryptohelper.h"
#include "../../utils/datetimehelper.h"
#include "AuditLogService.h"
#include <QDateTime>
#include <QDebug>

using namespace Repository;
using namespace LEDDB;

UserService::UserService() = default;

// 辅助方法：通过用户名获取用户ID，找不到时返回0并记录警告
int UserService::getUserIdByUserName(const QString& userName) {
    if (userName.isEmpty()) return 0;
    auto userRepo = RepositoryFactory::createUserRepository();
    auto user = userRepo->findByUserName(userName);
    if (!user) {
        qWarning() << "UserService: cannot find user ID for userName:" << userName;
        return 0;
    }
    return user->userId();
}

// 记录用户操作日志（只接受 int operatorUserId，避免重载歧义）
void UserService::logUserOperation(int operatorUserId, const QString& operationType,
                                   const QString& operationDesc, bool success,
                                   const QString& targetTable, int targetId) {
    AuditLogService audit;
    audit.logOperation(operatorUserId, operationType, success ? "成功" : "失败",
                       operationDesc, targetTable, targetId, QString());
}

bool UserService::createUser(const User& user, const QString& operatorUser) {
    auto userRepo = RepositoryFactory::createUserRepository();

    if (userRepo->exists(user.userName())) {
        logUserOperation(getUserIdByUserName(operatorUser), "创建用户",
                         QString("用户已存在: %1").arg(user.userName()), false,
                         "sys_user", 0);
        return false;
    }

    User newUser = user;
    newUser.setCreateTime(QDateTime::currentDateTime());
    newUser.setLastLoginTime(QDateTime::currentDateTime());
    bool success = userRepo->insert(newUser);

    int targetId = success ? newUser.userId() : 0;
    logUserOperation(getUserIdByUserName(operatorUser), "创建用户",
                     QString("创建用户 %1").arg(user.userName()), success,
                     "sys_user", targetId);
    return success;
}

bool UserService::updateUser(const User& user, const QString& operatorUser) {
    auto userRepo = RepositoryFactory::createUserRepository();
    User updated = user;
    updated.setUpdateTime(QDateTime::currentDateTime());
    bool success = userRepo->update(updated);

    logUserOperation(getUserIdByUserName(operatorUser), "更新用户",
                     QString("更新用户 ID=%1").arg(user.userId()), success,
                     "sys_user", user.userId());
    return success;
}

bool UserService::deleteUser(int userId, const QString& operatorUser) {
    auto userRepo = RepositoryFactory::createUserRepository();
    auto user = userRepo->findById(userId);
    if (!user) {
        qWarning() << "UserService: deleteUser called with non-existent userId =" << userId;
        return false;
    }

    bool success = userRepo->deleteById(userId);
    logUserOperation(getUserIdByUserName(operatorUser), "删除用户",
                     QString("删除用户 %1").arg(user->userName()), success,
                     "sys_user", userId);
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

    int operatorId = success ? getUserIdByUserName(userName) : 0;
    logUserOperation(operatorId, "登录认证",
                     QString("用户 %1 登录").arg(userName), success,
                     QString(), 0);
    return success;
}

bool UserService::changePassword(int userId, const QString& oldPassword,
                                 const QString& newPassword, const QString& operatorUser) {
    auto userRepo = RepositoryFactory::createUserRepository();
    auto user = userRepo->findById(userId);
    if (!user) {
        qWarning() << "UserService: changePassword called with non-existent userId =" << userId;
        return false;
    }

    if (!userRepo->authenticate(user->userName(), oldPassword)) {
        logUserOperation(getUserIdByUserName(operatorUser), "修改密码",
                         QString("用户 %1 旧密码错误").arg(user->userName()), false,
                         "sys_user", userId);
        return false;
    }

    User updated = *user;
    updated.setPassword(newPassword);
    updated.setLastLoginTime(QDateTime::currentDateTime());
    updated.setUpdateTime(QDateTime::currentDateTime());
    bool success = userRepo->update(updated);

    logUserOperation(getUserIdByUserName(operatorUser), "修改密码",
                     QString("修改用户 %1 密码").arg(user->userName()), success,
                     "sys_user", userId);
    return success;
}