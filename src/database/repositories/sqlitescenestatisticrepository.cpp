#include "sqlitescenestatisticrepository.h"

// repositories/sqlite_scenestatistic_repository.cpp
// #include "sqlite_scenestatistic_repository.h"
#include "../databasemanager.h"
#include "../../utils/datetimehelper.h"
#include <QSqlQuery>

using namespace Repository;

bool SqliteSceneStatisticRepository::insert(const LEDDB::SceneStatistic& stat) {
    QSqlQuery query(DatabaseManager::instance().getDatabase());
    query.prepare(R"(
        INSERT INTO scene_statistics (project_id, scene_type, collect_time, env_brightness,
        scene_status, schedule_result, play_count, total_duration, stat_date, create_time, update_time)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    )");
    query.addBindValue(stat.projectId());
    query.addBindValue(stat.sceneType());
    query.addBindValue(toIsoString(stat.collectTime()));
    query.addBindValue(stat.envBrightness());
    query.addBindValue(stat.sceneStatus());
    query.addBindValue(stat.scheduleResult());
    query.addBindValue(stat.playCount());
    query.addBindValue(stat.totalDuration());
    query.addBindValue(stat.statDate().toString(Qt::ISODate));
    query.addBindValue(toIsoString(stat.createTime()));
    query.addBindValue(toIsoString(stat.updateTime()));
    return query.exec();
}

bool SqliteSceneStatisticRepository::update(const LEDDB::SceneStatistic& stat) {
    QSqlQuery query(DatabaseManager::instance().getDatabase());
    query.prepare(R"(
        UPDATE scene_statistics SET project_id=?, scene_type=?, collect_time=?,
        env_brightness=?, scene_status=?, schedule_result=?, play_count=?,
        total_duration=?, stat_date=?, update_time=? WHERE stat_id=?
    )");
    query.addBindValue(stat.projectId());
    query.addBindValue(stat.sceneType());
    query.addBindValue(toIsoString(stat.collectTime()));
    query.addBindValue(stat.envBrightness());
    query.addBindValue(stat.sceneStatus());
    query.addBindValue(stat.scheduleResult());
    query.addBindValue(stat.playCount());
    query.addBindValue(stat.totalDuration());
    query.addBindValue(stat.statDate().toString(Qt::ISODate));
    query.addBindValue(toIsoString(stat.updateTime()));
    query.addBindValue(stat.statId());
    return query.exec();
}

bool SqliteSceneStatisticRepository::deleteById(int statId) {
    QSqlQuery query(DatabaseManager::instance().getDatabase());
    query.prepare("DELETE FROM scene_statistics WHERE stat_id = ?");
    query.addBindValue(statId);
    return query.exec();
}

std::optional<LEDDB::SceneStatistic> SqliteSceneStatisticRepository::findById(int statId) {
    QSqlQuery query(DatabaseManager::instance().getDatabase());
    query.prepare("SELECT * FROM scene_statistics WHERE stat_id = ?");
    query.addBindValue(statId);
    if (!query.exec() || !query.next()) {
        return std::nullopt;
    }
    return LEDDB::SceneStatistic::fromSqlRecord(query.record());
}

QList<LEDDB::SceneStatistic> SqliteSceneStatisticRepository::findAll() {
    QList<LEDDB::SceneStatistic> list;
    QSqlQuery query(DatabaseManager::instance().getDatabase());
    query.prepare("SELECT * FROM scene_statistics ORDER BY collect_time DESC");
    if (!query.exec()) return list;
    while (query.next()) list.append(LEDDB::SceneStatistic::fromSqlRecord(query.record()));
    return list;
}

QList<LEDDB::SceneStatistic> SqliteSceneStatisticRepository::findByTimeRange(
    const QDateTime& start, const QDateTime& end) {
    QList<LEDDB::SceneStatistic> list;
    QSqlQuery query(DatabaseManager::instance().getDatabase());
    query.prepare("SELECT * FROM scene_statistics WHERE collect_time BETWEEN ? AND ? ORDER BY collect_time");
    query.addBindValue(toIsoString(start));
    query.addBindValue(toIsoString(end));
    if (!query.exec()) return list;
    while (query.next()) list.append(LEDDB::SceneStatistic::fromSqlRecord(query.record()));
    return list;
}

QList<LEDDB::SceneStatistic> SqliteSceneStatisticRepository::findLatest(int limit) {
    QList<LEDDB::SceneStatistic> list;
    QSqlQuery query(DatabaseManager::instance().getDatabase());
    query.prepare("SELECT * FROM scene_statistics ORDER BY collect_time DESC LIMIT ?");
    query.addBindValue(limit);
    if (!query.exec()) return list;
    while (query.next()) list.append(LEDDB::SceneStatistic::fromSqlRecord(query.record()));
    return list;
}

QList<LEDDB::SceneStatistic> SqliteSceneStatisticRepository::findByProjectId(int projectId) {
    QList<LEDDB::SceneStatistic> list;
    QSqlQuery query(DatabaseManager::instance().getDatabase());
    query.prepare("SELECT * FROM scene_statistics WHERE project_id = ? ORDER BY collect_time DESC");
    query.addBindValue(projectId);
    if (!query.exec()) return list;
    while (query.next()) list.append(LEDDB::SceneStatistic::fromSqlRecord(query.record()));
    return list;
}

bool SqliteSceneStatisticRepository::archiveOlderThan(const QDateTime& before) {
    QSqlQuery query(DatabaseManager::instance().getDatabase());
    query.prepare("DELETE FROM scene_statistics WHERE collect_time < ?");
    query.addBindValue(toIsoString(before));
    return query.exec();
}