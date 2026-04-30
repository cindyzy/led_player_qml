// core/auth/IAuthenticator.h
#ifndef IAUTHENTICATOR_H
#define IAUTHENTICATOR_H

#include <QString>
#include <optional>

struct AuthResult {
    int userId;
    QString userName;
    int roleId;
    bool success;
    QString errorMessage;
};

class IAuthenticator {
public:
    virtual ~IAuthenticator() = default;
    virtual AuthResult authenticate(const QString& username, const QString& password) = 0;
};

#endif // IAUTHENTICATOR_H