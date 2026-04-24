// dmxcontroller.cpp
#include "dmxcontroller.h"
#include <QDateTime>
#include <QDebug>
#include <cmath>

DMXController::DMXController(QObject *parent)
    : QObject(parent)
    , m_channels(8, 0)
    , m_animationMode(ModeStatic)
    , m_animationTimer(nullptr)
    , m_autoSendEnabled(true)
    , m_timeCounter(0)
    , m_breathDirection(1)
    , m_breathValue(0)
    , m_chasePosition(0)
    , m_lastLogTime(0)
{
    initConnections();
    // 初始化为中等亮度示范
    for (int i = 0; i < 8; ++i) {
        m_channels[i] = (i + 1) * 32;
    }
    emitAllChannelSignals();
    sendCurrentPacket();
}

DMXController::~DMXController()
{
    if (m_animationTimer) {
        m_animationTimer->stop();
        delete m_animationTimer;
    }
}

void DMXController::initConnections()
{
    m_animationTimer = new QTimer(this);
    connect(m_animationTimer, &QTimer::timeout, this, &DMXController::updateAnimation);
    setAnimationMode(ModeStatic);
}

void DMXController::appendLog(const QString &msg)
{
    QString timestamp = QDateTime::currentDateTime().toString("hh:mm:ss.zzz");
    QString fullMsg = QString("[%1] %2").arg(timestamp, msg);
    m_logMessages.prepend(fullMsg);
    if (m_logMessages.size() > MAX_LOG_ENTRIES) {
        m_logMessages.removeLast();
    }
    emit logMessagesChanged();
}

void DMXController::generatePacketInfo(QString &packetDesc)
{
    // 符合DMX512-A标准数据包描述: 复位信号 + 复位后标记 + 起始码(0x00) + 数据字段
    packetDesc = QString("DMX512-A数据包 | 复位信号(Break) 92μs | 复位后标记(MAB) 12μs | 起始码: 00h (零起始码) | 字段: ");
    for (int i = 0; i < m_channels.size(); ++i) {
        if (i > 0) packetDesc += ", ";
        packetDesc += QString("CH%1=%2").arg(i + 1).arg(m_channels[i]);
    }
    packetDesc += QString(" | 校验: 无强制校验 | 符合EIA-485-A");
}

void DMXController::sendCurrentPacket()
{
    if (!m_autoSendEnabled && m_animationMode == ModeStatic) {
        // 手动模式且自动发送关闭，不主动记录日志防止杂乱，但可根据需求发送
        // 但为了演示效果依然可以发送不过减少日志频率，简单处理：默认总是发送
    }
    QString packetInfo;
    generatePacketInfo(packetInfo);
    appendLog(packetInfo);
    m_lastSendTime.restart();
}

void DMXController::clearLog()
{
    m_logMessages.clear();
    emit logMessagesChanged();
    appendLog("日志已清除");
}

void DMXController::resetAllChannels()
{
    stopAnimation();
    setAnimationMode(ModeStatic);
    for (int i = 0; i < m_channels.size(); ++i) {
        m_channels[i] = 0;
    }
    emitAllChannelSignals();
    sendCurrentPacket();
}

void DMXController::setAllChannels(int value)
{
    stopAnimation();
    setAnimationMode(ModeStatic);
    for (int i = 0; i < m_channels.size(); ++i) {
        m_channels[i] = qBound(0, value, 255);
    }
    emitAllChannelSignals();
    sendCurrentPacket();
}

void DMXController::setChannel0(int value)
{
    qDebug()<<"DMXController::setChannel0";
    if (m_channels[0] != value) {
        stopAnimation();
        if (m_animationMode != ModeStatic) {
            setAnimationMode(ModeStatic);
        }
        m_channels[0] = qBound(0, value, 255);
        emit channel0Changed();
        sendCurrentPacket();
    }
}

void DMXController::setChannel1(int value)
{
    if (m_channels[1] != value) {
        stopAnimation();
        if (m_animationMode != ModeStatic) {
            setAnimationMode(ModeStatic);
        }
        m_channels[1] = qBound(0, value, 255);
        emit channel1Changed();
        sendCurrentPacket();
    }
}

void DMXController::setChannel2(int value)
{
    if (m_channels[2] != value) {
        stopAnimation();
        if (m_animationMode != ModeStatic) {
            setAnimationMode(ModeStatic);
        }
        m_channels[2] = qBound(0, value, 255);
        emit channel2Changed();
        sendCurrentPacket();
    }
}

void DMXController::setChannel3(int value)
{
    if (m_channels[3] != value) {
        stopAnimation();
        if (m_animationMode != ModeStatic) {
            setAnimationMode(ModeStatic);
        }
        m_channels[3] = qBound(0, value, 255);
        emit channel3Changed();
        sendCurrentPacket();
    }
}

void DMXController::setChannel4(int value)
{
    if (m_channels[4] != value) {
        stopAnimation();
        if (m_animationMode != ModeStatic) {
            setAnimationMode(ModeStatic);
        }
        m_channels[4] = qBound(0, value, 255);
        emit channel4Changed();
        sendCurrentPacket();
    }
}

void DMXController::setChannel5(int value)
{
    if (m_channels[5] != value) {
        stopAnimation();
        if (m_animationMode != ModeStatic) {
            setAnimationMode(ModeStatic);
        }
        m_channels[5] = qBound(0, value, 255);
        emit channel5Changed();
        sendCurrentPacket();
    }
}

