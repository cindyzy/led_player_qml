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
    QList<LEDDB::SceneStatistic> statistics;
    if (projectId > 0) {
        statistics = m_businessController->getStatisticsByProject(projectId);
    } else {
        statistics = m_businessController->getAllStatistics();
    }
    beginResetModel();
    m_statistics = statistics;
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
                                       double totalDuration, const QDateTime& statDate, const QString& operatorUser)
{
    if (!m_businessController) {
        qDebug() << "SceneStatisticModel: BusinessController not set!";
        return false;
    }
    LEDDB::SceneStatistic stat;
    stat.setProjectId(projectId);
    stat.setSceneType(sceneType);
    stat.setPlayCount(playCount);
    stat.setTotalDuration(totalDuration);
    stat.setStatDate(statDate.date());
    stat.setCollectTime(statDate);
    bool success = m_businessController->recordSceneStatistic(stat, operatorUser);
    if (success) {
        loadStatistics(projectId);
    }
    return success;
}

bool SceneStatisticModel::updateStatistic(int statId, int playCount, double totalDuration, const QString& operatorUser)
{
    if (!m_businessController) {
        qDebug() << "SceneStatisticModel: BusinessController not set!";
        return false;
    }
    auto optStat = m_businessController->getStatisticById(statId);
    if (!optStat.has_value()) {
        return false;
    }
    LEDDB::SceneStatistic stat = optStat.value();
    stat.setPlayCount(playCount);
    stat.setTotalDuration(totalDuration);
    bool success = m_businessController->updateSceneStatistic(stat, operatorUser);
    if (success) {
        loadStatistics(0);
    }
    return success;
}

bool SceneStatisticModel::deleteStatistic(int statId, const QString& operatorUser)
{
    if (!m_businessController) {
        qDebug() << "SceneStatisticModel: BusinessController not set!";
        return false;
    }
    bool success = m_businessController->deleteSceneStatistic(statId,operatorUser);
    if (success) {
        loadStatistics(0);
    }
    return success;
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