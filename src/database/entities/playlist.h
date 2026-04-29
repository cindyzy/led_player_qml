#ifndef PLAYLIST_H
#define PLAYLIST_H

// entities/playlist.h
#pragma once
#include <QString>
#include <QDateTime>
#include <QSqlRecord>
namespace LEDDB {

class PlayList {
public:
    PlayList() = default;
    PlayList(int listId, int projectId, const QString& listName, int playSort,
             int loopType, int status, const QDateTime& createTime, const QDateTime& updateTime,
             int programCount = 0, long long totalFrames = 0, double totalDuration = 0.0);

    int listId() const { return m_listId; }
    void setListId(int id) { m_listId = id; }

    int projectId() const { return m_projectId; }
    void setProjectId(int id) { m_projectId = id; }

    QString listName() const { return m_listName; }
    void setListName(const QString& name) { m_listName = name; }

    int playSort() const { return m_playSort; }
    void setPlaySort(int sort) { m_playSort = sort; }

    int loopType() const { return m_loopType; }
    void setLoopType(int type) { m_loopType = type; } // 0单次 1循环

    int status() const { return m_status; }
    void setStatus(int status) { m_status = status; } // 0禁用 1启用

    QDateTime createTime() const { return m_createTime; }
    void setCreateTime(const QDateTime& dt) { m_createTime = dt; }

    QDateTime updateTime() const { return m_updateTime; }
    void setUpdateTime(const QDateTime& dt) { m_updateTime = dt; }

    // 新增字段
    int programCount() const { return m_programCount; }
    void setProgramCount(int count) { m_programCount = count; }

    long long totalFrames() const { return m_totalFrames; }
    void setTotalFrames(long long frames) { m_totalFrames = frames; }

    double totalDuration() const { return m_totalDuration; }
    void setTotalDuration(double duration) { m_totalDuration = duration; }

    /**
     * @brief 从 SQL 查询记录（QSqlRecord）构建 PlayList 对象
     * @param record 包含所有字段的查询记录
     * @return 填充后的 PlayList 对象
     */
    static PlayList fromSqlRecord(const QSqlRecord& record);

private:
    int m_listId = 0;           // 播放列表唯一ID（主键，自增）
    int m_projectId = 0;        // 所属项目ID，关联 project_config 表
    QString m_listName;         // 播放列表名称
    int m_playSort = 0;         // 排序序号，控制项目内播放列表的显示顺序
    int m_loopType = 1;         // 循环模式：0-单次，1-循环（默认循环）
    int m_status = 1;           // 状态：0-禁用，1-启用（默认启用）
    QDateTime m_createTime;     // 创建时间（数据库自动生成）
    QDateTime m_updateTime;     // 最后更新时间（业务逻辑更新）
    
    // 新增字段
    int m_programCount = 0;     // 节目数量
    long long m_totalFrames = 0; // 总帧数
    double m_totalDuration = 0.0; // 总时长（秒）
};

} // namespace LEDDB

#endif // PLAYLIST_H
