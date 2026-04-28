// entities/scenestatistic.cpp
#include "scenestatistic.h"
#include "../../utils/datetimehelper.h"
#include <QSqlRecord>

namespace LEDDB {

SceneStatistic::SceneStatistic(int statId, const QDateTime& collectTime, int envBrightness,
                               const QString& sceneStatus, const QString& scheduleResult)
    : m_statId(statId), m_collectTime(collectTime), m_envBrightness(envBrightness),
    m_sceneStatus(sceneStatus), m_scheduleResult(scheduleResult) {}

SceneStatistic SceneStatistic::fromSqlRecord(const QSqlRecord& rec)
{
    SceneStatistic ss;
    ss.setStatId(rec.value("stat_id").toInt());
    ss.setCollectTime(fromIsoString(rec.value("collect_time").toString()));
    ss.setEnvBrightness(rec.value("env_brightness").toInt());
    ss.setSceneStatus(rec.value("scene_status").toString());
    ss.setScheduleResult(rec.value("schedule_result").toString());
    return ss;
}

} // namespace LEDDB