// entities/playlist.cpp
#include "playlist.h"
#include "../../utils/datetimehelper.h"
#include <QSqlRecord>

namespace LEDDB {

PlayList::PlayList(int listId, int projectId, const QString& listName, int playSort,
                   int loopType, int status, const QDateTime& createTime, const QDateTime& updateTime,
                   int programCount, long long totalFrames, double totalDuration)
    : m_listId(listId), m_projectId(projectId), m_listName(listName), m_playSort(playSort),
    m_loopType(loopType), m_status(status), m_createTime(createTime), m_updateTime(updateTime),
    m_programCount(programCount), m_totalFrames(totalFrames), m_totalDuration(totalDuration) {}

PlayList PlayList::fromSqlRecord(const QSqlRecord& rec)
{
    PlayList pl;
    pl.setListId(rec.value("list_id").toInt());
    pl.setProjectId(rec.value("project_id").toInt());
    pl.setListName(rec.value("list_name").toString());
    pl.setPlaySort(rec.value("play_sort").toInt());
    pl.setLoopType(rec.value("loop_type").toInt());
    pl.setStatus(rec.value("status").toInt());
    pl.setCreateTime(fromIsoString(rec.value("create_time").toString()));
    pl.setUpdateTime(fromIsoString(rec.value("update_time").toString()));
    
    // 新增字段
    pl.setProgramCount(rec.value("program_count").toInt());
    pl.setTotalFrames(rec.value("total_frames").toLongLong());
    pl.setTotalDuration(rec.value("total_duration").toDouble());
    
    return pl;
}

} // namespace LEDDB