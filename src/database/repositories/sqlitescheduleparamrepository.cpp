#include "sqlitescheduleparamrepository.h"
// repositories/sqlite_scheduleparam_repository.cpp
// #include "sqlite_scheduleparam_repository.h"
#include "../databasemanager.h"
#include <QSqlQuery>

using namespace Repository;

bool SqliteScheduleParamRepository::insert(const LEDDB::ScheduleParam& param) {
    QSqlQuery query(DatabaseManager::instance().getDatabase());
    query.prepare(R"(
        INSERT INTO schedule_param (scene_type, scene_threshold, predict_cycle,
        env_weight, scene_weight, brightness_min, brightness_max, strategy_json)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?)
    )");
    query.addBindValue(param.sceneType());
    query.addBindValue(param.sceneThreshold());
    query.addBindValue(param.predictCycle());
    query.addBindValue(param.envWeight());
    query.addBindValue(param.sceneWeight());
    query.addBindValue(param.brightnessMin());
    query.addBindValue(param.brightnessMax());
    query.addBindValue(param.strategyJson());
    return query.exec();
}

bool SqliteScheduleParamRepository::update(const LEDDB::ScheduleParam& param) {
    QSqlQuery query(DatabaseManager::instance().getDatabase());
    query.prepare(R"(
        UPDATE schedule_param SET scene_type=?, scene_threshold=?, predict_cycle=?,
        env_weight=?, scene_weight=?, brightness_min=?, brightness_max=?, strategy_json=?
        WHERE schedule_id=?
    )");
    query.addBindValue(param.sceneType());
    query.addBindValue(param.sceneThreshold());
    query.addBindValue(param.predictCycle());
    query.addBindValue(param.envWeight());
    query.addBindValue(param.sceneWeight());
    query.addBindValue(param.brightnessMin());
    query.addBindValue(param.brightnessMax());
    query.addBindValue(param.strategyJson());
    query.addBindValue(param.scheduleId());
    return query.exec();
}

bool SqliteScheduleParamRepository::deleteById(int scheduleId) {
    QSqlQuery query(DatabaseManager::instance().getDatabase());
    query.prepare("DELETE FROM schedule_param WHERE schedule_id = ?");
    query.addBindValue(scheduleId);
    return query.exec();
}

std::optional<LEDDB::ScheduleParam> SqliteScheduleParamRepository::findById(int scheduleId) {
    QSqlQuery query(DatabaseManager::instance().getDatabase());
    query.prepare("SELECT * FROM schedule_param WHERE schedule_id = ?");
    query.addBindValue(scheduleId);
    if (!query.exec() || !query.next()) return std::nullopt;
    return LEDDB::ScheduleParam::fromSqlRecord(query.record());
}

std::optional<LEDDB::ScheduleParam> SqliteScheduleParamRepository::findBySceneType(const QString& sceneType) {
    QSqlQuery query(DatabaseManager::instance().getDatabase());
    query.prepare("SELECT * FROM schedule_param WHERE scene_type = ?");
    query.addBindValue(sceneType);
    if (!query.exec() || !query.next()) return std::nullopt;
    return LEDDB::ScheduleParam::fromSqlRecord(query.record());
}

QList<LEDDB::ScheduleParam> SqliteScheduleParamRepository::findAll() {
    QList<LEDDB::ScheduleParam> list;
    QSqlQuery query("SELECT * FROM schedule_param", DatabaseManager::instance().getDatabase());
    while (query.next()) list.append(LEDDB::ScheduleParam::fromSqlRecord(query.record()));
    return list;
}