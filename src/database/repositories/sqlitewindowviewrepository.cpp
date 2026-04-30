#include "sqlitewindowviewrepository.h"

// repositories/sqlite_windowview_repository.cpp
// #include "sqlite_windowview_repository.h"
#include "../databasemanager.h"
#include "../../utils/datetimehelper.h"
#include <QSqlQuery>

using namespace Repository;

bool SqliteWindowViewRepository::insert(const LEDDB::WindowView& view) {
    QSqlQuery query(DatabaseManager::instance().getDatabase());
    query.prepare(R"(
        INSERT INTO window_view (program_id, window_name, x_pos, y_pos, width, height,
        z_index, status, blend_type, window_color, lock_position, play_count, create_time, update_time)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    )");
    query.addBindValue(view.programId());
    query.addBindValue(view.windowName());
    query.addBindValue(view.xPos());
    query.addBindValue(view.yPos());
    query.addBindValue(view.width());
    query.addBindValue(view.height());
    query.addBindValue(view.zIndex());
    query.addBindValue(view.status());
    query.addBindValue(view.blendType());
    query.addBindValue(view.windowColor());
    query.addBindValue(view.lockPosition());
    query.addBindValue(view.playCount());
    query.addBindValue(toIsoString(view.createTime()));
    query.addBindValue(toIsoString(view.updateTime()));
    return query.exec();
}

bool SqliteWindowViewRepository::update(const LEDDB::WindowView& view) {
    QSqlQuery query(DatabaseManager::instance().getDatabase());
    query.prepare(R"(
        UPDATE window_view SET program_id=?, window_name=?, x_pos=?, y_pos=?,
        width=?, height=?, z_index=?, status=?, blend_type=?, window_color=?,
        lock_position=?, play_count=?, update_time=? WHERE window_id=?
    )");
    query.addBindValue(view.programId());
    query.addBindValue(view.windowName());
    query.addBindValue(view.xPos());
    query.addBindValue(view.yPos());
    query.addBindValue(view.width());
    query.addBindValue(view.height());
    query.addBindValue(view.zIndex());
    query.addBindValue(view.status());
    query.addBindValue(view.blendType());
    query.addBindValue(view.windowColor());
    query.addBindValue(view.lockPosition());
    query.addBindValue(view.playCount());
    query.addBindValue(toIsoString(view.updateTime()));
    query.addBindValue(view.windowId());
    return query.exec();
}

bool SqliteWindowViewRepository::deleteById(int windowId) {
    QSqlQuery query(DatabaseManager::instance().getDatabase());
    query.prepare("DELETE FROM window_view WHERE window_id = ?");
    query.addBindValue(windowId);
    return query.exec();
}

bool SqliteWindowViewRepository::deleteByProgramId(int programId) {
    QSqlQuery query(DatabaseManager::instance().getDatabase());
    query.prepare("DELETE FROM window_view WHERE program_id = ?");
    query.addBindValue(programId);
    return query.exec();
}

std::optional<LEDDB::WindowView> SqliteWindowViewRepository::findById(int windowId) {
    QSqlQuery query(DatabaseManager::instance().getDatabase());
    query.prepare("SELECT * FROM window_view WHERE window_id = ?");
    query.addBindValue(windowId);
    if (!query.exec() || !query.next()) return std::nullopt;
    return LEDDB::WindowView::fromSqlRecord(query.record());
}

QList<LEDDB::WindowView> SqliteWindowViewRepository::findByProgramId(int programId) {
    QList<LEDDB::WindowView> list;
    QSqlQuery query(DatabaseManager::instance().getDatabase());
    query.prepare("SELECT * FROM window_view WHERE program_id = ?");
    query.addBindValue(programId);
    if (!query.exec()) return list;
    while (query.next()) list.append(LEDDB::WindowView::fromSqlRecord(query.record()));
    return list;
}

QList<LEDDB::WindowView> SqliteWindowViewRepository::getWindowsByProgramId(int programId) {
    // 与 findByProgramId 功能相同，提供别名以兼容不同调用习惯
    return findByProgramId(programId);
}

QList<LEDDB::WindowView> SqliteWindowViewRepository::findByProgramAndStatus(int programId, int status) {
    QList<LEDDB::WindowView> list;
    QSqlQuery query(DatabaseManager::instance().getDatabase());
    query.prepare("SELECT * FROM window_view WHERE program_id = ? AND status = ?");
    query.addBindValue(programId);
    query.addBindValue(status);
    if (!query.exec()) return list;
    while (query.next()) list.append(LEDDB::WindowView::fromSqlRecord(query.record()));
    return list;
}