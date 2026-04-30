// core/auth/PasswordAuthenticator.h
#ifndef PASSWORDAUTHENTICATOR_H
#define PASSWORDAUTHENTICATOR_H

#include "IAuthenticator.h"

class PasswordAuthenticator : public IAuthenticator {
public:
    AuthResult authenticate(const QString& username, const QString& password) override;
};

#endif // PASSWORDAUTHENTICATOR_H