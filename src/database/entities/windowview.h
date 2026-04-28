#ifndef WINDOWVIEW_H
#define WINDOWVIEW_H

// entities/windowview.h
#pragma once
#include <QString>
#include <QDateTime>
#include <QSqlRecord>
namespace LEDDB {

class WindowView {
public:
    WindowView() = default;
    WindowView(int windowId, int programId, const QString& windowName,
               int xPos, int yPos, int width, int height, int zIndex,
               int status, const QDateTime& createTime, const QDateTime& updateTime);

    int windowId() const { return m_windowId; }
    void setWindowId(int id) { m_windowId = id; }

    int programId() const { return m_programId; }
    void setProgramId(int id) { m_programId = id; }

    QString windowName() const { return m_windowName; }
    void setWindowName(const QString& name) { m_windowName = name; }

    int xPos() const { return m_xPos; }
    void setXPos(int x) { m_xPos = x; }

    int yPos() const { return m_yPos; }
    void setYPos(int y) { m_yPos = y; }

    int width() const { return m_width; }
    void setWidth(int w) { m_width = w; }

    int height() const { return m_height; }
    void setHeight(int h) { m_height = h; }

    int zIndex() const { return m_zIndex; }
    void setZIndex(int z) { m_zIndex = z; }

    int status() const { return m_status; }
    void setStatus(int status) { m_status = status; }  // 0隐藏 1显示

    QDateTime createTime() const { return m_createTime; }
    void setCreateTime(const QDateTime& dt) { m_createTime = dt; }

    QDateTime updateTime() const { return m_updateTime; }
    void setUpdateTime(const QDateTime& dt) { m_updateTime = dt; }

    static WindowView fromSqlRecord(const QSqlRecord& record);

private:
    int m_windowId = 0;
    int m_programId = 0;
    QString m_windowName;
    int m_xPos = 0;
    int m_yPos = 0;
    int m_width = 1920;
    int m_height = 1080;
    int m_zIndex = 0;
    int m_status = 1;
    QDateTime m_createTime;
    QDateTime m_updateTime;
};

} // namespace LEDDB

#endif // WINDOWVIEW_H
