#ifndef AIMODELCONFIG_H
#define AIMODELCONFIG_H

// entities/aimodelconfig.h
#pragma once
#include <QString>
#include <QSqlRecord>
namespace LEDDB {

class AiModelConfig {
public:
    AiModelConfig() = default;
    AiModelConfig(int modelId, const QString& modelName, const QString& apiUrl,
                  const QString& apiKey, int timeout, const QString& offlineStrategy,
                  int enableStatus);

    int modelId() const { return m_modelId; }
    void setModelId(int id) { m_modelId = id; }

    QString modelName() const { return m_modelName; }
    void setModelName(const QString& name) { m_modelName = name; }

    QString apiUrl() const { return m_apiUrl; }
    void setApiUrl(const QString& url) { m_apiUrl = url; }

    QString apiKey() const { return m_apiKey; }      // AES加密存储
    void setApiKey(const QString& key) { m_apiKey = key; }

    int timeout() const { return m_timeout; }
    void setTimeout(int ms) { m_timeout = ms; }

    QString offlineStrategy() const { return m_offlineStrategy; }
    void setOfflineStrategy(const QString& strategy) { m_offlineStrategy = strategy; }

    int enableStatus() const { return m_enableStatus; }
    void setEnableStatus(int status) { m_enableStatus = status; }  // 0关闭 1启用

    static AiModelConfig fromSqlRecord(const QSqlRecord& record);

private:
    int m_modelId = 0;
    QString m_modelName;
    QString m_apiUrl;
    QString m_apiKey;
    int m_timeout = 10000;
    QString m_offlineStrategy = "local";
    int m_enableStatus = 1;
};

} // namespace LEDDB

#endif // AIMODELCONFIG_H
