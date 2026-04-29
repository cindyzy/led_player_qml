#ifndef SQLITELEDDEVICEREPOSITORY_H
#define SQLITELEDDEVICEREPOSITORY_H

// repositories/sqlite_leddevice_repository.h
#pragma once
#include "interfaces/ILedDeviceRepository.h"

namespace Repository {

class SqliteLedDeviceRepository : public ILedDeviceRepository {
public:
    bool insert(const LEDDB::LedDevice& device) override;
    bool update(const LEDDB::LedDevice& device) override;
    bool deleteById(int deviceId) override;
    std::optional<LEDDB::LedDevice> findById(int deviceId) override;
    QList<LEDDB::LedDevice> findByOnlineStatus(int onlineStatus) override;
    QList<LEDDB::LedDevice> findByIp(const QString& ip) override;
    QList<LEDDB::LedDevice> findAll(int offset = 0, int limit = 100) override;
    bool updateBrightness(int deviceId, int brightness) override;
    bool updateOnlineStatus(int deviceId, int status) override;
};

} // namespace Repository

#endif // SQLITELEDDEVICEREPOSITORY_H
