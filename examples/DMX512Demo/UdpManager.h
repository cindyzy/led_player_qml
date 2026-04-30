#ifndef UDPMANAGER_H
#define UDPMANAGER_H

#include <QObject>
#include <QUdpSocket>
#include <QHostAddress>

class UdpManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool isBound READ isBound NOTIFY boundChanged)
    Q_PROPERTY(QStringList localIpList READ localIpList CONSTANT)

public:
    explicit UdpManager(QObject *parent = nullptr);

    bool isBound() const { return m_bound; }
    QStringList localIpList() const;

    Q_INVOKABLE bool bindPort(quint16 port);
    Q_INVOKABLE void unbind();
    Q_INVOKABLE void sendData(const QString &ip, quint16 port, const QString &data);
    Q_INVOKABLE void sendArtPoll(const QString &targetIp, quint16 port);
    Q_INVOKABLE void sendNetConfig(const QString &targetIp, quint16 port,
                                   bool dhcp, const QString &ip, const QString &mask, const QString &gateway);
    Q_INVOKABLE void sendSetTargetIp(const QString &targetIp, quint16 port, const QString &destIp);
    Q_INVOKABLE void requestDeviceMode(const QString &targetIp, quint16 port);

signals:
    void boundChanged();
    void dataReceived(const QString &fromIp, quint16 fromPort, const QString &hexData, const QString &asciiData);
    void nodeFound(const QString &ip, const QString &shortName);

private slots:
    void onReadyRead();

private:
    QUdpSocket *m_socket;
    bool m_bound;
    QHostAddress m_boundAddress;
    quint16 m_boundPort;

    void parseArtPollReply(const QByteArray &data, const QHostAddress &sender);
};

#endif // UDPMANAGER_H