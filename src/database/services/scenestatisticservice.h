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
    QList<LEDDB::SceneStatistic> getStatisticsByTimeRange(const QDateTime& start, const QDateTime& end);
    QList<LEDDB::SceneStatistic> getLatestStatistics(int limit = 100);
    bool archiveOldData(int daysToKeep);  // 删除超过指定天数的数据
};
#endif // SCENESTATISTICSERVICE_H
