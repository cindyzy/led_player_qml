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
             int loopType, int status, const QDateTime& createTime, const QDateTime& updateTime);

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

    static PlayList fromSqlRecord(const QSqlRecord& record);

private:
    int m_listId = 0;
    int m_projectId = 0;
    QString m_listName;
    int m_playSort = 0;
    int m_loopType = 1;
    int m_status = 1;
    QDateTime m_createTime;
    QDateTime m_updateTime;
};

} // namespace LEDDB

#endif // PLAYLIST_H
