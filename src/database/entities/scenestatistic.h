#ifndef SCENESTATISTIC_H
#define SCENESTATISTIC_H

// entities/scenestatistic.h
#pragma once
#include <QString>
#include <QDateTime>
#include <QSqlRecord>
namespace LEDDB {

class SceneStatistic {
public:
    SceneStatistic() = default;
    SceneStatistic(int statId, const QDateTime& collectTime, int envBrightness,
                   const QString& sceneStatus, const QString& scheduleResult);

    int statId() const { return m_statId; }
    void setStatId(int id) { m_statId = id; }

    QDateTime collectTime() const { return m_collectTime; }
    void setCollectTime(const QDateTime& dt) { m_collectTime = dt; }

    int envBrightness() const { return m_envBrightness; }
    void setEnvBrightness(int brightness) { m_envBrightness = brightness; }

    QString sceneStatus() const { return m_sceneStatus; }
    void setSceneStatus(const QString& status) { m_sceneStatus = status; }

    QString scheduleResult() const { return m_scheduleResult; }
    void setScheduleResult(const QString& result) { m_scheduleResult = result; }

    static SceneStatistic fromSqlRecord(const QSqlRecord& record);

private:
    int m_statId = 0;
    QDateTime m_collectTime;
    int m_envBrightness = 0;
    QString m_sceneStatus;
    QString m_scheduleResult;
};

} // namespace LEDDB

#endif // SCENESTATISTIC_H
