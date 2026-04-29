#include "ScheduleParamModel.h"
#include <QDebug>

ScheduleParamModel::ScheduleParamModel(QObject* parent) : QAbstractListModel(parent)
{
}

void ScheduleParamModel::setBusinessController(BusinessController* controller)
{
    m_businessController = controller;
}

bool ScheduleParamModel::loadParams()
{
    if (!m_businessController) {
        qDebug() << "ScheduleParamModel: BusinessController not set!";
        return false;
    }
    beginResetModel();
    m_params.clear();
    endResetModel();
    emit countChanged();
    return true;
}

QVariant ScheduleParamModel::getParamData(int index) const
{
    if (index < 0 || index >= m_params.size()) return QVariant();
    const LEDDB::ScheduleParam& param = m_params[index];
    QVariantMap map;
    map["scheduleId"] = param.scheduleId();
    map["sceneType"] = param.sceneType();
    map["sceneThreshold"] = param.sceneThreshold();
    map["predictCycle"] = param.predictCycle();
    map["envWeight"] = param.envWeight();
    map["sceneWeight"] = param.sceneWeight();
    map["brightnessMin"] = param.brightnessMin();
    map["brightnessMax"] = param.brightnessMax();
    map["strategyJson"] = param.strategyJson();
    return map;
}

bool ScheduleParamModel::addParam(const QString& sceneType, double sceneThreshold, int predictCycle,
                                   double envWeight, double sceneWeight, int brightnessMin, int brightnessMax,
                                   const QString& strategyJson)
{
    if (!m_businessController) {
        qDebug() << "ScheduleParamModel: BusinessController not set!";
        return false;
    }
    qDebug() << "ScheduleParamModel: addParam called -" << sceneType;
    return true;
}

bool ScheduleParamModel::updateParam(int scheduleId, const QString& sceneType, double sceneThreshold,
                                      int predictCycle, double envWeight, double sceneWeight,
                                      int brightnessMin, int brightnessMax, const QString& strategyJson)
{
    if (!m_businessController) {
        qDebug() << "ScheduleParamModel: BusinessController not set!";
        return false;
    }
    qDebug() << "ScheduleParamModel: updateParam called -" << scheduleId;
    return true;
}

bool ScheduleParamModel::deleteParam(int scheduleId)
{
    if (!m_businessController) {
        qDebug() << "ScheduleParamModel: BusinessController not set!";
        return false;
    }
    qDebug() << "ScheduleParamModel: deleteParam called -" << scheduleId;
    return true;
}

QVariant ScheduleParamModel::findParamById(int scheduleId) const
{
    for (int i = 0; i < m_params.size(); ++i) {
        if (m_params[i].scheduleId() == scheduleId) {
            return getParamData(i);
        }
    }
    return QVariant();
}

int ScheduleParamModel::rowCount(const QModelIndex& parent) const
{
    Q_UNUSED(parent);
    return m_params.size();
}

QVariant ScheduleParamModel::data(const QModelIndex& index, int role) const
{
    if (!index.isValid() || index.row() >= m_params.size()) return QVariant();
    const LEDDB::ScheduleParam& param = m_params[index.row()];
    switch (role) {
    case ScheduleIdRole: return param.scheduleId();
    case SceneTypeRole: return param.sceneType();
    case SceneThresholdRole: return param.sceneThreshold();
    case PredictCycleRole: return param.predictCycle();
    case EnvWeightRole: return param.envWeight();
    case SceneWeightRole: return param.sceneWeight();
    case BrightnessMinRole: return param.brightnessMin();
    case BrightnessMaxRole: return param.brightnessMax();
    case StrategyJsonRole: return param.strategyJson();
    default: return QVariant();
    }
}

QHash<int, QByteArray> ScheduleParamModel::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[ScheduleIdRole] = "scheduleId";
    roles[SceneTypeRole] = "sceneType";
    roles[SceneThresholdRole] = "sceneThreshold";
    roles[PredictCycleRole] = "predictCycle";
    roles[EnvWeightRole] = "envWeight";
    roles[SceneWeightRole] = "sceneWeight";
    roles[BrightnessMinRole] = "brightnessMin";
    roles[BrightnessMaxRole] = "brightnessMax";
    roles[StrategyJsonRole] = "strategyJson";
    return roles;
}