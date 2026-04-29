#ifndef ISCENESTATISTICREPOSITORY_H
#define ISCENESTATISTICREPOSITORY_H

// repositories/interfaces/ISceneStatisticRepository.h
#pragma once
#include "../../entities/scenestatistic.h"
#include <QList>
#include <QDateTime>

namespace Repository {

class ISceneStatisticRepository {
public:
    virtual ~ISceneStatisticRepository() = default;

    virtual bool insert(const LEDDB::SceneStatistic& stat) = 0;
    virtual bool deleteById(int statId) = 0;                // 允许清理旧数据
    virtual QList<LEDDB::SceneStatistic> findByTimeRange(const QDateTime& start, const QDateTime& end) = 0;
    virtual QList<LEDDB::SceneStatistic> findLatest(int limit = 100) = 0;
    virtual QList<LEDDB::SceneStatistic> findByProjectId(int projectId) = 0;
    virtual bool archiveOlderThan(const QDateTime& before) = 0;
};

} // namespace Repositoryz
#endif // ISCENESTATISTICREPOSITORY_H
