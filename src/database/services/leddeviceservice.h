#ifndef LEDDEVICESERVICE_H
#define LEDDEVICESERVICE_H
// services/LedDeviceService.h
#pragma once
#include "../entities/leddevice.h"
#include <optional>
#include <QList>
#include "../databasemanager.h"
class LedDeviceService {
public:
    LedDeviceService();

    bool addDevice(const LEDDB::LedDevice& device, const QString& operatorUser);
    bool updateDevice(const LEDDB::LedDevice& device, const QString& operatorUser);
    bool removeDevice(int deviceId, const QString& operatorUser);
    std::optional<LEDDB::LedDevice> getDeviceById(int deviceId);
    QList<LEDDB::LedDevice> getAllDevices(int offset = 0, int limit = 100);
    QList<LEDDB::LedDevice> getOnlineDevices();
    bool setBrightness(int deviceId, int brightness, const QString& operatorUser);
    bool setDeviceStatus(int deviceId, int onlineStatus, const QString& operatorUser);
};
#endif // LEDDEVICESERVICE_H
