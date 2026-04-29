#ifndef LEDDEVICE_H
#define LEDDEVICE_H

// entities/leddevice.h
#pragma once
#include <QString>
#include <QDateTime>
#include <QSqlRecord>
namespace LEDDB {

class LedDevice {
public:
    LedDevice() = default;
    LedDevice(int deviceId, const QString& deviceName, const QString& deviceType,
              const QString& ipAddr, int port, int brightness, int onlineStatus,
              const QString& configJson, const QDateTime& updateTime);

    // Getters / Setters
    int deviceId() const { return m_deviceId; }
    void setDeviceId(const int id) { m_deviceId = id; }

    QString deviceName() const { return m_deviceName; }
    void setDeviceName(const QString& name) { m_deviceName = name; }

    QString deviceType() const { return m_deviceType; }
    void setDeviceType(const QString& type) { m_deviceType = type; }

    QString ipAddr() const { return m_ipAddr; }
    void setIpAddr(const QString& ip) { m_ipAddr = ip; }

    int port() const { return m_port; }
    void setPort(int port) { m_port = port; }

    int brightness() const { return m_brightness; }
    void setBrightness(int brightness) { m_brightness = brightness; }

    int onlineStatus() const { return m_onlineStatus; }
    void setOnlineStatus(int status) { m_onlineStatus = status; }

    QString configJson() const { return m_configJson; }
    void setConfigJson(const QString& json) { m_configJson = json; }

    QDateTime updateTime() const { return m_updateTime; }
    void setUpdateTime(const QDateTime& dt) { m_updateTime = dt; }

    static LedDevice fromSqlRecord(const QSqlRecord& record);

private:
    int m_deviceId;
    QString m_deviceName;
    QString m_deviceType;
    QString m_ipAddr;
    int m_port = 0;
    int m_brightness = 50;
    int m_onlineStatus = 0;   // 0离线 1在线
    QString m_configJson;
    QDateTime m_updateTime;
};

} // namespace LEDDB

#endif // LEDDEVICE_H
