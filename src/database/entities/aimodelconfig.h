#ifndef AIMODELCONFIG_H
#define AIMODELCONFIG_H

// entities/aimodelconfig.h
#pragma once
#include <QString>
#include <QSqlRecord>
#include <QDateTime>
namespace LEDDB {

class AiModelConfig {
public:
    AiModelConfig() = default;
    AiModelConfig(int modelId, const QString& modelName, const QString& apiUrl,
                  const QString& apiKey, int timeout, const QString& offlineStrategy,
                  const QString& modelPath, const QString& apiEndpoint,
                  const QString& modelParams, int enableStatus,
                  const QDateTime& createTime, const QDateTime& updateTime);


    // ---------- getters ----------
    int configId() const { return m_configId; }
    QString modelName() const { return m_modelName; }
    QString apiUrl() const { return m_apiUrl; }
    QString apiKey() const { return m_apiKey; }          // AES加密存储
    int timeout() const { return m_timeout; }
    QString offlineStrategy() const { return m_offlineStrategy; }
    QString modelPath() const { return m_modelPath; }
    QString apiEndpoint() const { return m_apiEndpoint; }
    QString modelParams() const { return m_modelParams; }
    int enableStatus() const { return m_enableStatus; }   // 0关闭, 1启用
    QDateTime createTime() const { return m_createTime; }
    QDateTime updateTime() const { return m_updateTime; }

    // ---------- setters ----------
    void setConfigId(int id) { m_configId = id; }
    void setModelName(const QString& name) { m_modelName = name; }
    void setApiUrl(const QString& url) { m_apiUrl = url; }
    void setApiKey(const QString& key) { m_apiKey = key; }
    void setTimeout(int ms) { m_timeout = ms; }
    void setOfflineStrategy(const QString& strategy) { m_offlineStrategy = strategy; }
    void setModelPath(const QString& path) { m_modelPath = path; }
    void setApiEndpoint(const QString& endpoint) { m_apiEndpoint = endpoint; }
    void setModelParams(const QString& params) { m_modelParams = params; }
    void setEnableStatus(int status) { m_enableStatus = status; }
    void setCreateTime(const QDateTime& dt) { m_createTime = dt; }
    void setUpdateTime(const QDateTime& dt) { m_updateTime = dt; }
    static AiModelConfig fromSqlRecord(const QSqlRecord& record);

private:
    int m_configId = 0;                 // 配置唯一ID（主键）
    QString m_modelName;                // 模型名称
    QString m_apiUrl;                   // API 基础地址（兼容旧字段）
    QString m_apiKey;                   // API 密钥（AES加密）
    int m_timeout = 10000;              // 超时毫秒
    QString m_offlineStrategy = "local";// 离线降级策略
    QString m_modelPath;                // 本地模型文件路径（或下载地址）
    QString m_apiEndpoint;              // 具体的 API 端点（如 /v1/chat）
    QString m_modelParams;              // 模型参数 JSON（如温度、最大 token 等）
    int m_enableStatus = 1;             // 启用状态 0-关闭,1-启用
    QDateTime m_createTime;             // 创建时间
    QDateTime m_updateTime;             // 最后更新时间
};

} // namespace LEDDB

#endif // AIMODELCONFIG_H
