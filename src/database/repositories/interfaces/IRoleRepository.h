#ifndef IROLEREPOSITORY_H
#define IROLEREPOSITORY_H

// repositories/interfaces/IRoleRepository.h
#pragma once
#include "../../entities/role.h"
#include <optional>
#include <QList>

namespace Repository {

class IRoleRepository {
public:
    virtual ~IRoleRepository() = default;

    virtual bool insert(const LEDDB::Role& role) = 0;
    virtual bool update(const LEDDB::Role& role) = 0;
    virtual bool deleteById(int roleId) = 0;
    virtual std::optional<LEDDB::Role> findById(int roleId) = 0;
    virtual std::optional<LEDDB::Role> findByName(const QString& roleName) = 0;
    virtual QList<LEDDB::Role> findAll() = 0;
};

} // namespace Repository

#endif // IROLEREPOSITORY_H