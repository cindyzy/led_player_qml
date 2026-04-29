
// entities/aimodelconfig.cpp
#include "aimodelconfig.h"
#include <QSqlRecord>
#include "../../utils/datetimehelper.h"


namespace LEDDB {

AiModelConfig::AiModelConfig(int configId, const QString& modelName, const QString& apiUrl,
                             const QString& apiKey, int timeout, const QString& offlineStrategy,
                             const QString& modelPath, const QString& apiEndpoint,
                             const QString& modelParams, int enableStatus,
                             const QDateTime& createTime, const QDateTime& updateTime)
    : m_configId(configId)
    , m_modelName(modelName)
    , m_apiUrl(apiUrl)
    , m_apiKey(apiKey)
    , m_timeout(timeout)
    , m_offlineStrategy(offlineStrategy)
    , m_modelPath(modelPath)
    , m_apiEndpoint(apiEndpoint)
    , m_modelParams(modelParams)
    , m_enableStatus(enableStatus)
    , m_createTime(createTime)
    , m_updateTime(updateTime)
{
}


AiModelConfig AiModelConfig::fromSqlRecord(const QSqlRecord& record)
{
    AiModelConfig config;
    config.setConfigId(record.value("config_id").toInt());
    config.setModelName(record.value("model_name").toString());
    config.setApiUrl(record.value("api_url").toString());
    config.setApiKey(record.value("api_key").toString());
    config.setTimeout(record.value("timeout").toInt());
    config.setOfflineStrategy(record.value("offline_strategy").toString());
    config.setModelPath(record.value("model_path").toString());
    config.setApiEndpoint(record.value("api_endpoint").toString());
    config.setModelParams(record.value("model_params").toString());
    config.setEnableStatus(record.value("enable_status").toInt());
    config.setCreateTime(fromIsoString(record.value("create_time").toString()));
    config.setUpdateTime(fromIsoString(record.value("update_time").toString()));
    return config;
}

} // namespace LEDDB