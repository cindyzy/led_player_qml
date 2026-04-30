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
    MediaSource(int mediaId, const QString& mediaName, const QString& filePath,
                const QString& fileType, const QString& mediaType,
                double duration, const QString& qualityParam, const QString& aiEditParam,
                const QString& thumbnailPath, int status,
                const QDateTime& createTime, const QDateTime& updateTime,
                int windowId, int mediaSort, long long frames = 0);

    // ---------- getters ----------
    int mediaId() const { return m_mediaId; }
    QString mediaName() const { return m_mediaName; }
    QString filePath() const { return m_filePath; }
    QString fileType() const { return m_fileType; }
    QString mediaType() const { return m_mediaType; }
    double duration() const { return m_duration; }
    QString qualityParam() const { return m_qualityParam; }
    QString aiEditParam() const { return m_aiEditParam; }
    QString thumbnailPath() const { return m_thumbnailPath; }
    int status() const { return m_status; }
    QDateTime createTime() const { return m_createTime; }
    QDateTime updateTime() const { return m_updateTime; }
    int windowId() const { return m_windowId; }
    int mediaSort() const { return m_mediaSort; }
    long long frames() const { return m_frames; }

    // ---------- setters ----------
    void setMediaId(int id) { m_mediaId = id; }
    void setMediaName(const QString& name) { m_mediaName = name; }
    void setFilePath(const QString& path) { m_filePath = path; }
    void setFileType(const QString& type) { m_fileType = type; }
    void setMediaType(const QString& type) { m_mediaType = type; }
    void setDuration(double sec) { m_duration = sec; }
    void setQualityParam(const QString& param) { m_qualityParam = param; }
    void setAiEditParam(const QString& param) { m_aiEditParam = param; }
    void setThumbnailPath(const QString& path) { m_thumbnailPath = path; }
    void setStatus(int status) { m_status = status; }
    void setCreateTime(const QDateTime& dt) { m_createTime = dt; }
    void setUpdateTime(const QDateTime& dt) { m_updateTime = dt; }
    void setWindowId(int id) { m_windowId = id; }
    void setMediaSort(int sort) { m_mediaSort = sort; }
    void setFrames(long long frames) { m_frames = frames; }

    static MediaSource fromSqlRecord(const QSqlRecord& record);

private:
    int m_mediaId = 0;
    QString m_mediaName;            // 素材显示名称
    QString m_filePath;             // 文件路径
    QString m_fileType;             // 文件格式（扩展名）
    QString m_mediaType;            // 素材类型（图片/视频/音频/流媒体等）
    double m_duration = 0.0;        // 时长（秒）
    QString m_qualityParam;         // 画质参数 JSON
    QString m_aiEditParam;          // AI 编辑参数 JSON
    QString m_thumbnailPath;        // 缩略图路径
    int m_status = 1;               // 状态：0-禁用，1-正常
    QDateTime m_createTime;
    QDateTime m_updateTime;         // 最后更新时间
    int m_windowId = 0;             // 所属视窗 ID
    int m_mediaSort = 0;            // 播放排序序号
    long long m_frames = 0;         // 帧数
};

} // namespace LEDDB
#endif // MEDIASOURCE_H
