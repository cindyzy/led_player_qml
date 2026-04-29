#ifndef USERSERVICE_H
#define USERSERVICE_H

// services/UserService.h
#pragma once
#include "../entities/user.h"
#include <optional>
#include <QList>

class UserService {
public:
    UserService();

    // 基本 CRUD
    bool createUser(const LEDDB::User& user, const QString& operatorUser);
    bool updateUser(const LEDDB::User& user, const QString& operatorUser);
    bool deleteUser(int userId, const QString& operatorUser);

    // 查询
    std::optional<LEDDB::User> getUserById(int userId);
    std::optional<LEDDB::User> getUserByName(const QString& userName);
    QList<LEDDB::User> getAllUsers(int offset = 0, int limit = 100);

    // 业务方法
    bool authenticate(const QString& userName, const QString& password);
    bool changePassword(int userId, const QString& oldPassword,
                        const QString& newPassword, const QString& operatorUser);

private:
    static int getUserIdByUserName(const QString& userName);
    static void logUserOperation(int operatorUserId, const QString& operationType,
                          const QString& operationDesc, bool success,
                          const QString& targetTable, int targetId);
};
#endif // USERSERVICE_H
