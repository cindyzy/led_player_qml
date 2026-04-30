// core/auth/AuthenticatorFactory.h
#ifndef AUTHENTICATORFACTORY_H
#define AUTHENTICATORFACTORY_H

#include <memory>
#include "IAuthenticator.h"

enum class AuthType {
    Password,
    Ldap,
    OAuth2
};

class AuthenticatorFactory {
public:
    static std::unique_ptr<IAuthenticator> create(AuthType type);
};

#endif // AUTHENTICATORFACTORY_H