#ifndef SQLITEPROJECTCONFIGREPOSITORY_H
#define SQLITEPROJECTCONFIGREPOSITORY_H

// repositories/sqlite_projectconfig_repository.h
#pragma once
#include "interfaces/IProjectConfigRepository.h"
#include "sqliteplaylistrepository.h"     // 为了级联删除时需要用到其他repo
#include "sqliteprograminforepository.h"
#include "sqlitewindowviewrepository.h"
#include "sqlitemediasourcerepository.h"

namespace Repository {

class SqliteProjectConfigRepository : public IProjectConfigRepository {
public:
    bool insert(const LEDDB::ProjectConfig& project) override;
    bool update(const LEDDB::ProjectConfig& project) override;
    bool deleteById(int projectId) override;
    bool cascadeDeleteById(int projectId) override;
    std::optional<LEDDB::ProjectConfig> findById(int projectId) override;
    QList<LEDDB::ProjectConfig> findByValid(int isValid = 1) override;
    QList<LEDDB::ProjectConfig> findAll() override;
};

} // namespace Repository

#endif // SQLITEPROJECTCONFIGREPOSITORY_H
