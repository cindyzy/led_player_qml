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
        INSERT INTO scene_statistics (collect_time, env_brightness, scene_status, schedule_result)
        VALUES (?, ?, ?, ?)
    )");
    query.addBindValue(toIsoString(stat.collectTime()));
    query.addBindValue(stat.envBrightness());
    query.addBindValue(stat.sceneStatus());
    query.addBindValue(stat.scheduleResult());
    return query.exec();
}

bool SqliteSceneStatisticRepository::deleteById(int statId) {
    QSqlQuery query(DatabaseManager::instance().getDatabase());
    query.prepare("DELETE FROM scene_statistics WHERE stat_id = ?");
    query.addBindValue(statId);
    return query.exec();
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