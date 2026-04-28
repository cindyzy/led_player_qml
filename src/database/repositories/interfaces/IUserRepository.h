// repositories/interfaces/IUserRepository.h
#pragma once
#include "../../entities/user.h"
#include <optional>
#include <QList>

namespace Repository {

class IUserRepository {
public:
    virtual ~IUserRepository() = default;

    virtual bool insert(const LEDDB::User& user) = 0;
    virtual bool update(const LEDDB::User& user) = 0;
    virtual bool deleteById(int userId) = 0;
    virtual std::optional<LEDDB::User> findById(int userId) = 0;
    virtual std::optional<LEDDB::User> findByUserName(const QString& userName) = 0;
    virtual QList<LEDDB::User> findAll(int offset = 0, int limit = 100) = 0;
    virtual bool authenticate(const QString& userName, const QString& plainPassword) = 0;
    virtual bool exists(const QString& userName) = 0;
};

} // namespace Repository