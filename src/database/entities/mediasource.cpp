#include "mediasource.h"

// entities/mediasource.cpp
#include "../../utils/datetimehelper.h"
#include <QSqlRecord>

namespace LEDDB {

MediaSource::MediaSource(int mediaId, const QString& filePath, const QString& fileType,
                         double duration, const QString& qualityParam, const QString& aiEditParam,
                         const QDateTime& createTime, int windowId, int mediaSort)
    : m_mediaId(mediaId), m_filePath(filePath), m_fileType(fileType), m_duration(duration),
    m_qualityParam(qualityParam), m_aiEditParam(aiEditParam), m_createTime(createTime),
    m_windowId(windowId), m_mediaSort(mediaSort) {}

MediaSource MediaSource::fromSqlRecord(const QSqlRecord& rec)
{
    MediaSource ms;
    ms.setMediaId(rec.value("media_id").toInt());
    ms.setFilePath(rec.value("file_path").toString());
    ms.setFileType(rec.value("file_type").toString());
    ms.setDuration(rec.value("duration").toDouble());
    ms.setQualityParam(rec.value("quality_param").toString());
    ms.setAiEditParam(rec.value("ai_edit_param").toString());
    ms.setCreateTime(fromIsoString(rec.value("create_time").toString()));
    ms.setWindowId(rec.value("window_id").toInt());
    ms.setMediaSort(rec.value("media_sort").toInt());
    return ms;
}

} // namespace LEDDB