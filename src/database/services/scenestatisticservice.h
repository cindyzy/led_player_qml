#ifndef SCENESTATISTICSERVICE_H
#define SCENESTATISTICSERVICE_H

// services/SceneStatisticService.h
#pragma once
#include "../entities/scenestatistic.h"
#include <QList>
#include <QDateTime>

class SceneStatisticService {
public:
    SceneStatisticService();

    bool recordSceneData(const LEDDB::SceneStatistic& stat);
    bool updateSceneStatistic(const LEDDB::SceneStatistic& stat);
    bool deleteSceneStatistic(int statId);
    std::optional<LEDDB::SceneStatistic> getStatisticById(int statId);
    QList<LEDDB::SceneStatistic> getAllStatistics();
    QList<LEDDB::SceneStatistic> getStatisticsByTimeRange(const QDateTime& start, const QDateTime& end);
    QList<LEDDB::SceneStatistic> getStatisticsByProject(int projectId);
    QList<LEDDB::SceneStatistic> getLatestStatistics(int limit = 100);
    bool archiveOldData(int daysToKeep);
};
#endif // SCENESTATISTICSERVICE_H