#include "mediasource.h"

// entities/mediasource.cpp
#include "../../utils/datetimehelper.h"
#include <QSqlRecord>

namespace LEDDB {

MediaSource::MediaSource(int mediaId, const QString& mediaName, const QString& filePath,
                         const QString& fileType, const QString& mediaType,
                         double duration, const QString& qualityParam, const QString& aiEditParam,
                         const QString& thumbnailPath, int status,
                         const QDateTime& createTime, const QDateTime& updateTime,
                         int windowId, int mediaSort, long long frames)
    : m_mediaId(mediaId)
    , m_mediaName(mediaName)
    , m_filePath(filePath)
    , m_fileType(fileType)
    , m_mediaType(mediaType)
    , m_duration(duration)
    , m_qualityParam(qualityParam)
    , m_aiEditParam(aiEditParam)
    , m_thumbnailPath(thumbnailPath)
    , m_status(status)
    , m_createTime(createTime)
    , m_updateTime(updateTime)
    , m_windowId(windowId)
    , m_mediaSort(mediaSort)
    , m_frames(frames)
{
}

MediaSource MediaSource::fromSqlRecord(const QSqlRecord& record)
{
    MediaSource ms;
    ms.setMediaId(record.value("media_id").toInt());
    ms.setMediaName(record.value("media_name").toString());
    ms.setFilePath(record.value("file_path").toString());
    ms.setFileType(record.value("file_type").toString());
    ms.setMediaType(record.value("media_type").toString());
    ms.setDuration(record.value("duration").toDouble());
    ms.setQualityParam(record.value("quality_param").toString());
    ms.setAiEditParam(record.value("ai_edit_param").toString());
    ms.setThumbnailPath(record.value("thumbnail_path").toString());
    ms.setStatus(record.value("status").toInt());
    ms.setCreateTime(fromIsoString(record.value("create_time").toString()));
    ms.setUpdateTime(fromIsoString(record.value("update_time").toString()));
    ms.setWindowId(record.value("window_id").toInt());
    ms.setMediaSort(record.value("media_sort").toInt());
    ms.setFrames(record.value("frames").toLongLong());
    return ms;
}

} // namespace LEDDB