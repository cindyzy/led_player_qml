#include "UdpManager.h"
#include <QNetworkInterface>
#include <QDebug>

UdpManager::UdpManager(QObject *parent) : QObject(parent), m_socket(new QUdpSocket(this)), m_bound(false)
{
    connect(m_socket, &QUdpSocket::readyRead, this, &UdpManager::onReadyRead);
}

QStringList UdpManager::localIpList() const
{
    QStringList ips;
    for (const QHostAddress &addr : QNetworkInterface::allAddresses()) {
        if (addr.protocol() == QAbstractSocket::IPv4Protocol && addr != QHostAddress::LocalHost)
            ips << addr.toString();
    }
    if (ips.isEmpty()) ips << "127.0.0.1";
    return ips;
}

bool UdpManager::bindPort(quint16 port)
{
    if (m_bound) unbind();
    if (m_socket->bind(port)) {
        m_bound = true;
        m_boundPort = port;
        m_boundAddress = QHostAddress::Any;
        emit boundChanged();
        sendData("", 0, ""); // 触发日志，仅用于提示
        return true;
    }
    return false;
}

void UdpManager::unbind()
{
    if (m_bound) {
        m_socket->close();
        m_bound = false;
        emit boundChanged();
    }
}

void UdpManager::sendData(const QString &ip, quint16 port, const QString &data)
{
    if (!m_bound) {
        emit dataReceived("System", 0, "", "UDP未绑定，请先点击【打开UDP】");
        return;
    }

    QHostAddress addr;
    if (ip.isEmpty() || ip == "255.255.255.255")
        addr = QHostAddress::Broadcast;
    else
        addr = QHostAddress(ip);

    QByteArray datagram = data.toUtf8();
    qint64 ret = m_socket->writeDatagram(datagram, addr, port);
    if (ret == -1) {
        emit dataReceived("System", 0, "", "发送失败: " + m_socket->errorString());
    } else {
        emit dataReceived("System", 0, "", QString("发送 %1 字节到 %2:%3").arg(ret).arg(ip).arg(port));
    }
}

void UdpManager::sendArtPoll(const QString &targetIp, quint16 port)
{
    // ArtPoll 构造 (Art-Net 协议)
    QByteArray packet;
    packet.append("Art-Net\0", 8);          // ID (8 bytes with null)
    packet.append(char(0x00));              // OpCode Low (ArtPoll = 0x2000)
    packet.append(char(0x20));              // OpCode High
    packet.append(char(0x00)); packet.append(char(0x0E)); // ProtoVer = 14
    packet.append(char(0x00));              // TalkToMe
    packet.append(char(0x00));              // Priority

    sendData(targetIp, port, QString::fromLatin1(packet.toHex()));
    emit dataReceived("System", 0, "", "已发送 ArtPoll 包");
}

void UdpManager::sendNetConfig(const QString &targetIp, quint16 port,
                               bool dhcp, const QString &ip, const QString &mask, const QString &gateway)
{
    // 自定义协议：模拟设备网络参数修改（实际使用时需根据设备文档实现）
    QString cmd = QString("SET_NET:DHCP=%1,IP=%2,MASK=%3,GATEWAY=%4")
                      .arg(dhcp ? "ON" : "OFF").arg(ip).arg(mask).arg(gateway);
    sendData(targetIp, port, cmd);
}

void UdpManager::sendSetTargetIp(const QString &targetIp, quint16 port, const QString &destIp)
{
    QString cmd = QString("SET_TARGET_IP:%1").arg(destIp);
    sendData(targetIp, port, cmd);
}

void UdpManager::requestDeviceMode(const QString &targetIp, quint16 port)
{
    sendData(targetIp, port, "GET_MODE");
}

void UdpManager::onReadyRead()
{
    while (m_socket->hasPendingDatagrams()) {
        QByteArray buffer;
        buffer.resize(m_socket->pendingDatagramSize());
        QHostAddress sender;
        quint16 senderPort;
        m_socket->readDatagram(buffer.data(), buffer.size(), &sender, &senderPort);

        QString hex = buffer.toHex(' ').toUpper();
        QString ascii;
        for (char c : buffer) {
            if (c >= 32 && c < 127) ascii.append(c);
            else ascii.append('.');
        }
        emit dataReceived(sender.toString(), senderPort, hex, ascii);

        // 自动解析 ArtPollReply (OpCode 0x2100)
        if (buffer.size() >= 12 && buffer.startsWith("Art-Net\0")) {
            quint16 opCode = (quint16)((unsigned char)buffer[9] << 8) | (unsigned char)buffer[8];
            if (opCode == 0x2100) {
                parseArtPollReply(buffer, sender);
            }
        }
    }
}

void UdpManager::parseArtPollReply(const QByteArray &data, const QHostAddress &sender)
{
    // 提取 ShortName (18字节偏移 12 到 30)
    QString shortName;
    if (data.size() >= 30) {
        shortName = QString::fromLatin1(data.mid(12, 18)).simplified();
    }
    emit nodeFound(sender.toString(), shortName.isEmpty() ? "未知设备" : shortName);
}