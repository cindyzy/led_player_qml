// dmxcontroller.h (完整修正版)
#ifndef DMXCONTROLLER_H
#define DMXCONTROLLER_H

#include <QObject>
#include <QTimer>
#include <QStringList>
#include <QElapsedTimer>

class DMXController : public QObject
{
    Q_OBJECT
    Q_PROPERTY(int channel0 READ channel0 WRITE setChannel0 NOTIFY channel0Changed)
    Q_PROPERTY(int channel1 READ channel1 WRITE setChannel1 NOTIFY channel1Changed)
    Q_PROPERTY(int channel2 READ channel2 WRITE setChannel2 NOTIFY channel2Changed)
    Q_PROPERTY(int channel3 READ channel3 WRITE setChannel3 NOTIFY channel3Changed)
    Q_PROPERTY(int channel4 READ channel4 WRITE setChannel4 NOTIFY channel4Changed)
    Q_PROPERTY(int channel5 READ channel5 WRITE setChannel5 NOTIFY channel5Changed)
    Q_PROPERTY(int channel6 READ channel6 WRITE setChannel6 NOTIFY channel6Changed)
    Q_PROPERTY(int channel7 READ channel7 WRITE setChannel7 NOTIFY channel7Changed)
    Q_PROPERTY(int animationMode READ animationMode WRITE setAnimationMode NOTIFY animationModeChanged)
    Q_PROPERTY(QStringList logMessages READ logMessages NOTIFY logMessagesChanged)
    Q_PROPERTY(bool autoSendEnabled READ autoSendEnabled WRITE setAutoSendEnabled NOTIFY autoSendEnabledChanged)

public:
    explicit DMXController(QObject *parent = nullptr);
    ~DMXController();

    enum AnimationMode {
        ModeStatic = 0,
        ModeBreathing,
        ModeRainbowWheel,
        ModeChase,
        ModeSineWave
    };
    Q_ENUM(AnimationMode)

    int channel0() const { return m_channels[0]; }
    int channel1() const { return m_channels[1]; }
    int channel2() const { return m_channels[2]; }
    int channel3() const { return m_channels[3]; }
    int channel4() const { return m_channels[4]; }
    int channel5() const { return m_channels[5]; }
    int channel6() const { return m_channels[6]; }
    int channel7() const { return m_channels[7]; }
    int animationMode() const { return m_animationMode; }
    QStringList logMessages() const { return m_logMessages; }
    bool autoSendEnabled() const { return m_autoSendEnabled; }

    void setChannel0(int value);
    void setChannel1(int value);
    void setChannel2(int value);
    void setChannel3(int value);
    void setChannel4(int value);
    void setChannel5(int value);
    void setChannel6(int value);
    void setChannel7(int value);
    void setAnimationMode(int mode);
    void setAutoSendEnabled(bool enabled);

    QVector<int> channels() const;
    void setChannels(const QVector<int> &newChannels);

public slots:
    void resetAllChannels();
    void setAllChannels(int value);
    void sendCurrentPacket();
    void clearLog();

signals:
    void channel0Changed();
    void channel1Changed();
    void channel2Changed();
    void channel3Changed();
    void channel4Changed();
    void channel5Changed();
    void channel6Changed();
    void channel7Changed();
    void animationModeChanged();
    void logMessagesChanged();
    void autoSendEnabledChanged();

    void channelsChanged();

private slots:
    void updateAnimation();

private:
    void initConnections();
    void appendLog(const QString &msg);
    void generatePacketInfo(QString &packetDesc);
    void updateAllChannels(const QVector<int> &newValues);
    void emitAllChannelSignals();
    void stopAnimation();
    void startAnimation();

    QVector<int> m_channels;
    int m_animationMode;
    QTimer *m_animationTimer;
    QStringList m_logMessages;
    bool m_autoSendEnabled;
    QElapsedTimer m_lastSendTime;
    int m_timeCounter;
    int m_breathDirection;
    int m_breathValue;
    int m_chasePosition;
    qint64 m_lastLogTime;

    static constexpr int MAX_LOG_ENTRIES = 100;
    static constexpr int ANIMATION_INTERVAL_MS = 50;
    Q_PROPERTY(QVector<int> channels READ channels WRITE setChannels NOTIFY channelsChanged FINAL)
};

#endif // DMXCONTROLLER_H