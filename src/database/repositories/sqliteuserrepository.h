#ifndef SQLITEUSERREPOSITORY_H
#define SQLITEUSERREPOSITORY_H

// repositories/sqlite_user_repository.h
#pragma once
#include "interfaces/IUserRepository.h"

namespace Repository {

class SqliteUserRepository : public IUserRepository {
public:
    bool insert(const LEDDB::User& user) override;
    bool update(const LEDDB::User& user) override;
    bool deleteById(int userId) override;
    std::optional<LEDDB::User> findById(int userId) override;
    std::optional<LEDDB::User> findByUserName(const QString& userName) override;
    QList<LEDDB::User> findAll(int offset = 0, int limit = 100) override;
    bool authenticate(const QString& userName, const QString& plainPassword) override;
    bool exists(const QString& userName) override;
};

} // namespace Repository

#endif // SQLITEUSERREPOSITORY_H
