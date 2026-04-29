#include "programinfoservice.h"

// services/ProgramInfoService.cpp
// #include "ProgramInfoService.h"
#include "../repositories/RepositoryFactory.h"
#include "../../utils/datetimehelper.h"
#include "AuditLogService.h"
#include <QDateTime>

using namespace Repository;
using namespace LEDDB;

ProgramInfoService::ProgramInfoService() = default;

bool ProgramInfoService::createProgram(const ProgramInfo& program, const QString& operatorUser) {
    auto progRepo = RepositoryFactory::createProgramInfoRepository();
    ProgramInfo newProg = program;
    newProg.setCreateTime(QDateTime::currentDateTime());
    newProg.setUpdateTime(QDateTime::currentDateTime());
    bool success = progRepo->insert(newProg);
    int userId = 0;
    auto userRepo = RepositoryFactory::createUserRepository();
    auto userOpt = userRepo->findByUserName(operatorUser);
    if (userOpt.has_value()) {
        userId = userOpt.value().userId();
    }

    AuditLogService().logOperation(userId, "创建节目", success ? "成功" : "失败",
                                   QString("在播放列表 %1 下创建节目 %2").arg(program.listId()).arg(program.programName()),
                                   "program_info", newProg.programId());
    return success;
}

bool ProgramInfoService::updateProgram(const ProgramInfo& program, const QString& operatorUser) {
    auto progRepo = RepositoryFactory::createProgramInfoRepository();
    ProgramInfo updated = program;
    updated.setUpdateTime(QDateTime::currentDateTime());
    bool success = progRepo->update(updated);

    int userId = 0;
    auto userRepo = RepositoryFactory::createUserRepository();
    auto userOpt = userRepo->findByUserName(operatorUser);
    if (userOpt.has_value()) {
        userId = userOpt.value().userId();
    }

    AuditLogService().logOperation(userId, "更新节目", success ? "成功" : "失败",
                                   QString("更新节目 ID=%1").arg(program.programId()),
                                   "program_info", program.programId());
    return success;
}

bool ProgramInfoService::deleteProgram(int programId, const QString& operatorUser) {
    auto progRepo = RepositoryFactory::createProgramInfoRepository();
    auto program = progRepo->findById(programId);
    if (!program) return false;

    int userId = 0;
    auto userRepo = RepositoryFactory::createUserRepository();
    auto userOpt = userRepo->findByUserName(operatorUser);
    if (userOpt.has_value()) {
        userId = userOpt.value().userId();
    }

    auto viewRepo = RepositoryFactory::createWindowViewRepository();
    auto mediaRepo = RepositoryFactory::createMediaSourceRepository();

    auto& dbMgr = DatabaseManager::instance();
    if (!dbMgr.beginTransaction()) return false;

    auto windows = viewRepo->findByProgramId(programId);
    for (const auto& win : windows) {
        mediaRepo->deleteByWindowId(win.windowId());
    }
    viewRepo->deleteByProgramId(programId);
    bool success = progRepo->deleteById(programId);

    if (success && dbMgr.commitTransaction()) {
        AuditLogService().logOperation(userId, "删除节目", "成功",
                                       QString("删除节目 %1").arg(program->programName()),
                                       "program_info", programId);
        return true;
    } else {
        dbMgr.rollbackTransaction();
        AuditLogService().logOperation(userId, "删除节目", "失败",
                                       QString("删除节目 %1 失败").arg(program->programName()),
                                       "program_info", programId);
        return false;
    }
}

std::optional<ProgramInfo> ProgramInfoService::getProgramById(int programId) {
    auto progRepo = RepositoryFactory::createProgramInfoRepository();
    return progRepo->findById(programId);
}

QList<ProgramInfo> ProgramInfoService::getProgramsByPlayList(int listId) {
    auto progRepo = RepositoryFactory::createProgramInfoRepository();
    return progRepo->findByListId(listId);
}

QList<ProgramInfo> ProgramInfoService::getProgramsByListId(int listId) {
    // 与 getProgramsByPlayList 功能相同，提供别名以兼容不同调用习惯
    return getProgramsByPlayList(listId);
}

bool ProgramInfoService::reorderPrograms(int listId, const QList<int>& programIdsInOrder, const QString& operatorUser) {
    if (programIdsInOrder.isEmpty()) return true;

    int userId = 0;
    auto userRepo = RepositoryFactory::createUserRepository();
    auto userOpt = userRepo->findByUserName(operatorUser);
    if (userOpt.has_value()) {
        userId = userOpt.value().userId();
    }

    auto& dbMgr = DatabaseManager::instance();
    if (!dbMgr.beginTransaction()) return false;

    bool success = true;
    for (int i = 0; i < programIdsInOrder.size(); ++i) {
        auto prog = getProgramById(programIdsInOrder[i]);
        if (!prog || prog->listId() != listId) {
            success = false;
            break;
        }
        ProgramInfo updated = *prog;
        updated.setProgramSort(i);
        updated.setUpdateTime(QDateTime::currentDateTime());
        if (!RepositoryFactory::createProgramInfoRepository()->update(updated)) {
            success = false;
            break;
        }
    }

    if (success && dbMgr.commitTransaction()) {
        AuditLogService().logOperation(userId, "重排节目", "成功",
                                       QString("播放列表 %1 节目顺序已调整").arg(listId),
                                       "program_info", listId);
        return true;
    } else {
        dbMgr.rollbackTransaction();
        AuditLogService().logOperation(userId, "重排节目", "失败",
                                       QString("播放列表 %1 节目顺序调整失败").arg(listId),
                                       "program_info", listId);
        return false;
    }
}