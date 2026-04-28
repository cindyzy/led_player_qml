#ifndef MEDIASOURCE_H
#define MEDIASOURCE_H

// entities/mediasource.h
#pragma once
#include <QString>
#include <QDateTime>
#include <QSqlRecord>
namespace LEDDB {

class MediaSource {
public:
    MediaSource() = default;
    MediaSource(int mediaId, const QString& filePath, const QString& fileType,
                double duration, const QString& qualityParam, const QString& aiEditParam,
                const QDateTime& createTime, int windowId, int mediaSort);

    int mediaId() const { return m_mediaId; }
    void setMediaId(int id) { m_mediaId = id; }

    QString filePath() const { return m_filePath; }
    void setFilePath(const QString& path) { m_filePath = path; }

    QString fileType() const { return m_fileType; }
    void setFileType(const QString& type) { m_fileType = type; }

    double duration() const { return m_duration; }
    void setDuration(double sec) { m_duration = sec; }

    QString qualityParam() const { return m_qualityParam; }
    void setQualityParam(const QString& param) { m_qualityParam = param; }

    QString aiEditParam() const { return m_aiEditParam; }
    void setAiEditParam(const QString& param) { m_aiEditParam = param; }

    QDateTime createTime() const { return m_createTime; }
    void setCreateTime(const QDateTime& dt) { m_createTime = dt; }

    int windowId() const { return m_windowId; }
    void setWindowId(int id) { m_windowId = id; }

    int mediaSort() const { return m_mediaSort; }
    void setMediaSort(int sort) { m_mediaSort = sort; }

    static MediaSource fromSqlRecord(const QSqlRecord& record);

private:
    int m_mediaId = 0;
    QString m_filePath;
    QString m_fileType;
    double m_duration = 0.0;
    QString m_qualityParam;   // JSON
    QString m_aiEditParam;    // JSON
    QDateTime m_createTime;
    int m_windowId = 0;
    int m_mediaSort = 0;
};

} // namespace LEDDB
#endif // MEDIASOURCE_H
