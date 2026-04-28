#include "windowviewservice.h"

// services/WindowViewService.cpp
// #include "WindowViewService.h"
#include "../repositories/RepositoryFactory.h"
#include "../../utils/datetimehelper.h"
#include "AuditLogService.h"
#include <QDateTime>

using namespace Repository;
using namespace LEDDB;

WindowViewService::WindowViewService() = default;

bool WindowViewService::createWindow(const WindowView& window, const QString& operatorUser) {
    auto viewRepo = RepositoryFactory::createWindowViewRepository();
    WindowView newWin = window;
    newWin.setCreateTime(QDateTime::currentDateTime());
    newWin.setUpdateTime(QDateTime::currentDateTime());
    bool success = viewRepo->insert(newWin);
    AuditLogService().logOperation(operatorUser, "创建视窗",
                                   QString("在节目 %1 下创建视窗 %2").arg(window.programId()).arg(window.windowName()), success ? "成功" : "失败");
    return success;
}

bool WindowViewService::updateWindow(const WindowView& window, const QString& operatorUser) {
    auto viewRepo = RepositoryFactory::createWindowViewRepository();
    WindowView updated = window;
    updated.setUpdateTime(QDateTime::currentDateTime());
    bool success = viewRepo->update(updated);
    AuditLogService().logOperation(operatorUser, "更新视窗",
                                   QString("更新视窗 ID=%1").arg(window.windowId()), success ? "成功" : "失败");
    return success;
}

bool WindowViewService::deleteWindow(int windowId, const QString& operatorUser) {
    auto viewRepo = RepositoryFactory::createWindowViewRepository();
    auto window = viewRepo->findById(windowId);
    if (!window) return false;

    auto mediaRepo = RepositoryFactory::createMediaSourceRepository();

    auto& dbMgr = DatabaseManager::instance();
    if (!dbMgr.beginTransaction()) return false;

    mediaRepo->deleteByWindowId(windowId);
    bool success = viewRepo->deleteById(windowId);

    if (success && dbMgr.commitTransaction()) {
        AuditLogService().logOperation(operatorUser, "删除视窗",
                                       QString("删除视窗 %1").arg(window->windowName()), "成功");
        return true;
    } else {
        dbMgr.rollbackTransaction();
        AuditLogService().logOperation(operatorUser, "删除视窗",
                                       QString("删除视窗 %1 失败").arg(window->windowName()), "失败");
        return false;
    }
}

std::optional<WindowView> WindowViewService::getWindowById(int windowId) {
    auto viewRepo = RepositoryFactory::createWindowViewRepository();
    return viewRepo->findById(windowId);
}

QList<WindowView> WindowViewService::getWindowsByProgram(int programId) {
    auto viewRepo = RepositoryFactory::createWindowViewRepository();
    return viewRepo->findByProgramId(programId);
}

QList<WindowView> WindowViewService::getWindowsByProgramId(int programId) {
    // 与 getWindowsByProgram 功能相同，提供别名以兼容不同调用习惯
    return getWindowsByProgram(programId);
}

bool WindowViewService::reorderWindows(int programId, const QList<int>& windowIdsInOrder, const QString& operatorUser) {
    if (windowIdsInOrder.isEmpty()) return true;

    auto& dbMgr = DatabaseManager::instance();
    if (!dbMgr.beginTransaction()) return false;

    bool success = true;
    for (int i = 0; i < windowIdsInOrder.size(); ++i) {
        auto win = getWindowById(windowIdsInOrder[i]);
        if (!win || win->programId() != programId) {
            success = false;
            break;
        }
        WindowView updated = *win;
        updated.setZIndex(i);
        updated.setUpdateTime(QDateTime::currentDateTime());
        if (!RepositoryFactory::createWindowViewRepository()->update(updated)) {
            success = false;
            break;
        }
    }

    if (success && dbMgr.commitTransaction()) {
        AuditLogService().logOperation(operatorUser, "重排视窗",
                                       QString("节目 %1 视窗层级已调整").arg(programId), "成功");
        return true;
    } else {
        dbMgr.rollbackTransaction();
        AuditLogService().logOperation(operatorUser, "重排视窗",
                                       QString("节目 %1 视窗层级调整失败").arg(programId), "失败");
        return false;
    }
}