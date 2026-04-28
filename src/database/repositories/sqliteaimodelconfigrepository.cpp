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
        INSERT INTO ai_model_config (model_name, api_url, api_key, timeout,
        offline_strategy, enable_status)
        VALUES (?, ?, ?, ?, ?, ?)
    )");
    query.addBindValue(config.modelName());
    query.addBindValue(config.apiUrl());
    query.addBindValue(CryptoHelper::aesEncrypt(config.apiKey()));
    query.addBindValue(config.timeout());
    query.addBindValue(config.offlineStrategy());
    query.addBindValue(config.enableStatus());
    return query.exec();
}

bool SqliteAiModelConfigRepository::update(const LEDDB::AiModelConfig& config) {
    QSqlQuery query(DatabaseManager::instance().getDatabase());
    query.prepare(R"(
        UPDATE ai_model_config SET model_name=?, api_url=?, api_key=?,
        timeout=?, offline_strategy=?, enable_status=?
        WHERE model_id=?
    )");
    query.addBindValue(config.modelName());
    query.addBindValue(config.apiUrl());
    query.addBindValue(CryptoHelper::aesEncrypt(config.apiKey()));
    query.addBindValue(config.timeout());
    query.addBindValue(config.offlineStrategy());
    query.addBindValue(config.enableStatus());
    query.addBindValue(config.modelId());
    return query.exec();
}

bool SqliteAiModelConfigRepository::deleteById(int modelId) {
    QSqlQuery query(DatabaseManager::instance().getDatabase());
    query.prepare("DELETE FROM ai_model_config WHERE model_id = ?");
    query.addBindValue(modelId);
    return query.exec();
}

std::optional<LEDDB::AiModelConfig> SqliteAiModelConfigRepository::findById(int modelId) {
    QSqlQuery query(DatabaseManager::instance().getDatabase());
    query.prepare("SELECT * FROM ai_model_config WHERE model_id = ?");
    query.addBindValue(modelId);
    if (!query.exec() || !query.next()) return std::nullopt;
    auto config = LEDDB::AiModelConfig::fromSqlRecord(query.record());
    // apiKey 返回密文，上层如需明文自行调用 CryptoHelper::decrypt()
    return config;
}

QList<LEDDB::AiModelConfig> SqliteAiModelConfigRepository::findAllEnabled() {
    QList<LEDDB::AiModelConfig> list;
    QSqlQuery query(DatabaseManager::instance().getDatabase());
    query.prepare("SELECT * FROM ai_model_config WHERE enable_status = 1");
    if (!query.exec()) return list;
    while (query.next()) list.append(LEDDB::AiModelConfig::fromSqlRecord(query.record()));
    return list;
}

QList<LEDDB::AiModelConfig> SqliteAiModelConfigRepository::findAll() {
    QList<LEDDB::AiModelConfig> list;
    QSqlQuery query("SELECT * FROM ai_model_config", DatabaseManager::instance().getDatabase());
    while (query.next()) list.append(LEDDB::AiModelConfig::fromSqlRecord(query.record()));
    return list;
}