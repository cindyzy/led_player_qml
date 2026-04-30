#include "MediaSourceModel.h"
#include <QDebug>
#include <QFileInfo>

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
    QList<LEDDB::MediaSource> medias;
    if (windowId > 0) {
        medias = m_businessController->getMediaByWindow(windowId);
    }
    beginResetModel();
    m_medias = medias;
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
                                 double duration, const QString& mediaType, const QString& thumbnailPath, const QString& operatorUser)
{
    if (!m_businessController) {
        qDebug() << "MediaSourceModel: BusinessController not set!";
        return false;
    }
    // 解析文件扩展名作为 fileType
    QFileInfo fileInfo(filePath);
    QString fileType = fileInfo.suffix().toLower();
    
    bool success = m_businessController->addMedia(windowId, filePath, fileType, duration, 0, operatorUser);
    if (success) {
        loadMedias(windowId);
    }
    return success;
}

bool MediaSourceModel::updateMedia(int mediaId, const QString& mediaName, double duration, int status, const QString& operatorUser)
{
    if (!m_businessController) {
        qDebug() << "MediaSourceModel: BusinessController not set!";
        return false;
    }
    auto optMedia = m_businessController->getMediaById(mediaId);
    if (!optMedia.has_value()) {
        return false;
    }
    LEDDB::MediaSource media = optMedia.value();
    
    bool success = m_businessController->updateMedia(mediaId, media.filePath(), media.fileType(), duration, media.mediaSort(), mediaName, status, operatorUser);
    if (success) {
        loadMedias(0);
    }
    return success;
}

bool MediaSourceModel::deleteMedia(int mediaId, const QString& operatorUser)
{
    if (!m_businessController) {
        qDebug() << "MediaSourceModel: BusinessController not set!";
        return false;
    }
    bool success = m_businessController->deleteMedia(mediaId, operatorUser);
    if (success) {
        loadMedias(0);
    }
    return success;
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