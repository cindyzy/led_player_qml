// entities/scheduleparam.cpp
#include "scheduleparam.h"
#include <QSqlRecord>
#include "../../utils/datetimehelper.h"

namespace LEDDB {

ScheduleParam::ScheduleParam(int scheduleId, const QString& sceneType, double sceneThreshold,
                             int predictCycle, double envWeight, double sceneWeight,
                             int brightnessMin, int brightnessMax, const QString& strategyJson)
    : m_scheduleId(scheduleId), m_sceneType(sceneType), m_sceneThreshold(sceneThreshold),
    m_predictCycle(predictCycle), m_envWeight(envWeight), m_sceneWeight(sceneWeight),
    m_brightnessMin(brightnessMin), m_brightnessMax(brightnessMax), m_strategyJson(strategyJson) {}

ScheduleParam ScheduleParam::fromSqlRecord(const QSqlRecord& rec)
{
    ScheduleParam sp;
    sp.setScheduleId(rec.value("schedule_id").toInt());
    sp.setSceneType(rec.value("scene_type").toString());
    sp.setSceneThreshold(rec.value("scene_threshold").toDouble());
    sp.setPredictCycle(rec.value("predict_cycle").toInt());
    sp.setEnvWeight(rec.value("env_weight").toDouble());
    sp.setSceneWeight(rec.value("scene_weight").toDouble());
    sp.setBrightnessMin(rec.value("brightness_min").toInt());
    sp.setBrightnessMax(rec.value("brightness_max").toInt());
    sp.setStrategyJson(rec.value("strategy_json").toString());
    return sp;
}

} // namespace LEDDB