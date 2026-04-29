// entities/programinfo.cpp
#include "programinfo.h"
#include "../../utils/datetimehelper.h"
#include <QSqlRecord>

namespace LEDDB {

ProgramInfo::ProgramInfo(int programId, int listId, const QString& programName, int programSort,
                         double playDuration, double intervalTime, int status,
                         const QDateTime& createTime, const QDateTime& updateTime, const QDateTime& startTime, const QDateTime& endTime)
    : m_programId(programId), m_listId(listId), m_programName(programName),
    m_programSort(programSort), m_playDuration(playDuration), m_intervalTime(intervalTime),
    m_status(status), m_createTime(createTime), m_updateTime(updateTime), m_startTime(startTime), m_endTime(endTime) {}

ProgramInfo ProgramInfo::fromSqlRecord(const QSqlRecord& rec)
{
    ProgramInfo pi;
    pi.setProgramId(rec.value("program_id").toInt());
    pi.setListId(rec.value("list_id").toInt());
    pi.setProgramName(rec.value("program_name").toString());
    pi.setProgramSort(rec.value("program_sort").toInt());
    pi.setPlayDuration(rec.value("play_duration").toDouble());
    pi.setIntervalTime(rec.value("interval_time").toDouble());
    pi.setStatus(rec.value("status").toInt());
    pi.setCreateTime(fromIsoString(rec.value("create_time").toString()));
    pi.setUpdateTime(fromIsoString(rec.value("update_time").toString()));
    pi.setStartTime(fromIsoString(rec.value("start_time").toString()));
    pi.setEndTime(fromIsoString(rec.value("end_time").toString()));
    return pi;
}



} // namespace LEDDB