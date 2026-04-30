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
    if (newStat.createTime().isNull())
        newStat.setCreateTime(QDateTime::currentDateTime());
    newStat.setUpdateTime(QDateTime::currentDateTime());
    return statRepo->insert(newStat);
}

bool SceneStatisticService::updateSceneStatistic(const SceneStatistic& stat) {
    auto statRepo = RepositoryFactory::createSceneStatisticRepository();
    SceneStatistic updated = stat;
    updated.setUpdateTime(QDateTime::currentDateTime());
    return statRepo->update(updated);
}

bool SceneStatisticService::deleteSceneStatistic(int statId) {
    auto statRepo = RepositoryFactory::createSceneStatisticRepository();
    return statRepo->deleteById(statId);
}

std::optional<SceneStatistic> SceneStatisticService::getStatisticById(int statId) {
    auto statRepo = RepositoryFactory::createSceneStatisticRepository();
    return statRepo->findById(statId);
}

QList<SceneStatistic> SceneStatisticService::getAllStatistics() {
    auto statRepo = RepositoryFactory::createSceneStatisticRepository();
    return statRepo->findAll();
}

QList<SceneStatistic> SceneStatisticService::getStatisticsByTimeRange(const QDateTime& start, const QDateTime& end) {
    auto statRepo = RepositoryFactory::createSceneStatisticRepository();
    return statRepo->findByTimeRange(start, end);
}

QList<SceneStatistic> SceneStatisticService::getStatisticsByProject(int projectId) {
    auto statRepo = RepositoryFactory::createSceneStatisticRepository();
    return statRepo->findByProjectId(projectId);
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