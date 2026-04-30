// core/auth/PasswordAuthenticator.cpp
#include "PasswordAuthenticator.h"
#include "../../database/services/UserService.h"

AuthResult PasswordAuthenticator::authenticate(const QString& username, const QString& password)
{
    UserService userSvc;
    AuthResult result;
    result.success = false;

    if (!userSvc.authenticate(username, password)) {
        result.errorMessage = "用户名或密码错误";
        return result;
    }

    auto user = userSvc.getUserByName(username);
    if (!user) {
        result.errorMessage = "用户不存在";
        return result;
    }

    if (user->status() != 1) {
        result.errorMessage = "账号已被禁用";
        return result;
    }

    result.success = true;
    result.userId = user->userId();
    result.userName = user->userName();
    result.roleId = user->roleId();
    return result;
}