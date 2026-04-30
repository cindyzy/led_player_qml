#include "sqliteprojectconfigrepository.h"

// repositories/sqlite_projectconfig_repository.cpp
// #include "sqlite_projectconfig_repository.h"
#include "../databasemanager.h"
#include "../../utils/datetimehelper.h"
#include <QSqlQuery>

using namespace Repository;

bool SqliteProjectConfigRepository::insert(const LEDDB::ProjectConfig& project) {
    QSqlQuery query(DatabaseManager::instance().getDatabase());
    query.prepare(R"(
        INSERT INTO project_config (project_name, project_path, window_layout, light_mapping,
        cron_strategy, create_time, is_valid)
        VALUES (?, ?, ?, ?, ?, ?, ?)
    )");
    query.addBindValue(project.projectName());
    query.addBindValue(project.projectPath());
    query.addBindValue(project.windowLayout());
    query.addBindValue(project.lightMapping());
    query.addBindValue(project.cronStrategy());
    query.addBindValue(toIsoString(project.createTime()));
    query.addBindValue(project.isValid());
    return query.exec();
}

bool SqliteProjectConfigRepository::update(const LEDDB::ProjectConfig& project) {
    QSqlQuery query(DatabaseManager::instance().getDatabase());
    query.prepare(R"(
        UPDATE project_config SET project_name=?, project_path=?, window_layout=?, light_mapping=?,
        cron_strategy=?, is_valid=? WHERE project_id=?
    )");
    query.addBindValue(project.projectName());
    query.addBindValue(project.projectPath());
    query.addBindValue(project.windowLayout());
    query.addBindValue(project.lightMapping());
    query.addBindValue(project.cronStrategy());
    query.addBindValue(project.isValid());
    query.addBindValue(project.projectId());
    return query.exec();
}

bool SqliteProjectConfigRepository::deleteById(int projectId) {
    QSqlQuery query(DatabaseManager::instance().getDatabase());
    query.prepare("DELETE FROM project_config WHERE project_id = ?");
    query.addBindValue(projectId);
    return query.exec();
}

bool SqliteProjectConfigRepository::cascadeDeleteById(int projectId) {
    auto& dbMgr = DatabaseManager::instance();
    if (!dbMgr.beginTransaction()) return false;

    SqlitePlayListRepository plRepo;
    SqliteProgramInfoRepository progRepo;
    SqliteWindowViewRepository viewRepo;
    SqliteMediaSourceRepository mediaRepo;

    // 1. 获取项目下所有播放列表
    auto playLists = plRepo.findByProjectId(projectId);
    for (const auto& pl : playLists) {
        // 2. 获取列表下所有节目
        auto programs = progRepo.findByListId(pl.listId());
        for (const auto& prog : programs) {
            // 3. 获取节目下所有视窗
            auto windows = viewRepo.findByProgramId(prog.programId());
            for (const auto& win : windows) {
                if (!mediaRepo.deleteByWindowId(win.windowId())) {
                    dbMgr.rollbackTransaction();
                    return false;
                }
            }
            if (!viewRepo.deleteByProgramId(prog.programId())) {
                dbMgr.rollbackTransaction();
                return false;
            }
        }
        if (!progRepo.deleteByListId(pl.listId())) {
            dbMgr.rollbackTransaction();
            return false;
        }
    }
    if (!plRepo.deleteByProjectId(projectId)) {
        dbMgr.rollbackTransaction();
        return false;
    }
    if (!deleteById(projectId)) {
        dbMgr.rollbackTransaction();
        return false;
    }
    return dbMgr.commitTransaction();
}

std::optional<LEDDB::ProjectConfig> SqliteProjectConfigRepository::findById(int projectId) {
    QSqlQuery query(DatabaseManager::instance().getDatabase());
    query.prepare("SELECT * FROM project_config WHERE project_id = ?");
    query.addBindValue(projectId);
    if (!query.exec() || !query.next()) return std::nullopt;
    return LEDDB::ProjectConfig::fromSqlRecord(query.record());
}

QList<LEDDB::ProjectConfig> SqliteProjectConfigRepository::findByValid(int isValid) {
    QList<LEDDB::ProjectConfig> list;
    QSqlQuery query(DatabaseManager::instance().getDatabase());
    query.prepare("SELECT * FROM project_config WHERE is_valid = ?");
    query.addBindValue(isValid);
    if (!query.exec()) return list;
    while (query.next()) list.append(LEDDB::ProjectConfig::fromSqlRecord(query.record()));
    return list;
}

QList<LEDDB::ProjectConfig> SqliteProjectConfigRepository::findAll() {
    QList<LEDDB::ProjectConfig> list;
    QSqlQuery query("SELECT * FROM project_config", DatabaseManager::instance().getDatabase());
    while (query.next()) list.append(LEDDB::ProjectConfig::fromSqlRecord(query.record()));
    return list;
}