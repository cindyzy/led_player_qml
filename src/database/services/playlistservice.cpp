#include "playlistservice.h"

// services/PlayListService.cpp
// #include "PlayListService.h"
#include "../repositories/RepositoryFactory.h"
#include "../../utils/datetimehelper.h"
#include "AuditLogService.h"
#include <QDateTime>

using namespace Repository;
using namespace LEDDB;

PlayListService::PlayListService() = default;

bool PlayListService::createPlayList(const PlayList& playlist, const QString& operatorUser) {
    auto plRepo = RepositoryFactory::createPlayListRepository();
    PlayList newPl = playlist;
    newPl.setCreateTime(QDateTime::currentDateTime());
    newPl.setUpdateTime(QDateTime::currentDateTime());
    bool success = plRepo->insert(newPl);
    int userId = 0;
    auto userRepo = RepositoryFactory::createUserRepository();
    auto userOpt = userRepo->findByUserName(operatorUser);
    if (userOpt.has_value()) {
        userId = userOpt.value().userId();
    }

    AuditLogService().logOperation(userId, "创建播放列表", success ? "成功" : "失败",
                                   QString("在项目 %1 下创建播放列表 %2").arg(playlist.projectId()).arg(playlist.listName()),
                                   "play_list", newPl.listId());
    return success;
}

bool PlayListService::updatePlayList(const PlayList& playlist, const QString& operatorUser) {
    auto plRepo = RepositoryFactory::createPlayListRepository();
    PlayList updated = playlist;
    updated.setUpdateTime(QDateTime::currentDateTime());
    bool success = plRepo->update(updated);

    int userId = 0;
    auto userRepo = RepositoryFactory::createUserRepository();
    auto userOpt = userRepo->findByUserName(operatorUser);
    if (userOpt.has_value()) {
        userId = userOpt.value().userId();
    }

    AuditLogService().logOperation(userId, "更新播放列表", success ? "成功" : "失败",
                                   QString("更新播放列表 ID=%1").arg(playlist.listId()),
                                   "play_list", playlist.listId());
    return success;
}

bool PlayListService::deletePlayList(int listId, const QString& operatorUser) {
    auto plRepo = RepositoryFactory::createPlayListRepository();
    auto playlist = plRepo->findById(listId);
    if (!playlist) return false;

    int userId = 0;
    auto userRepo = RepositoryFactory::createUserRepository();
    auto userOpt = userRepo->findByUserName(operatorUser);
    if (userOpt.has_value()) {
        userId = userOpt.value().userId();
    }

    // 删除列表前，先删除其下所有节目（及其下级内容）
    auto progRepo = RepositoryFactory::createProgramInfoRepository();
    auto viewRepo = RepositoryFactory::createWindowViewRepository();
    auto mediaRepo = RepositoryFactory::createMediaSourceRepository();

    auto& dbMgr = DatabaseManager::instance();
    if (!dbMgr.beginTransaction()) return false;

    auto programs = progRepo->findByListId(listId);
    for (const auto& prog : programs) {
        auto windows = viewRepo->findByProgramId(prog.programId());
        for (const auto& win : windows) {
            mediaRepo->deleteByWindowId(win.windowId());
        }
        viewRepo->deleteByProgramId(prog.programId());
    }
    progRepo->deleteByListId(listId);
    bool success = plRepo->deleteById(listId);

    if (success && dbMgr.commitTransaction()) {
        AuditLogService().logOperation(userId, "删除播放列表", "成功",
                                       QString("删除播放列表 %1").arg(playlist->listName()),
                                       "play_list", listId);
        return true;
    } else {
        dbMgr.rollbackTransaction();
        AuditLogService().logOperation(userId, "删除播放列表", "失败",
                                       QString("删除播放列表 %1 失败").arg(playlist->listName()),
                                       "play_list", listId);
        return false;
    }
}

std::optional<PlayList> PlayListService::getPlayListById(int listId) {
    auto plRepo = RepositoryFactory::createPlayListRepository();
    return plRepo->findById(listId);
}

QList<PlayList> PlayListService::getAllPlayLists() {
    auto plRepo = RepositoryFactory::createPlayListRepository();
    return plRepo->findAll();
}

QList<PlayList> PlayListService::getPlayListsByProject(int projectId) {
    auto plRepo = RepositoryFactory::createPlayListRepository();
    return plRepo->findByProjectId(projectId);
}

QList<PlayList> PlayListService::getPlayListsByProjectId(int projectId) {
    // 与 getPlayListsByProject 功能相同，提供别名以兼容不同调用习惯
    return getPlayListsByProject(projectId);
}

bool PlayListService::reorderPlayLists(int projectId, const QList<int>& listIdsInOrder, const QString& operatorUser) {
    if (listIdsInOrder.isEmpty()) return true;

    int userId = 0;
    auto userRepo = RepositoryFactory::createUserRepository();
    auto userOpt = userRepo->findByUserName(operatorUser);
    if (userOpt.has_value()) {
        userId = userOpt.value().userId();
    }

    auto& dbMgr = DatabaseManager::instance();
    if (!dbMgr.beginTransaction()) return false;

    bool success = true;
    for (int i = 0; i < listIdsInOrder.size(); ++i) {
        auto pl = getPlayListById(listIdsInOrder[i]);
        if (!pl || pl->projectId() != projectId) {
            success = false;
            break;
        }
        PlayList updated = *pl;
        updated.setPlaySort(i);
        updated.setUpdateTime(QDateTime::currentDateTime());
        if (!RepositoryFactory::createPlayListRepository()->update(updated)) {
            success = false;
            break;
        }
    }

    if (success && dbMgr.commitTransaction()) {
        AuditLogService().logOperation(userId, "重排播放列表", "成功",
                                       QString("项目 %1 播放列表顺序已调整").arg(projectId),
                                       "play_list", projectId);
        return true;
    } else {
        dbMgr.rollbackTransaction();
        AuditLogService().logOperation(userId, "重排播放列表", "失败",
                                       QString("项目 %1 播放列表顺序调整失败").arg(projectId),
                                       "play_list", projectId);
        return false;
    }
}