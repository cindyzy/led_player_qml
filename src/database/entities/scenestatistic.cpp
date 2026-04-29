// entities/scenestatistic.cpp
#include "scenestatistic.h"
#include "../../utils/datetimehelper.h"
#include <QSqlRecord>

namespace LEDDB {

SceneStatistic::SceneStatistic(int statId, int projectId, const QString& sceneType,
                               const QDateTime& collectTime, int envBrightness,
                               const QString& sceneStatus, const QString& scheduleResult,
                               int playCount, double totalDuration, const QDate& statDate,
                               const QDateTime& createTime, const QDateTime& updateTime)
    : m_statId(statId)
    , m_projectId(projectId)
    , m_sceneType(sceneType)
    , m_collectTime(collectTime)
    , m_envBrightness(envBrightness)
    , m_sceneStatus(sceneStatus)
    , m_scheduleResult(scheduleResult)
    , m_playCount(playCount)
    , m_totalDuration(totalDuration)
    , m_statDate(statDate)
    , m_createTime(createTime)
    , m_updateTime(updateTime)
{
}

SceneStatistic SceneStatistic::fromSqlRecord(const QSqlRecord& record)
{
    SceneStatistic stat;
    stat.setStatId(record.value("stat_id").toInt());
    stat.setProjectId(record.value("project_id").toInt());
    stat.setSceneType(record.value("scene_type").toString());
    stat.setCollectTime(fromIsoString(record.value("collect_time").toString()));
    stat.setEnvBrightness(record.value("env_brightness").toInt());
    stat.setSceneStatus(record.value("scene_status").toString());
    stat.setScheduleResult(record.value("schedule_result").toString());
    stat.setPlayCount(record.value("play_count").toInt());
    stat.setTotalDuration(record.value("total_duration").toDouble());
    stat.setStatDate(QDate::fromString(record.value("stat_date").toString(), Qt::ISODate));
    stat.setCreateTime(fromIsoString(record.value("create_time").toString()));
    stat.setUpdateTime(fromIsoString(record.value("update_time").toString()));
    return stat;
}

} // namespace LEDDB