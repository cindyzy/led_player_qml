#ifndef SCHEDULEPARAM_H
#define SCHEDULEPARAM_H

// entities/scheduleparam.h
#pragma once
#include <QString>
#include <QSqlRecord>
namespace LEDDB {

class ScheduleParam {
public:
    ScheduleParam() = default;
    ScheduleParam(int scheduleId, const QString& sceneType, double sceneThreshold,
                  int predictCycle, double envWeight, double sceneWeight,
                  int brightnessMin, int brightnessMax, const QString& strategyJson);

    int scheduleId() const { return m_scheduleId; }
    void setScheduleId(int id) { m_scheduleId = id; }

    QString sceneType() const { return m_sceneType; }
    void setSceneType(const QString& type) { m_sceneType = type; }

    double sceneThreshold() const { return m_sceneThreshold; }
    void setSceneThreshold(double thr) { m_sceneThreshold = thr; }

    int predictCycle() const { return m_predictCycle; }
    void setPredictCycle(int cycle) { m_predictCycle = cycle; }

    double envWeight() const { return m_envWeight; }
    void setEnvWeight(double weight) { m_envWeight = weight; }

    double sceneWeight() const { return m_sceneWeight; }
    void setSceneWeight(double weight) { m_sceneWeight = weight; }

    int brightnessMin() const { return m_brightnessMin; }
    void setBrightnessMin(int min) { m_brightnessMin = min; }

    int brightnessMax() const { return m_brightnessMax; }
    void setBrightnessMax(int max) { m_brightnessMax = max; }

    QString strategyJson() const { return m_strategyJson; }
    void setStrategyJson(const QString& json) { m_strategyJson = json; }

    static ScheduleParam fromSqlRecord(const QSqlRecord& record);

private:
    int m_scheduleId = 0;
    QString m_sceneType;
    double m_sceneThreshold = 0.5;
    int m_predictCycle = 5;
    double m_envWeight = 0.5;
    double m_sceneWeight = 0.5;
    int m_brightnessMin = 10;
    int m_brightnessMax = 100;
    QString m_strategyJson;
};

} // namespace LEDDB
#endif // SCHEDULEPARAM_H