void DMXController::setChannel6(int value)
{
    if (m_channels[6] != value) {
        stopAnimation();
        if (m_animationMode != ModeStatic) {
            setAnimationMode(ModeStatic);
        }
        m_channels[6] = qBound(0, value, 255);
        emit channel6Changed();
        sendCurrentPacket();
    }
}

void DMXController::setChannel7(int value)
{
    if (m_channels[7] != value) {
        stopAnimation();
        if (m_animationMode != ModeStatic) {
            setAnimationMode(ModeStatic);
        }
        m_channels[7] = qBound(0, value, 255);
        emit channel7Changed();
        sendCurrentPacket();
    }
}

void DMXController::setAnimationMode(int mode)
{
    if (m_animationMode == mode)
        return;
    m_animationMode = mode;
    emit animationModeChanged();

    if (mode == ModeStatic) {
        stopAnimation();
    } else {
        startAnimation();
    }
}

void DMXController::setAutoSendEnabled(bool enabled)
{
    if (m_autoSendEnabled == enabled)
        return;
    m_autoSendEnabled = enabled;
    emit autoSendEnabledChanged();
    if (enabled && m_animationMode != ModeStatic) {
        // 重新激活动画时确保定时器运行
        startAnimation();
    }
}

void DMXController::updateAllChannels(const QVector<int> &newValues)
{
    bool changed = false;
    for (int i = 0; i < m_channels.size(); ++i) {
        if (m_channels[i] != newValues[i]) {
            m_channels[i] = newValues[i];
            changed = true;
        }
    }
    if (changed) {
        emitAllChannelSignals();
        sendCurrentPacket();
    }
}

void DMXController::emitAllChannelSignals()
{
    emit channel0Changed();
    emit channel1Changed();
    emit channel2Changed();
    emit channel3Changed();
    emit channel4Changed();
    emit channel5Changed();
    emit channel6Changed();
    emit channel7Changed();
}

void DMXController::stopAnimation()
{
    if (m_animationTimer && m_animationTimer->isActive()) {
        m_animationTimer->stop();
    }
}

void DMXController::startAnimation()
{
    if (m_animationMode != ModeStatic && m_autoSendEnabled) {
        if (!m_animationTimer->isActive()) {
            m_animationTimer->start(ANIMATION_INTERVAL_MS);
        }
    }
}


void DMXController::setChannels(const QVector<int> &newChannels)
{
    // 如果新旧数据完全相同，无需处理
    if (m_channels == newChannels)
        return;

    // 确保至少有一个通道大小匹配（这里假定长度固定为8，可根据需要调整）
    int size = qMin(m_channels.size(), newChannels.size());
    for (int i = 0; i < size; ++i) {
        if (m_channels[i] != newChannels[i]) {
            // 根据索引调用对应的 setChannelX
            switch (i) {
            case 0: setChannel0(newChannels[0]); break;
            case 1: setChannel1(newChannels[1]); break;
            case 2: setChannel2(newChannels[2]); break;
            case 3: setChannel3(newChannels[3]); break;
            case 4: setChannel4(newChannels[4]); break;
            case 5: setChannel5(newChannels[5]); break;
            case 6: setChannel6(newChannels[6]); break;
            case 7: setChannel7(newChannels[7]); break;
            default: break;
            }
        }
    }

    // 发射 channelsChanged 信号，通知 QML 等前端属性已变动
    emit channelsChanged();
}

QVector<int> DMXController::channels() const
{
    return m_channels;
}

void DMXController::updateAnimation()
{
    QVector<int> newValues = m_channels;

    switch (m_animationMode) {
    case ModeBreathing:
    {
        // 呼吸效果：所有通道同步正弦变化
        static int step = 0;
        step = (step + 2) % 512;
        int val = static_cast<int>(127.5 + 127.5 * sin(step * 3.14159 / 256.0));
        for (int i = 0; i < newValues.size(); ++i) {
            newValues[i] = val;
        }
        break;
    }
    case ModeRainbowWheel:
    {
        // 彩虹轮: 每个通道相位偏移
        static int phase = 0;
        phase = (phase + 4) % 360;
        for (int i = 0; i < newValues.size(); ++i) {
            double angle = (phase + i * 45) * 3.14159 / 180.0;
            int val = static_cast<int>(127.5 + 127.5 * sin(angle));
            newValues[i] = qBound(0, val, 255);
        }
        break;
    }
    case ModeChase:
    {
        // 跑马灯效果
        m_chasePosition = (m_chasePosition + 1) % (newValues.size() * 2);
        for (int i = 0; i < newValues.size(); ++i) {
            int dist = (i - m_chasePosition + newValues.size()) % newValues.size();
            if (dist < 2) newValues[i] = 255;
            else if (dist < 4) newValues[i] = 100;
            else newValues[i] = 0;
        }
        break;
    }
    case ModeSineWave:
    {
        // 正弦波浪
        static int t = 0;
        t = (t + 3) % 360;
        for (int i = 0; i < newValues.size(); ++i) {
            double angle = (t + i * 30) * 3.14159 / 180.0;
            int val = static_cast<int>(127.5 + 127.5 * sin(angle));
            newValues[i] = qBound(0, val, 255);
        }
        break;
    }
    default:
        return;
    }
    updateAllChannels(newValues);
}