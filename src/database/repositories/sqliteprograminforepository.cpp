#include "sqliteprograminforepository.h"

// repositories/sqlite_programinfo_repository.cpp
// #include "sqlite_programinfo_repository.h"
#include "../databasemanager.h"
#include "../../utils/datetimehelper.h"
#include <QSqlQuery>

using namespace Repository;

bool SqliteProgramInfoRepository::insert(const LEDDB::ProgramInfo& program) {
    QSqlQuery query(DatabaseManager::instance().getDatabase());
    query.prepare(R"(
        INSERT INTO program_info (list_id, program_name, program_sort, play_duration,
        interval_time, status, create_time, update_time)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?)
    )");
    query.addBindValue(program.listId());
    query.addBindValue(program.programName());
    query.addBindValue(program.programSort());
    query.addBindValue(program.playDuration());
    query.addBindValue(program.intervalTime());
    query.addBindValue(program.status());
    query.addBindValue(toIsoString(program.createTime()));
    query.addBindValue(toIsoString(program.updateTime()));
    return query.exec();
}

bool SqliteProgramInfoRepository::update(const LEDDB::ProgramInfo& program) {
    QSqlQuery query(DatabaseManager::instance().getDatabase());
    query.prepare(R"(
        UPDATE program_info SET list_id=?, program_name=?, program_sort=?,
        play_duration=?, interval_time=?, status=?, update_time=?
        WHERE program_id=?
    )");
    query.addBindValue(program.listId());
    query.addBindValue(program.programName());
    query.addBindValue(program.programSort());
    query.addBindValue(program.playDuration());
    query.addBindValue(program.intervalTime());
    query.addBindValue(program.status());
    query.addBindValue(toIsoString(program.updateTime()));
    query.addBindValue(program.programId());
    return query.exec();
}

bool SqliteProgramInfoRepository::deleteById(int programId) {
    QSqlQuery query(DatabaseManager::instance().getDatabase());
    query.prepare("DELETE FROM program_info WHERE program_id = ?");
    query.addBindValue(programId);
    return query.exec();
}

bool SqliteProgramInfoRepository::deleteByListId(int listId) {
    QSqlQuery query(DatabaseManager::instance().getDatabase());
    query.prepare("DELETE FROM program_info WHERE list_id = ?");
    query.addBindValue(listId);
    return query.exec();
}

std::optional<LEDDB::ProgramInfo> SqliteProgramInfoRepository::findById(int programId) {
    QSqlQuery query(DatabaseManager::instance().getDatabase());
    query.prepare("SELECT * FROM program_info WHERE program_id = ?");
    query.addBindValue(programId);
    if (!query.exec() || !query.next()) return std::nullopt;
    return LEDDB::ProgramInfo::fromSqlRecord(query.record());
}

QList<LEDDB::ProgramInfo> SqliteProgramInfoRepository::findByListId(int listId) {
    QList<LEDDB::ProgramInfo> list;
    QSqlQuery query(DatabaseManager::instance().getDatabase());
    query.prepare("SELECT * FROM program_info WHERE list_id = ?");
    query.addBindValue(listId);
    if (!query.exec()) return list;
    while (query.next()) list.append(LEDDB::ProgramInfo::fromSqlRecord(query.record()));
    return list;
}

QList<LEDDB::ProgramInfo> SqliteProgramInfoRepository::findByListIdAndStatus(int listId, int status) {
    QList<LEDDB::ProgramInfo> list;
    QSqlQuery query(DatabaseManager::instance().getDatabase());
    query.prepare("SELECT * FROM program_info WHERE list_id = ? AND status = ?");
    query.addBindValue(listId);
    query.addBindValue(status);
    if (!query.exec()) return list;
    while (query.next()) list.append(LEDDB::ProgramInfo::fromSqlRecord(query.record()));
    return list;
}