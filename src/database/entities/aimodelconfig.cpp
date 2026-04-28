
// entities/aimodelconfig.cpp
#include "aimodelconfig.h"
#include <QSqlRecord>

namespace LEDDB {

AiModelConfig::AiModelConfig(int modelId, const QString& modelName, const QString& apiUrl,
                             const QString& apiKey, int timeout, const QString& offlineStrategy,
                             int enableStatus)
    : m_modelId(modelId), m_modelName(modelName), m_apiUrl(apiUrl), m_apiKey(apiKey),
    m_timeout(timeout), m_offlineStrategy(offlineStrategy), m_enableStatus(enableStatus) {}

AiModelConfig AiModelConfig::fromSqlRecord(const QSqlRecord& rec)
{
    AiModelConfig amc;
    amc.setModelId(rec.value("model_id").toInt());
    amc.setModelName(rec.value("model_name").toString());
    amc.setApiUrl(rec.value("api_url").toString());
    amc.setApiKey(rec.value("api_key").toString());
    amc.setTimeout(rec.value("timeout").toInt());
    amc.setOfflineStrategy(rec.value("offline_strategy").toString());
    amc.setEnableStatus(rec.value("enable_status").toInt());
    return amc;
}

} // namespace LEDDB