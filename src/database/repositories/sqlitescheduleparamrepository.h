#ifndef SQLITESCHEDULEPARAMREPOSITORY_H
#define SQLITESCHEDULEPARAMREPOSITORY_H

// repositories/sqlite_scheduleparam_repository.h
#pragma once
#include "interfaces/IScheduleParamRepository.h"

namespace Repository {

class SqliteScheduleParamRepository : public IScheduleParamRepository {
public:
    bool insert(const LEDDB::ScheduleParam& param) override;
    bool update(const LEDDB::ScheduleParam& param) override;
    bool deleteById(int scheduleId) override;
    std::optional<LEDDB::ScheduleParam> findById(int scheduleId) override;
    std::optional<LEDDB::ScheduleParam> findBySceneType(const QString& sceneType) override;
    QList<LEDDB::ScheduleParam> findAll() override;
};

} // namespace Repository

#endif // SQLITESCHEDULEPARAMREPOSITORY_H
