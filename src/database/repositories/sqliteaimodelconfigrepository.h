#ifndef SQLITEAIMODELCONFIGREPOSITORY_H
#define SQLITEAIMODELCONFIGREPOSITORY_H

// repositories/sqlite_aimodelconfig_repository.h
#pragma once
#include "interfaces/IAiModelConfigRepository.h"

namespace Repository {

class SqliteAiModelConfigRepository : public IAiModelConfigRepository {
public:
    bool insert(const LEDDB::AiModelConfig& config) override;
    bool update(const LEDDB::AiModelConfig& config) override;
    bool deleteById(int configId) override;
    std::optional<LEDDB::AiModelConfig> findById(int configId) override;
    QList<LEDDB::AiModelConfig> findAllEnabled() override;
    QList<LEDDB::AiModelConfig> findAll() override;
};

} // namespace Repository
#endif // SQLITEAIMODELCONFIGREPOSITORY_H
