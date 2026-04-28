#ifndef AIMODELCONFIGSERVICE_H
#define AIMODELCONFIGSERVICE_H

// services/AiModelConfigService.h
#pragma once
#include "../entities/aimodelconfig.h"
#include <optional>
#include <QList>

class AiModelConfigService {
public:
    AiModelConfigService();

    bool addModelConfig(const LEDDB::AiModelConfig& config, const QString& operatorUser);
    bool updateModelConfig(const LEDDB::AiModelConfig& config, const QString& operatorUser);
    bool removeModelConfig(int modelId, const QString& operatorUser);
    std::optional<LEDDB::AiModelConfig> getModelConfig(int modelId);
    QList<LEDDB::AiModelConfig> getEnabledModels();
    QList<LEDDB::AiModelConfig> getAllModels();
};

#endif // AIMODELCONFIGSERVICE_H
