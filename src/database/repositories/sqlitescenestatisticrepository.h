#ifndef SQLITESCENESTATISTICREPOSITORY_H
#define SQLITESCENESTATISTICREPOSITORY_H

// repositories/sqlite_scenestatistic_repository.h
#pragma once
#include "interfaces/ISceneStatisticRepository.h"

namespace Repository {

class SqliteSceneStatisticRepository : public ISceneStatisticRepository {
public:
    bool insert(const LEDDB::SceneStatistic& stat) override;
    bool deleteById(int statId) override;
    QList<LEDDB::SceneStatistic> findByTimeRange(const QDateTime& start, const QDateTime& end) override;
    QList<LEDDB::SceneStatistic> findLatest(int limit = 100) override;
    QList<LEDDB::SceneStatistic> findByProjectId(int projectId) override;
    bool archiveOlderThan(const QDateTime& before) override;
};

} // namespace Repository
#endif // SQLITESCENESTATISTICREPOSITORY_H
