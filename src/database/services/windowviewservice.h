#ifndef WINDOWVIEWSERVICE_H
#define WINDOWVIEWSERVICE_H
#include "../databasemanager.h"
// services/WindowViewService.h
#pragma once
#include "../entities/windowview.h"
#include <optional>
#include <QList>

class WindowViewService {
public:
    WindowViewService();

    bool createWindow(const LEDDB::WindowView& window, const QString& operatorUser);
    bool updateWindow(const LEDDB::WindowView& window, const QString& operatorUser);
    bool deleteWindow(int windowId, const QString& operatorUser);
    std::optional<LEDDB::WindowView> getWindowById(int windowId);
    QList<LEDDB::WindowView> getWindowsByProgram(int programId);
    QList<LEDDB::WindowView> getWindowsByProgramId(int programId);
    bool reorderWindows(int programId, const QList<int>& windowIdsInOrder, const QString& operatorUser);
};

#endif // WINDOWVIEWSERVICE_H
