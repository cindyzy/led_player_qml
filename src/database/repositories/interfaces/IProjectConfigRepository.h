#ifndef IPROJECTCONFIGREPOSITORY_H
#define IPROJECTCONFIGREPOSITORY_H

// repositories/interfaces/IProjectConfigRepository.h
#pragma once
#include "../../entities/projectconfig.h"
#include <optional>
#include <QList>

namespace Repository {

class IProjectConfigRepository {
public:
    virtual ~IProjectConfigRepository() = default;

    virtual bool insert(const LEDDB::ProjectConfig& project) = 0;
    virtual bool update(const LEDDB::ProjectConfig& project) = 0;
    virtual bool deleteById(int projectId) = 0;
    virtual bool cascadeDeleteById(int projectId) = 0;   // 级联删除项目及下属所有内容
    virtual std::optional<LEDDB::ProjectConfig> findById(int projectId) = 0;
    virtual QList<LEDDB::ProjectConfig> findByValid(int isValid = 1) = 0;
    virtual QList<LEDDB::ProjectConfig> findAll() = 0;
};

} // namespace Repository

#endif // IPROJECTCONFIGREPOSITORY_H
