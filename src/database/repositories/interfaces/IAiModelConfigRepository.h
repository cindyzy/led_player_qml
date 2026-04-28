#ifndef IAIMODELCONFIGREPOSITORY_H
#define IAIMODELCONFIGREPOSITORY_H

// repositories/interfaces/IAiModelConfigRepository.h
#pragma once
#include "../../entities/aimodelconfig.h"
#include <optional>
#include <QList>

namespace Repository {

class IAiModelConfigRepository {
public:
    virtual ~IAiModelConfigRepository() = default;

    virtual bool insert(const LEDDB::AiModelConfig& config) = 0;
    virtual bool update(const LEDDB::AiModelConfig& config) = 0;
    virtual bool deleteById(int modelId) = 0;
    virtual std::optional<LEDDB::AiModelConfig> findById(int modelId) = 0;
    virtual QList<LEDDB::AiModelConfig> findAllEnabled() = 0;
    virtual QList<LEDDB::AiModelConfig> findAll() = 0;
};

} // namespace Repository

#endif // IAIMODELCONFIGREPOSITORY_H
