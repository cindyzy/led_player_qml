// entities/windowview.cpp
#include "windowview.h"
#include "../../utils/datetimehelper.h"
#include <QSqlRecord>

namespace LEDDB {

WindowView::WindowView(int windowId, int programId, const QString& windowName,
                       int xPos, int yPos, int width, int height, int zIndex,
                       int status, int blendType, const QString& windowColor,
                       int lockPosition, int playCount,
                       const QDateTime& createTime, const QDateTime& updateTime)
    : m_windowId(windowId), m_programId(programId), m_windowName(windowName),
    m_xPos(xPos), m_yPos(yPos), m_width(width), m_height(height), m_zIndex(zIndex),
    m_status(status), m_blendType(blendType), m_windowColor(windowColor),
    m_lockPosition(lockPosition), m_playCount(playCount),
    m_createTime(createTime), m_updateTime(updateTime) {}

WindowView WindowView::fromSqlRecord(const QSqlRecord& rec)
{
    WindowView wv;
    wv.setWindowId(rec.value("window_id").toInt());
    wv.setProgramId(rec.value("program_id").toInt());
    wv.setWindowName(rec.value("window_name").toString());
    wv.setXPos(rec.value("x_pos").toInt());
    wv.setYPos(rec.value("y_pos").toInt());
    wv.setWidth(rec.value("width").toInt());
    wv.setHeight(rec.value("height").toInt());
    wv.setZIndex(rec.value("z_index").toInt());
    wv.setStatus(rec.value("status").toInt());
    wv.setBlendType(rec.value("blend_type").toInt());
    wv.setWindowColor(rec.value("window_color").toString());
    wv.setLockPosition(rec.value("lock_position").toInt());
    wv.setPlayCount(rec.value("play_count").toInt());
    wv.setCreateTime(fromIsoString(rec.value("create_time").toString()));
    wv.setUpdateTime(fromIsoString(rec.value("update_time").toString()));
    return wv;
}

} // namespace LEDDB