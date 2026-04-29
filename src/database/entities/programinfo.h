#ifndef PROGRAMINFO_H
#define PROGRAMINFO_H

// entities/programinfo.h
#pragma once
#include <QString>
#include <QDateTime>
#include <QSqlRecord>
namespace LEDDB {

class ProgramInfo {
public:
    ProgramInfo() = default;
    ProgramInfo(int programId, int listId, const QString& programName, int programSort,
                double playDuration, double intervalTime, int status,
                const QDateTime& createTime, const QDateTime& updateTime, const QDateTime& startTime, const QDateTime& endTime);

    int programId() const { return m_programId; }
    void setProgramId(int id) { m_programId = id; }

    int listId() const { return m_listId; }
    void setListId(int id) { m_listId = id; }

    QString programName() const { return m_programName; }
    void setProgramName(const QString& name) { m_programName = name; }

    int programSort() const { return m_programSort; }
    void setProgramSort(int sort) { m_programSort = sort; }

    double playDuration() const { return m_playDuration; }
    void setPlayDuration(double sec) { m_playDuration = sec; }

    double intervalTime() const { return m_intervalTime; }
    void setIntervalTime(double sec) { m_intervalTime = sec; }

    int status() const { return m_status; }
    void setStatus(int status) { m_status = status; }

    QDateTime createTime() const { return m_createTime; }
    void setCreateTime(const QDateTime& dt) { m_createTime = dt; }

    QDateTime updateTime() const { return m_updateTime; }
    void setUpdateTime(const QDateTime& dt) { m_updateTime = dt; }

    QDateTime startTime() const{ return m_startTime; }
    void setStartTime(const QDateTime &dt){ m_startTime = dt; }

    QDateTime endTime() const{ return m_endTime; }
    void setEndTime(const QDateTime &dt){ m_endTime = dt; }

    static ProgramInfo fromSqlRecord(const QSqlRecord& record);


private:
    int m_programId = 0;
    int m_listId = 0;
    QString m_programName;
    int m_programSort = 0;
    double m_playDuration = 0.0;
    double m_intervalTime = 0.0;
    int m_status = 1;
    QDateTime m_createTime;
    QDateTime m_updateTime;
    QDateTime m_startTime;
    QDateTime m_endTime;
};

} // namespace LEDDB
#endif // PROGRAMINFO_H
