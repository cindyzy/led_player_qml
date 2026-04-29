#include "MediaSourceModel.h"
#include <QDebug>

MediaSourceModel::MediaSourceModel(QObject* parent) : QAbstractListModel(parent)
{
}

void MediaSourceModel::setBusinessController(BusinessController* controller)
{
    m_businessController = controller;
}

bool MediaSourceModel::loadMedias(int windowId)
{
    if (!m_businessController) {
        qDebug() << "MediaSourceModel: BusinessController not set!";
        return false;
    }
    beginResetModel();
    m_medias.clear();
    endResetModel();
    emit countChanged();
    return true;
}

QVariant MediaSourceModel::getMediaData(int index) const
{
    if (index < 0 || index >= m_medias.size()) return QVariant();
    const LEDDB::MediaSource& media = m_medias[index];
    QVariantMap map;
    map["mediaId"] = media.mediaId();
    map["windowId"] = media.windowId();
    map["filePath"] = media.filePath();
    map["mediaName"] = media.mediaName();
    map["duration"] = media.duration();
    map["mediaType"] = media.mediaType();
    map["thumbnailPath"] = media.thumbnailPath();
    map["status"] = media.status();
    map["createTime"] = media.createTime().toString();
    map["updateTime"] = media.updateTime().toString();
    return map;
}

bool MediaSourceModel::addMedia(int windowId, const QString& filePath, const QString& mediaName,
                                 double duration, int mediaType, const QString& thumbnailPath)
{
    if (!m_businessController) {
        qDebug() << "MediaSourceModel: BusinessController not set!";
        return false;
    }
    qDebug() << "MediaSourceModel: addMedia called -" << mediaName;
    return true;
}

bool MediaSourceModel::updateMedia(int mediaId, const QString& mediaName, double duration, int status)
{
    if (!m_businessController) {
        qDebug() << "MediaSourceModel: BusinessController not set!";
        return false;
    }
    qDebug() << "MediaSourceModel: updateMedia called -" << mediaId;
    return true;
}

bool MediaSourceModel::deleteMedia(int mediaId)
{
    if (!m_businessController) {
        qDebug() << "MediaSourceModel: BusinessController not set!";
        return false;
    }
    qDebug() << "MediaSourceModel: deleteMedia called -" << mediaId;
    return true;
}

QVariant MediaSourceModel::findMediaById(int mediaId) const
{
    for (int i = 0; i < m_medias.size(); ++i) {
        if (m_medias[i].mediaId() == mediaId) {
            return getMediaData(i);
        }
    }
    return QVariant();
}

int MediaSourceModel::rowCount(const QModelIndex& parent) const
{
    Q_UNUSED(parent);
    return m_medias.size();
}

QVariant MediaSourceModel::data(const QModelIndex& index, int role) const
{
    if (!index.isValid() || index.row() >= m_medias.size()) return QVariant();
    const LEDDB::MediaSource& media = m_medias[index.row()];
    switch (role) {
    case MediaIdRole: return media.mediaId();
    case WindowIdRole: return media.windowId();
    case FilePathRole: return media.filePath();
    case MediaNameRole: return media.mediaName();
    case DurationRole: return media.duration();
    case MediaTypeRole: return media.mediaType();
    case ThumbnailPathRole: return media.thumbnailPath();
    case StatusRole: return media.status();
    case CreateTimeRole: return media.createTime();
    case UpdateTimeRole: return media.updateTime();
    default: return QVariant();
    }
}

QHash<int, QByteArray> MediaSourceModel::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[MediaIdRole] = "mediaId";
    roles[WindowIdRole] = "windowId";
    roles[FilePathRole] = "filePath";
    roles[MediaNameRole] = "mediaName";
    roles[DurationRole] = "duration";
    roles[MediaTypeRole] = "mediaType";
    roles[ThumbnailPathRole] = "thumbnailPath";
    roles[StatusRole] = "status";
    roles[CreateTimeRole] = "createTime";
    roles[UpdateTimeRole] = "updateTime";
    return roles;
}