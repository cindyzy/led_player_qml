#ifndef WINDOWVIEW_H
#define WINDOWVIEW_H

// entities/windowview.h
#pragma once

#include <QString>
#include <QDateTime>
#include <QSqlRecord>

namespace LEDDB {

/**
 * @brief 窗口视图实体类
 *
 * 对应数据库中的窗口视图表，描述一个显示窗口的位置、大小、层次等属性。
 * 主要用于 LED 大屏的内容布局管理。
 */
class WindowView {
public:
    /// 默认构造函数
    WindowView() = default;

    /**
     * @brief 带参数的构造函数
     * @param windowId   窗口唯一标识
     * @param programId  所属节目ID
     * @param windowName 窗口名称
     * @param xPos       左上角 X 坐标
     * @param yPos       左上角 Y 坐标
     * @param width      窗口宽度
     * @param height     窗口高度
     * @param zIndex     窗口 Z 序（层叠顺序）
     * @param status     状态：0-隐藏，1-显示
     * @param blendType  混合类型：0-正常，1-叠加，2-相乘
     * @param windowColor 视窗颜色（十六进制颜色值）
     * @param lockPosition 锁定位置：0-未锁定，1-锁定
     * @param playCount  播放次数
     * @param createTime 创建时间
     * @param updateTime 最后更新时间
     */
    WindowView(int windowId, int programId, const QString& windowName,
               int xPos, int yPos, int width, int height, int zIndex,
               int status, int blendType, const QString& windowColor,
               int lockPosition, int playCount,
               const QDateTime& createTime, const QDateTime& updateTime);

    // ────── 窗口ID ──────
    int windowId() const { return m_windowId; }
    void setWindowId(int id) { m_windowId = id; }

    // ────── 所属节目ID ──────
    int programId() const { return m_programId; }
    void setProgramId(int id) { m_programId = id; }

    // ────── 窗口名称 ──────
    QString windowName() const { return m_windowName; }
    void setWindowName(const QString& name) { m_windowName = name; }

    // ────── X坐标 ──────
    int xPos() const { return m_xPos; }
    void setXPos(int x) { m_xPos = x; }

    // ────── Y坐标 ──────
    int yPos() const { return m_yPos; }
    void setYPos(int y) { m_yPos = y; }

    // ────── 宽度 ──────
    int width() const { return m_width; }
    void setWidth(int w) { m_width = w; }

    // ────── 高度 ──────
    int height() const { return m_height; }
    void setHeight(int h) { m_height = h; }

    // ────── Z序（层叠顺序）──────
    int zIndex() const { return m_zIndex; }
    void setZIndex(int z) { m_zIndex = z; }

    // ────── 状态：0-隐藏，1-显示 ──────
    int status() const { return m_status; }
    void setStatus(int status) { m_status = status; }

    // ────── 混合类型：0-正常，1-叠加，2-相乘 ──────
    int blendType() const { return m_blendType; }
    void setBlendType(int type) { m_blendType = type; }

    // ────── 视窗颜色（十六进制颜色值）──────
    QString windowColor() const { return m_windowColor; }
    void setWindowColor(const QString& color) { m_windowColor = color; }

    // ────── 锁定位置：0-未锁定，1-锁定 ──────
    int lockPosition() const { return m_lockPosition; }
    void setLockPosition(int lock) { m_lockPosition = lock; }

    // ────── 播放次数 ──────
    int playCount() const { return m_playCount; }
    void setPlayCount(int count) { m_playCount = count; }

    // ────── 创建时间 ──────
    QDateTime createTime() const { return m_createTime; }
    void setCreateTime(const QDateTime& dt) { m_createTime = dt; }

    // ────── 最后更新时间 ──────
    QDateTime updateTime() const { return m_updateTime; }
    void setUpdateTime(const QDateTime& dt) { m_updateTime = dt; }

    /**
     * @brief 从 SQL 查询记录中构建 WindowView 对象
     * @param record QSqlRecord 对象，包含所有字段
     * @return 填充后的 WindowView 实例
     */
    static WindowView fromSqlRecord(const QSqlRecord& record);

private:
    int m_windowId = 0;       ///< 窗口唯一标识（主键）
    int m_programId = 0;      ///< 所属节目ID，关联 Program 表
    QString m_windowName;     ///< 窗口名称，便于识别
    int m_xPos = 0;           ///< 窗口左上角 X 坐标（像素）
    int m_yPos = 0;           ///< 窗口左上角 Y 坐标（像素）
    int m_width = 1920;       ///< 窗口宽度（像素），默认1920（常见LED屏宽）
    int m_height = 1080;      ///< 窗口高度（像素），默认1080（常见LED屏高）
    int m_zIndex = 0;         ///< 窗口 Z 序，值越大越靠上
    int m_status = 1;         ///< 窗口状态：0-隐藏，1-显示，默认为显示
    int m_blendType = 0;      ///< 混合类型：0-正常，1-叠加，2-相乘
    QString m_windowColor;    ///< 视窗颜色（十六进制颜色值）
    int m_lockPosition = 0;    ///< 锁定位置：0-未锁定，1-锁定
    int m_playCount = 0;       ///< 播放次数
    QDateTime m_createTime;   ///< 记录创建时间戳
    QDateTime m_updateTime;   ///< 记录最后修改时间戳
};

} // namespace LEDDB

#endif // WINDOWVIEW_H