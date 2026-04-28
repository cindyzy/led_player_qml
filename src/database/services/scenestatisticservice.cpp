#include "scenestatisticservice.h"

// services/SceneStatisticService.cpp
// #include "SceneStatisticService.h"
#include "../repositories/RepositoryFactory.h"
#include "../../utils/datetimehelper.h"
#include <QDateTime>

using namespace Repository;
using namespace LEDDB;

SceneStatisticService::SceneStatisticService() = default;

bool SceneStatisticService::recordSceneData(const SceneStatistic& stat) {
    auto statRepo = RepositoryFactory::createSceneStatisticRepository();
    SceneStatistic newStat = stat;
    if (newStat.collectTime().isNull())
        newStat.setCollectTime(QDateTime::currentDateTime());
    return statRepo->insert(newStat);
}

QList<SceneStatistic> SceneStatisticService::getStatisticsByTimeRange(const QDateTime& start, const QDateTime& end) {
    auto statRepo = RepositoryFactory::createSceneStatisticRepository();
    return statRepo->findByTimeRange(start, end);
}

QList<SceneStatistic> SceneStatisticService::getLatestStatistics(int limit) {
    auto statRepo = RepositoryFactory::createSceneStatisticRepository();
    return statRepo->findLatest(limit);
}

bool SceneStatisticService::archiveOldData(int daysToKeep) {
    QDateTime archiveBefore = QDateTime::currentDateTime().addDays(-daysToKeep);
    auto statRepo = RepositoryFactory::createSceneStatisticRepository();
    return statRepo->archiveOlderThan(archiveBefore);
}