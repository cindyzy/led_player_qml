#include "sqliteplaylistrepository.h"

// repositories/sqlite_playlist_repository.cpp
// #include "sqlite_playlist_repository.h"
#include "../databasemanager.h"
#include "../utils/datetimehelper.h"
#include <QSqlQuery>

using namespace Repository;

bool SqlitePlayListRepository::insert(const LEDDB::PlayList& playlist) {
    QSqlQuery query(DatabaseManager::instance().getDatabase());
    query.prepare(R"(
        INSERT INTO play_list (project_id, list_name, play_sort, loop_type, status, create_time, update_time)
        VALUES (?, ?, ?, ?, ?, ?, ?)
    )");
    query.addBindValue(playlist.projectId());
    query.addBindValue(playlist.listName());
    query.addBindValue(playlist.playSort());
    query.addBindValue(playlist.loopType());
    query.addBindValue(playlist.status());
    query.addBindValue(toIsoString(playlist.createTime()));
    query.addBindValue(toIsoString(playlist.updateTime()));
    return query.exec();
}

bool SqlitePlayListRepository::update(const LEDDB::PlayList& playlist) {
    QSqlQuery query(DatabaseManager::instance().getDatabase());
    query.prepare(R"(
        UPDATE play_list SET project_id=?, list_name=?, play_sort=?, loop_type=?,
        status=?, update_time=? WHERE list_id=?
    )");
    query.addBindValue(playlist.projectId());
    query.addBindValue(playlist.listName());
    query.addBindValue(playlist.playSort());
    query.addBindValue(playlist.loopType());
    query.addBindValue(playlist.status());
    query.addBindValue(toIsoString(playlist.updateTime()));
    query.addBindValue(playlist.listId());
    return query.exec();
}

bool SqlitePlayListRepository::deleteById(int listId) {
    QSqlQuery query(DatabaseManager::instance().getDatabase());
    query.prepare("DELETE FROM play_list WHERE list_id = ?");
    query.addBindValue(listId);
    return query.exec();
}

bool SqlitePlayListRepository::deleteByProjectId(int projectId) {
    QSqlQuery query(DatabaseManager::instance().getDatabase());
    query.prepare("DELETE FROM play_list WHERE project_id = ?");
    query.addBindValue(projectId);
    return query.exec();
}

std::optional<LEDDB::PlayList> SqlitePlayListRepository::findById(int listId) {
    QSqlQuery query(DatabaseManager::instance().getDatabase());
    query.prepare("SELECT * FROM play_list WHERE list_id = ?");
    query.addBindValue(listId);
    if (!query.exec() || !query.next()) return std::nullopt;
    return LEDDB::PlayList::fromSqlRecord(query.record());
}

QList<LEDDB::PlayList> SqlitePlayListRepository::findByProjectId(int projectId) {
    QList<LEDDB::PlayList> list;
    QSqlQuery query(DatabaseManager::instance().getDatabase());
    query.prepare("SELECT * FROM play_list WHERE project_id = ?");
    query.addBindValue(projectId);
    if (!query.exec()) return list;
    while (query.next()) list.append(LEDDB::PlayList::fromSqlRecord(query.record()));
    return list;
}

QList<LEDDB::PlayList> SqlitePlayListRepository::findByProjectAndStatus(int projectId, int status) {
    QList<LEDDB::PlayList> list;
    QSqlQuery query(DatabaseManager::instance().getDatabase());
    query.prepare("SELECT * FROM play_list WHERE project_id = ? AND status = ?");
    query.addBindValue(projectId);
    query.addBindValue(status);
    if (!query.exec()) return list;
    while (query.next()) list.append(LEDDB::PlayList::fromSqlRecord(query.record()));
    return list;
}