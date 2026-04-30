// core/auth/AuthenticatorFactory.cpp
#include "AuthenticatorFactory.h"
#include "PasswordAuthenticator.h"

std::unique_ptr<IAuthenticator> AuthenticatorFactory::create(AuthType type)
{
    switch (type) {
    case AuthType::Password:
        return std::make_unique<PasswordAuthenticator>();
    // 其他类型后续扩展
    default:
        return nullptr;
    }
}