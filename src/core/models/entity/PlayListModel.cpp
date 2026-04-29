#include "PlayListModel.h"
#include <QDebug>

PlayListModel::PlayListModel(QObject* parent) : QAbstractListModel(parent)
{
}

void PlayListModel::setBusinessController(BusinessController* controller)
{
    m_businessController = controller;
}

bool PlayListModel::loadPlayLists(int projectId)
{
    if (!m_businessController) {
        qDebug() << "PlayListModel: BusinessController not set!";
        return false;
    }
    beginResetModel();
    m_playLists.clear();
    endResetModel();
    emit countChanged();
    return true;
}

QVariant PlayListModel::getPlayListData(int index) const
{
    if (index < 0 || index >= m_playLists.size()) return QVariant();
    const LEDDB::PlayList& pl = m_playLists[index];
    QVariantMap map;
    map["listId"] = pl.listId();
    map["projectId"] = pl.projectId();
    map["listName"] = pl.listName();
    map["playSort"] = pl.playSort();
    map["loopType"] = pl.loopType();
    map["status"] = pl.status();
    map["createTime"] = pl.createTime().toString();
    map["updateTime"] = pl.updateTime().toString();
    // 新增字段
    map["programCount"] = pl.programCount();
    map["totalFrames"] = pl.totalFrames();
    map["totalDuration"] = pl.totalDuration();
    return map;
}

bool PlayListModel::addPlayList(int projectId, const QString& listName, int playSort, int loopType)
{
    if (!m_businessController) {
        qDebug() << "PlayListModel: BusinessController not set!";
        return false;
    }

    qDebug() << "PlayListModel: addPlayList called -" << listName;
    return true;
}

bool PlayListModel::updatePlayList(int listId, const QString& listName, int playSort, int loopType, int status)
{
    if (!m_businessController) {
        qDebug() << "PlayListModel: BusinessController not set!";
        return false;
    }
    qDebug() << "PlayListModel: updatePlayList called -" << listId;
    return true;
}

bool PlayListModel::deletePlayList(int listId)
{
    if (!m_businessController) {
        qDebug() << "PlayListModel: BusinessController not set!";
        return false;
    }
    qDebug() << "PlayListModel: deletePlayList called -" << listId;
    return true;
}

QVariant PlayListModel::findPlayListById(int listId) const
{
    for (int i = 0; i < m_playLists.size(); ++i) {
        if (m_playLists[i].listId() == listId) {
            return getPlayListData(i);
        }
    }
    return QVariant();
}

int PlayListModel::rowCount(const QModelIndex& parent) const
{
    Q_UNUSED(parent);
    return m_playLists.size();
}

QVariant PlayListModel::data(const QModelIndex& index, int role) const
{
    if (!index.isValid() || index.row() >= m_playLists.size()) return QVariant();
    const LEDDB::PlayList& pl = m_playLists[index.row()];
    switch (role) {
    case ListIdRole: return pl.listId();
    case ProjectIdRole: return pl.projectId();
    case ListNameRole: return pl.listName();
    case PlaySortRole: return pl.playSort();
    case LoopTypeRole: return pl.loopType();
    case StatusRole: return pl.status();
    case CreateTimeRole: return pl.createTime();
    case UpdateTimeRole: return pl.updateTime();
    // 新增字段
    case ProgramCountRole: return pl.programCount();
    case TotalFramesRole: return pl.totalFrames();
    case TotalDurationRole: return pl.totalDuration();
    default: return QVariant();
    }
}

QHash<int, QByteArray> PlayListModel::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[ListIdRole] = "listId";
    roles[ProjectIdRole] = "projectId";
    roles[ListNameRole] = "listName";
    roles[PlaySortRole] = "playSort";
    roles[LoopTypeRole] = "loopType";
    roles[StatusRole] = "status";
    roles[CreateTimeRole] = "createTime";
    roles[UpdateTimeRole] = "updateTime";
    // 新增字段
    roles[ProgramCountRole] = "programCount";
    roles[TotalFramesRole] = "totalFrames";
    roles[TotalDurationRole] = "totalDuration";
    return roles;
}