#ifndef PROGRAMINFOSERVICE_H
#define PROGRAMINFOSERVICE_H

// services/ProgramInfoService.h
#pragma once
#include "../entities/programinfo.h"
#include <optional>
#include <QList>
#include "../databasemanager.h"
class ProgramInfoService {
public:
    ProgramInfoService();

    bool createProgram(const LEDDB::ProgramInfo& program, const QString& operatorUser);
    bool updateProgram(const LEDDB::ProgramInfo& program, const QString& operatorUser);
    bool deleteProgram(int programId, const QString& operatorUser);
    std::optional<LEDDB::ProgramInfo> getProgramById(int programId);
    QList<LEDDB::ProgramInfo> getProgramsByPlayList(int listId);
    QList<LEDDB::ProgramInfo> getProgramsByListId(int listId);
    bool reorderPrograms(int listId, const QList<int>& programIdsInOrder, const QString& operatorUser);
};

#endif // PROGRAMINFOSERVICE_H
