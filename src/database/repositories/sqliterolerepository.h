#ifndef SQLITEROLEREPOSITORY_H
#define SQLITEROLEREPOSITORY_H

// repositories/sqlite_role_repository.h
#pragma once
#include "interfaces/IRoleRepository.h"

namespace Repository {

class SqliteRoleRepository : public IRoleRepository {
public:
    bool insert(const LEDDB::Role& role) override;
    bool update(const LEDDB::Role& role) override;
    bool deleteById(int roleId) override;
    std::optional<LEDDB::Role> findById(int roleId) override;
    std::optional<LEDDB::Role> findByName(const QString& roleName) override;
    QList<LEDDB::Role> findAll() override;
};

} // namespace Repository
#endif // SQLITEROLEREPOSITORY_H