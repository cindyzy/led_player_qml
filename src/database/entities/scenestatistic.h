#ifndef SCENESTATISTIC_H
#define SCENESTATISTIC_H

// entities/scenestatistic.h
#pragma once
#include <QString>
#include <QDateTime>
#include <QSqlRecord>
namespace LEDDB {

class SceneStatistic {
public:
    SceneStatistic() = default;
    SceneStatistic(int statId, int projectId, const QString& sceneType,
                   const QDateTime& collectTime, int envBrightness,
                   const QString& sceneStatus, const QString& scheduleResult,
                   int playCount, double totalDuration, const QDate& statDate,
                   const QDateTime& createTime, const QDateTime& updateTime);

    // ---------- getters ----------
    int statId() const { return m_statId; }
    int projectId() const { return m_projectId; }
    QString sceneType() const { return m_sceneType; }
    QDateTime collectTime() const { return m_collectTime; }
    int envBrightness() const { return m_envBrightness; }
    QString sceneStatus() const { return m_sceneStatus; }
    QString scheduleResult() const { return m_scheduleResult; }
    int playCount() const { return m_playCount; }
    double totalDuration() const { return m_totalDuration; }
    QDate statDate() const { return m_statDate; }
    QDateTime createTime() const { return m_createTime; }
    QDateTime updateTime() const { return m_updateTime; }

    // ---------- setters ----------
    void setStatId(int id) { m_statId = id; }
    void setProjectId(int id) { m_projectId = id; }
    void setSceneType(const QString& type) { m_sceneType = type; }
    void setCollectTime(const QDateTime& dt) { m_collectTime = dt; }
    void setEnvBrightness(int brightness) { m_envBrightness = brightness; }
    void setSceneStatus(const QString& status) { m_sceneStatus = status; }
    void setScheduleResult(const QString& result) { m_scheduleResult = result; }
    void setPlayCount(int count) { m_playCount = count; }
    void setTotalDuration(double duration) { m_totalDuration = duration; }
    void setStatDate(const QDate& date) { m_statDate = date; }
    void setCreateTime(const QDateTime& dt) { m_createTime = dt; }
    void setUpdateTime(const QDateTime& dt) { m_updateTime = dt; }

    // 从 SQL 查询记录构建对象
    static SceneStatistic fromSqlRecord(const QSqlRecord& record);

private:
    int m_statId = 0;               // 统计ID（主键）
    int m_projectId = 0;            // 关联项目ID
    QString m_sceneType;            // 场景类型（如 "concert", "sports"）
    QDateTime m_collectTime;        // 数据采集时间（保留原字段）
    int m_envBrightness = 0;        // 环境亮度
    QString m_sceneStatus;          // 场景状态标签
    QString m_scheduleResult;       // 调度执行结果
    int m_playCount = 0;            // 播放次数（新增）
    double m_totalDuration = 0.0;   // 累计播放时长（秒）（新增）
    QDate m_statDate;               // 统计日期（新增，按天聚合）
    QDateTime m_createTime;         // 创建时间（新增）
    QDateTime m_updateTime;         // 更新时间（新增）
};

} // namespace LEDDB

#endif // SCENESTATISTIC_H
