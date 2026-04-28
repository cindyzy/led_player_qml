#include "aimodelconfigservice.h"

// services/AiModelConfigService.cpp
// #include "AiModelConfigService.h"
#include "../repositories/RepositoryFactory.h"
#include "../../utils/cryptohelper.h"
#include "AuditLogService.h"

using namespace Repository;
using namespace LEDDB;

AiModelConfigService::AiModelConfigService() = default;

bool AiModelConfigService::addModelConfig(const AiModelConfig& config, const QString& operatorUser) {
    auto aiRepo = RepositoryFactory::createAiModelConfigRepository();
    bool success = aiRepo->insert(config);
    AuditLogService().logOperation(operatorUser, "添加AI模型",
                                   QString("添加模型 %1").arg(config.modelName()), success ? "成功" : "失败");
    return success;
}

bool AiModelConfigService::updateModelConfig(const AiModelConfig& config, const QString& operatorUser) {
    auto aiRepo = RepositoryFactory::createAiModelConfigRepository();
    bool success = aiRepo->update(config);
    AuditLogService().logOperation(operatorUser, "更新AI模型",
                                   QString("更新模型 %1").arg(config.modelName()), success ? "成功" : "失败");
    return success;
}

bool AiModelConfigService::removeModelConfig(int modelId, const QString& operatorUser) {
    auto aiRepo = RepositoryFactory::createAiModelConfigRepository();
    auto config = aiRepo->findById(modelId);
    if (!config) return false;
    bool success = aiRepo->deleteById(modelId);
    AuditLogService().logOperation(operatorUser, "删除AI模型",
                                   QString("删除模型 %1").arg(config->modelName()), success ? "成功" : "失败");
    return success;
}

std::optional<AiModelConfig> AiModelConfigService::getModelConfig(int modelId) {
    auto aiRepo = RepositoryFactory::createAiModelConfigRepository();
    auto config = aiRepo->findById(modelId);
    // 注意：apiKey字段仍是密文，业务层如需明文需调用 CryptoHelper::decrypt()
    return config;
}

QList<AiModelConfig> AiModelConfigService::getEnabledModels() {
    auto aiRepo = RepositoryFactory::createAiModelConfigRepository();
    return aiRepo->findAllEnabled();
}

QList<AiModelConfig> AiModelConfigService::getAllModels() {
    auto aiRepo = RepositoryFactory::createAiModelConfigRepository();
    return aiRepo->findAll();
}