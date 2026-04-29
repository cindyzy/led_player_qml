// entities/leddevice.cpp
#include "leddevice.h"
#include "../../utils/datetimehelper.h"
#include <QSqlRecord>

namespace LEDDB {

LedDevice::LedDevice(int deviceId, const QString& deviceName, const QString& deviceType,
                     const QString& ipAddr, int port, int brightness, int onlineStatus,
                     const QString& configJson, const QDateTime& updateTime)
    : m_deviceId(deviceId), m_deviceName(deviceName), m_deviceType(deviceType),
    m_ipAddr(ipAddr), m_port(port), m_brightness(brightness), m_onlineStatus(onlineStatus),
    m_configJson(configJson), m_updateTime(updateTime) {}

LedDevice LedDevice::fromSqlRecord(const QSqlRecord& rec)
{
    LedDevice d;
    d.setDeviceId(rec.value("device_id").toInt());
    d.setDeviceName(rec.value("device_name").toString());
    d.setDeviceType(rec.value("device_type").toString());
    d.setIpAddr(rec.value("ip_addr").toString());
    d.setPort(rec.value("port").toInt());
    d.setBrightness(rec.value("brightness").toInt());
    d.setOnlineStatus(rec.value("online_status").toInt());
    d.setConfigJson(rec.value("config_json").toString());
    d.setUpdateTime(fromIsoString(rec.value("update_time").toString()));
    return d;
}

} // namespace LEDDB