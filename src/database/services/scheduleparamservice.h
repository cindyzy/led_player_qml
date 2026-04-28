#ifndef SCHEDULEPARAMSERVICE_H
#define SCHEDULEPARAMSERVICE_H

// services/ScheduleParamService.h
#pragma once
#include "../entities/scheduleparam.h"
#include <optional>
#include <QList>

class ScheduleParamService {
public:
    ScheduleParamService();

    bool saveScheduleParam(const LEDDB::ScheduleParam& param, const QString& operatorUser);
    bool deleteScheduleParam(int scheduleId, const QString& operatorUser);
    std::optional<LEDDB::ScheduleParam> getScheduleParam(int scheduleId);
    std::optional<LEDDB::ScheduleParam> getScheduleParamBySceneType(const QString& sceneType);
    QList<LEDDB::ScheduleParam> getAllScheduleParams();
};
#endif // SCHEDULEPARAMSERVICE_H
