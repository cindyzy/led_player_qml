#ifndef SQLITEPERMISSIONREPOSITORY_H
#define SQLITEPERMISSIONREPOSITORY_H

// repositories/sqlite_permission_repository.h
#pragma once
#include "interfaces/IPermissionRepository.h"

namespace Repository {

class SqlitePermissionRepository : public IPermissionRepository {
public:
    bool insert(const LEDDB::Permission& perm) override;
    bool update(const LEDDB::Permission& perm) override;
    bool deleteById(int permId) override;
    bool deleteByRoleId(int roleId) override;
    QList<LEDDB::Permission> findByRoleId(int roleId) override;
};

} // namespace Repository
#endif // SQLITEPERMISSIONREPOSITORY_H
