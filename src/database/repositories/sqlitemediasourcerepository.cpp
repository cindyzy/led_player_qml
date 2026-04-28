#include "sqlitemediasourcerepository.h"

// repositories/sqlite_mediasource_repository.cpp
// #include "sqlite_mediasource_repository.h"
#include "../databasemanager.h"
#include "../utils/datetimehelper.h"
#include <QSqlQuery>

using namespace Repository;

bool SqliteMediaSourceRepository::insert(const LEDDB::MediaSource& media) {
    QSqlQuery query(DatabaseManager::instance().getDatabase());
    query.prepare(R"(
        INSERT INTO media_source (file_path, file_type, duration, quality_param,
        ai_edit_param, create_time, window_id, media_sort)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?)
    )");
    query.addBindValue(media.filePath());
    query.addBindValue(media.fileType());
    query.addBindValue(media.duration());
    query.addBindValue(media.qualityParam());
    query.addBindValue(media.aiEditParam());
    query.addBindValue(toIsoString(media.createTime()));
    query.addBindValue(media.windowId());
    query.addBindValue(media.mediaSort());
    return query.exec();
}

bool SqliteMediaSourceRepository::update(const LEDDB::MediaSource& media) {
    QSqlQuery query(DatabaseManager::instance().getDatabase());
    query.prepare(R"(
        UPDATE media_source SET file_path=?, file_type=?, duration=?,
        quality_param=?, ai_edit_param=?, window_id=?, media_sort=?
        WHERE media_id=?
    )");
    query.addBindValue(media.filePath());
    query.addBindValue(media.fileType());
    query.addBindValue(media.duration());
    query.addBindValue(media.qualityParam());
    query.addBindValue(media.aiEditParam());
    query.addBindValue(media.windowId());
    query.addBindValue(media.mediaSort());
    query.addBindValue(media.mediaId());
    return query.exec();
}

bool SqliteMediaSourceRepository::deleteById(int mediaId) {
    QSqlQuery query(DatabaseManager::instance().getDatabase());
    query.prepare("DELETE FROM media_source WHERE media_id = ?");
    query.addBindValue(mediaId);
    return query.exec();
}

bool SqliteMediaSourceRepository::deleteByWindowId(int windowId) {
    QSqlQuery query(DatabaseManager::instance().getDatabase());
    query.prepare("DELETE FROM media_source WHERE window_id = ?");
    query.addBindValue(windowId);
    return query.exec();
}

std::optional<LEDDB::MediaSource> SqliteMediaSourceRepository::findById(int mediaId) {
    QSqlQuery query(DatabaseManager::instance().getDatabase());
    query.prepare("SELECT * FROM media_source WHERE media_id = ?");
    query.addBindValue(mediaId);
    if (!query.exec() || !query.next()) return std::nullopt;
    return LEDDB::MediaSource::fromSqlRecord(query.record());
}

QList<LEDDB::MediaSource> SqliteMediaSourceRepository::findByWindowId(int windowId) {
    QList<LEDDB::MediaSource> list;
    QSqlQuery query(DatabaseManager::instance().getDatabase());
    query.prepare("SELECT * FROM media_source WHERE window_id = ? ORDER BY media_sort");
    query.addBindValue(windowId);
    if (!query.exec()) return list;
    while (query.next()) list.append(LEDDB::MediaSource::fromSqlRecord(query.record()));
    return list;
}

QList<LEDDB::MediaSource> SqliteMediaSourceRepository::findByWindowAndType(int windowId, const QString& fileType) {
    QList<LEDDB::MediaSource> list;
    QSqlQuery query(DatabaseManager::instance().getDatabase());
    query.prepare("SELECT * FROM media_source WHERE window_id = ? AND file_type = ? ORDER BY media_sort");
    query.addBindValue(windowId);
    query.addBindValue(fileType);
    if (!query.exec()) return list;
    while (query.next()) list.append(LEDDB::MediaSource::fromSqlRecord(query.record()));
    return list;
}