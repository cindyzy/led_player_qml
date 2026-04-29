#include "sqliteaimodelconfigrepository.h"

// repositories/sqlite_aimodelconfig_repository.cpp
// #include "sqlite_aimodelconfig_repository.h"
#include "../databasemanager.h"
#include "../../utils/cryptohelper.h"
#include <QSqlQuery>

using namespace Repository;

bool SqliteAiModelConfigRepository::insert(const LEDDB::AiModelConfig& config) {
    QSqlQuery query(DatabaseManager::instance().getDatabase());
    query.prepare(R"(
        INSERT INTO ai_model_config (
            model_name, api_url, api_key, timeout, offline_strategy,
            model_path, api_endpoint, model_params, enable_status,
            create_time, update_time
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    )");
    query.addBindValue(config.modelName());
    query.addBindValue(config.apiUrl());
    query.addBindValue(CryptoHelper::aesEncrypt(config.apiKey()));
    query.addBindValue(config.timeout());
    query.addBindValue(config.offlineStrategy());
    query.addBindValue(config.modelPath());
    query.addBindValue(config.apiEndpoint());
    query.addBindValue(config.modelParams());
    query.addBindValue(config.enableStatus());
    query.addBindValue(config.timeout());
    query.addBindValue(config.timeout());

    return query.exec();
}

bool SqliteAiModelConfigRepository::update(const LEDDB::AiModelConfig& config) {
    QSqlQuery query(DatabaseManager::instance().getDatabase());
    query.prepare(R"(
        UPDATE ai_model_config SET
            model_name = ?, api_url = ?, api_key = ?, timeout = ?,
            offline_strategy = ?, model_path = ?, api_endpoint = ?,
            model_params = ?, enable_status = ?, update_time = ?
        WHERE config_id = ?
    )");
    query.addBindValue(config.modelName());
    query.addBindValue(config.apiUrl());
    query.addBindValue(CryptoHelper::aesEncrypt(config.apiKey()));
    query.addBindValue(config.timeout());
    query.addBindValue(config.offlineStrategy());
    query.addBindValue(config.modelPath());
    query.addBindValue(config.apiEndpoint());
    query.addBindValue(config.modelParams());
    query.addBindValue(config.enableStatus());
    query.addBindValue(config.timeout());
    query.addBindValue(config.configId());   // 使用 configId 作为主键

    if (!query.exec()) {
        qCritical() << "update AiModelConfig failed:" << query.lastError().text();
        return false;
    }
    return query.exec();
}

bool SqliteAiModelConfigRepository::deleteById(int configId) {
    QSqlQuery query(DatabaseManager::instance().getDatabase());
    query.prepare("DELETE FROM ai_model_config WHERE config_id = ?");
    query.addBindValue(configId);
    if (!query.exec()) {
        qCritical() << "delete AiModelConfig failed:" << query.lastError().text();
        return false;
    }
    return true;
}

std::optional<LEDDB::AiModelConfig> SqliteAiModelConfigRepository::findById(int configId) {
    QSqlQuery query(DatabaseManager::instance().getDatabase());
    query.prepare("SELECT * FROM ai_model_config WHERE config_id = ?");
    query.addBindValue(configId);
    if (!query.exec() || !query.next()) {
        return std::nullopt;
    }
    auto config = LEDDB::AiModelConfig::fromSqlRecord(query.record());
    // apiKey 返回密文，上层如需明文自行调用 CryptoHelper::decrypt()
    return config;
}

QList<LEDDB::AiModelConfig> SqliteAiModelConfigRepository::findAllEnabled() {
    QList<LEDDB::AiModelConfig> list;
    QSqlQuery query(DatabaseManager::instance().getDatabase());
    query.prepare("SELECT * FROM ai_model_config WHERE enable_status = 1 ORDER BY model_name");
    if (!query.exec()) {
        qCritical() << "findAllEnabled failed:" << query.lastError().text();
        return list;
    }
    while (query.next()) {
        list.append(LEDDB::AiModelConfig::fromSqlRecord(query.record()));
    }
    return list;
}

QList<LEDDB::AiModelConfig> SqliteAiModelConfigRepository::findAll() {
    QList<LEDDB::AiModelConfig> list;
    QSqlQuery query(DatabaseManager::instance().getDatabase());
    query.prepare("SELECT * FROM ai_model_config ORDER BY config_id");
    if (!query.exec()) {
        qCritical() << "findAll failed:" << query.lastError().text();
        return list;
    }
    while (query.next()) {
        list.append(LEDDB::AiModelConfig::fromSqlRecord(query.record()));
    }
    return list;
}