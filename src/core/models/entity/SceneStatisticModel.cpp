#include "SceneStatisticModel.h"
#include <QDebug>

SceneStatisticModel::SceneStatisticModel(QObject* parent) : QAbstractListModel(parent)
{
}

void SceneStatisticModel::setBusinessController(BusinessController* controller)
{
    m_businessController = controller;
}

bool SceneStatisticModel::loadStatistics(int projectId)
{
    if (!m_businessController) {
        qDebug() << "SceneStatisticModel: BusinessController not set!";
        return false;
    }
    beginResetModel();
    m_statistics.clear();
    endResetModel();
    emit countChanged();
    return true;
}

QVariant SceneStatisticModel::getStatisticData(int index) const
{
    if (index < 0 || index >= m_statistics.size()) return QVariant();
    const LEDDB::SceneStatistic& stat = m_statistics[index];
    QVariantMap map;
    map["statId"]          = stat.statId();
    map["projectId"]       = stat.projectId();
    map["sceneType"]       = stat.sceneType();
    map["collectTime"]     = stat.collectTime();
    map["envBrightness"]   = stat.envBrightness();
    map["sceneStatus"]     = stat.sceneStatus();
    map["scheduleResult"]  = stat.scheduleResult();
    map["playCount"]       = stat.playCount();
    map["totalDuration"]   = stat.totalDuration();
    map["statDate"]        = stat.statDate();
    map["createTime"]      = stat.createTime();
    map["updateTime"]      = stat.updateTime();
    return map;
}

bool SceneStatisticModel::addStatistic(int projectId, const QString& sceneType, int playCount,
                                       double totalDuration, const QDateTime& statDate)
{
    if (!m_businessController) {
        qDebug() << "SceneStatisticModel: BusinessController not set!";
        return false;
    }
    qDebug() << "SceneStatisticModel: addStatistic called -" << sceneType;
    return true;
}

bool SceneStatisticModel::updateStatistic(int statId, int playCount, double totalDuration)
{
    if (!m_businessController) {
        qDebug() << "SceneStatisticModel: BusinessController not set!";
        return false;
    }
    qDebug() << "SceneStatisticModel: updateStatistic called -" << statId;
    return true;
}

bool SceneStatisticModel::deleteStatistic(int statId)
{
    if (!m_businessController) {
        qDebug() << "SceneStatisticModel: BusinessController not set!";
        return false;
    }
    qDebug() << "SceneStatisticModel: deleteStatistic called -" << statId;
    return true;
}

QVariant SceneStatisticModel::findStatisticById(int statId) const
{
    for (int i = 0; i < m_statistics.size(); ++i) {
        if (m_statistics[i].statId() == statId) {
            return getStatisticData(i);
        }
    }
    return QVariant();
}

int SceneStatisticModel::rowCount(const QModelIndex& parent) const
{
    Q_UNUSED(parent);
    return m_statistics.size();
}

QVariant SceneStatisticModel::data(const QModelIndex& index, int role) const
{
    if (!index.isValid() || index.row() >= m_statistics.size()) return QVariant();
    const LEDDB::SceneStatistic& stat = m_statistics[index.row()];
    switch (role) {
    case StatIdRole:          return stat.statId();
    case ProjectIdRole:       return stat.projectId();
    case SceneTypeRole:       return stat.sceneType();
    case CollectTimeRole:     return stat.collectTime();
    case EnvBrightnessRole:   return stat.envBrightness();
    case SceneStatusRole:     return stat.sceneStatus();
    case ScheduleResultRole:  return stat.scheduleResult();
    case PlayCountRole:       return stat.playCount();
    case TotalDurationRole:   return stat.totalDuration();
    case StatDateRole:        return stat.statDate();
    case CreateTimeRole:      return stat.createTime();
    case UpdateTimeRole:      return stat.updateTime();
    default:                  return QVariant();
    }
}

QHash<int, QByteArray> SceneStatisticModel::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[StatIdRole]         = "statId";
    roles[ProjectIdRole]      = "projectId";
    roles[SceneTypeRole]      = "sceneType";
    roles[CollectTimeRole]    = "collectTime";
    roles[EnvBrightnessRole]  = "envBrightness";
    roles[SceneStatusRole]    = "sceneStatus";
    roles[ScheduleResultRole] = "scheduleResult";
    roles[PlayCountRole]      = "playCount";
    roles[TotalDurationRole]  = "totalDuration";
    roles[StatDateRole]       = "statDate";
    roles[CreateTimeRole]     = "createTime";
    roles[UpdateTimeRole]     = "updateTime";
    return roles;
}