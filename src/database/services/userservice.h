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

    // 业务方法
    bool createUser(const LEDDB::User& user, const QString& operatorUser);
    bool updateUser(const LEDDB::User& user, const QString& operatorUser);
    bool deleteUser(int userId, const QString& operatorUser);
    std::optional<LEDDB::User> getUserById(int userId);
    std::optional<LEDDB::User> getUserByName(const QString& userName);
    QList<LEDDB::User> getAllUsers(int offset = 0, int limit = 100);
    bool authenticate(const QString& userName, const QString& password);
    bool changePassword(int userId, const QString& oldPassword, const QString& newPassword, const QString& operatorUser);

private:
    void logOperation(const QString& operatorUser, const QString& type, const QString& content, bool success);
};
#endif // USERSERVICE_H
