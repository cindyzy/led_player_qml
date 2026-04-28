#ifndef ISCHEDULEPARAMREPOSITORY_H
#define ISCHEDULEPARAMREPOSITORY_H

// repositories/interfaces/IScheduleParamRepository.h
#pragma once
#include "../../entities/scheduleparam.h"
#include <optional>
#include <QList>

namespace Repository {

class IScheduleParamRepository {
public:
    virtual ~IScheduleParamRepository() = default;

    virtual bool insert(const LEDDB::ScheduleParam& param) = 0;
    virtual bool update(const LEDDB::ScheduleParam& param) = 0;
    virtual bool deleteById(int scheduleId) = 0;
    virtual std::optional<LEDDB::ScheduleParam> findById(int scheduleId) = 0;
    virtual std::optional<LEDDB::ScheduleParam> findBySceneType(const QString& sceneType) = 0;
    virtual QList<LEDDB::ScheduleParam> findAll() = 0;
};

} // namespace Repository

#endif // ISCHEDULEPARAMREPOSITORY_H
