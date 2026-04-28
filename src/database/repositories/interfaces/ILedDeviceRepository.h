#ifndef ILEDDEVICEREPOSITORY_H
#define ILEDDEVICEREPOSITORY_H

// repositories/interfaces/ILedDeviceRepository.h
#pragma once
#include "../../entities/leddevice.h"
#include <optional>
#include <QList>

namespace Repository {

class ILedDeviceRepository {
public:
    virtual ~ILedDeviceRepository() = default;

    virtual bool insert(const LEDDB::LedDevice& device) = 0;
    virtual bool update(const LEDDB::LedDevice& device) = 0;
    virtual bool deleteById(const QString& deviceId) = 0;
    virtual std::optional<LEDDB::LedDevice> findById(const QString& deviceId) = 0;
    virtual QList<LEDDB::LedDevice> findByOnlineStatus(int onlineStatus) = 0;
    virtual QList<LEDDB::LedDevice> findByIp(const QString& ip) = 0;
    virtual QList<LEDDB::LedDevice> findAll(int offset = 0, int limit = 100) = 0;
    virtual bool updateBrightness(const QString& deviceId, int brightness) = 0;
    virtual bool updateOnlineStatus(const QString& deviceId, int status) = 0;
};

} // namespace Repository

#endif // ILEDDEVICEREPOSITORY_H
