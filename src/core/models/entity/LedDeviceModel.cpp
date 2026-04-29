#include "LedDeviceModel.h"
#include <QDebug>

LedDeviceModel::LedDeviceModel(QObject* parent) : QAbstractListModel(parent)
{
}

void LedDeviceModel::setBusinessController(BusinessController* controller)
{
    m_businessController = controller;
}

bool LedDeviceModel::loadDevices()
{
    if (!m_businessController) {
        qDebug() << "LedDeviceModel: BusinessController not set!";
        return false;
    }
    beginResetModel();
    m_devices.clear();
    endResetModel();
    emit countChanged();
    return true;
}

QVariant LedDeviceModel::getDeviceData(int index) const
{
    if (index < 0 || index >= m_devices.size()) return QVariant();
    const LEDDB::LedDevice& dev = m_devices[index];
    QVariantMap map;
    map["deviceId"] = dev.deviceId();
    map["deviceName"] = dev.deviceName();
    map["deviceType"] = dev.deviceType();
    map["ipAddr"] = dev.ipAddr();
    map["port"] = dev.port();
    map["brightness"] = dev.brightness();
    map["onlineStatus"] = dev.onlineStatus();
    map["configJson"] = dev.configJson();
    map["updateTime"] = dev.updateTime().toString();
    return map;
}

bool LedDeviceModel::addDevice(const QString& deviceName, const QString& deviceType,
                               const QString& ipAddr, int port, int brightness)
{
    if (!m_businessController) {
        qDebug() << "LedDeviceModel: BusinessController not set!";
        return false;
    }
    qDebug() << "LedDeviceModel: addDevice called -" << deviceName;
    return true;
}

bool LedDeviceModel::updateDevice(int deviceId, const QString& deviceName,
                                   const QString& deviceType, const QString& ipAddr,
                                   int port, int brightness, int onlineStatus)
{
    if (!m_businessController) {
        qDebug() << "LedDeviceModel: BusinessController not set!";
        return false;
    }
    qDebug() << "LedDeviceModel: updateDevice called -" << deviceId;
    return true;
}

bool LedDeviceModel::deleteDevice(int deviceId)
{
    if (!m_businessController) {
        qDebug() << "LedDeviceModel: BusinessController not set!";
        return false;
    }
    qDebug() << "LedDeviceModel: deleteDevice called -" << deviceId;
    return true;
}

QVariant LedDeviceModel::findDeviceById(int deviceId) const
{
    for (int i = 0; i < m_devices.size(); ++i) {
        if (m_devices[i].deviceId() == deviceId) {
            return getDeviceData(i);
        }
    }
    return QVariant();
}

bool LedDeviceModel::updateBrightness(int deviceId, int brightness)
{
    if (!m_businessController) {
        qDebug() << "LedDeviceModel: BusinessController not set!";
        return false;
    }
    qDebug() << "LedDeviceModel: updateBrightness called -" << deviceId;
    return true;
}

int LedDeviceModel::rowCount(const QModelIndex& parent) const
{
    Q_UNUSED(parent);
    return m_devices.size();
}

QVariant LedDeviceModel::data(const QModelIndex& index, int role) const
{
    if (!index.isValid() || index.row() >= m_devices.size()) return QVariant();
    const LEDDB::LedDevice& dev = m_devices[index.row()];
    switch (role) {
    case DeviceIdRole: return dev.deviceId();
    case DeviceNameRole: return dev.deviceName();
    case DeviceTypeRole: return dev.deviceType();
    case IpAddrRole: return dev.ipAddr();
    case PortRole: return dev.port();
    case BrightnessRole: return dev.brightness();
    case OnlineStatusRole: return dev.onlineStatus();
    case ConfigJsonRole: return dev.configJson();
    case UpdateTimeRole: return dev.updateTime();
    default: return QVariant();
    }
}

QHash<int, QByteArray> LedDeviceModel::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[DeviceIdRole] = "deviceId";
    roles[DeviceNameRole] = "deviceName";
    roles[DeviceTypeRole] = "deviceType";
    roles[IpAddrRole] = "ipAddr";
    roles[PortRole] = "port";
    roles[BrightnessRole] = "brightness";
    roles[OnlineStatusRole] = "onlineStatus";
    roles[ConfigJsonRole] = "configJson";
    roles[UpdateTimeRole] = "updateTime";
    return roles;
}