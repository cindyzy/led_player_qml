#ifndef IPERMISSIONREPOSITORY_H
#define IPERMISSIONREPOSITORY_H

// repositories/interfaces/IPermissionRepository.h
#pragma once
#include "../../entities/permission.h"
#include <QList>

namespace Repository {

class IPermissionRepository {
public:
    virtual ~IPermissionRepository() = default;

    virtual bool insert(const LEDDB::Permission& perm) = 0;
    virtual bool update(const LEDDB::Permission& perm) = 0;
    virtual bool deleteById(int permId) = 0;
    virtual bool deleteByRoleId(int roleId) = 0;   // 级联删除角色下所有权限
    virtual QList<LEDDB::Permission> findByRoleId(int roleId) = 0;
};

} // namespace Repository
#endif // IPERMISSIONREPOSITORY_H
