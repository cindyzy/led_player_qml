#include "leddeviceservice.h"

// services/LedDeviceService.cpp
#include "../repositories/repositoryfactory.h"
#include "../../utils/datetimehelper.h"
#include "AuditLogService.h"
#include <QDateTime>

using namespace Repository;
using namespace LEDDB;

LedDeviceService::LedDeviceService() = default;

bool LedDeviceService::addDevice(const LedDevice& device, const QString& operatorUser) {
    auto deviceRepo = RepositoryFactory::createLedDeviceRepository();
    LedDevice newDevice = device;
    newDevice.setUpdateTime(QDateTime::currentDateTime());
    bool success = deviceRepo->insert(newDevice);

    int userId = 0;
    auto userRepo = RepositoryFactory::createUserRepository();
    auto userOpt = userRepo->findByUserName(operatorUser);
    if (userOpt.has_value()) {
        userId = userOpt.value().userId();
    }

    AuditLogService().logOperation(userId, "添加设备", success ? "成功" : "失败",
                                   QString("添加设备 %1").arg(device.deviceName()),
                                   "led_device", newDevice.deviceId());
    return success;
}

bool LedDeviceService::updateDevice(const LedDevice& device, const QString& operatorUser) {
    auto deviceRepo = RepositoryFactory::createLedDeviceRepository();
    LedDevice updated = device;
    updated.setUpdateTime(QDateTime::currentDateTime());
    bool success = deviceRepo->update(updated);

    int userId = 0;
    auto userRepo = RepositoryFactory::createUserRepository();
    auto userOpt = userRepo->findByUserName(operatorUser);
    if (userOpt.has_value()) {
        userId = userOpt.value().userId();
    }

    AuditLogService().logOperation(userId, "更新设备", success ? "成功" : "失败",
                                   QString("更新设备 %1").arg(device.deviceId()),
                                   "led_device", device.deviceId());
    return success;
}

bool LedDeviceService::removeDevice(int deviceId, const QString& operatorUser) {
    auto deviceRepo = RepositoryFactory::createLedDeviceRepository();
    auto device = deviceRepo->findById(deviceId);
    if (!device) return false;
    bool success = deviceRepo->deleteById(deviceId);

    int userId = 0;
    auto userRepo = RepositoryFactory::createUserRepository();
    auto userOpt = userRepo->findByUserName(operatorUser);
    if (userOpt.has_value()) {
        userId = userOpt.value().userId();
    }

    AuditLogService().logOperation(userId, "删除设备", success ? "成功" : "失败",
                                   QString("删除设备 %1").arg(device->deviceName()),
                                   "led_device", deviceId);
    return success;
}

std::optional<LedDevice> LedDeviceService::getDeviceById(int deviceId) {
    auto deviceRepo = RepositoryFactory::createLedDeviceRepository();
    return deviceRepo->findById(deviceId);
}

QList<LedDevice> LedDeviceService::getAllDevices(int offset, int limit) {
    auto deviceRepo = RepositoryFactory::createLedDeviceRepository();
    return deviceRepo->findAll(offset, limit);
}

QList<LedDevice> LedDeviceService::getOnlineDevices() {
    auto deviceRepo = RepositoryFactory::createLedDeviceRepository();
    return deviceRepo->findByOnlineStatus(1);
}

bool LedDeviceService::setBrightness(int deviceId, int brightness, const QString& operatorUser) {
    if (brightness < 0 || brightness > 100) return false;
    auto deviceRepo = RepositoryFactory::createLedDeviceRepository();
    auto device = deviceRepo->findById(deviceId);
    if (!device) return false;

    int userId = 0;
    auto userRepo = RepositoryFactory::createUserRepository();
    auto userOpt = userRepo->findByUserName(operatorUser);
    if (userOpt.has_value()) {
        userId = userOpt.value().userId();
    }

    auto& dbMgr = DatabaseManager::instance();
    if (!dbMgr.beginTransaction()) return false;

    bool success = deviceRepo->updateBrightness(deviceId, brightness);
    if (success) {
        AuditLogService().logOperation(userId, "调节亮度", "成功",
                                       QString("设备 %1 亮度从 %2 调整为 %3").arg(deviceId).arg(device->brightness()).arg(brightness),
                                       "led_device", deviceId);
        dbMgr.commitTransaction();
        return true;
    } else {
        dbMgr.rollbackTransaction();
        AuditLogService().logOperation(userId, "调节亮度", "失败",
                                       QString("设备 %1 亮度调节失败").arg(deviceId),
                                       "led_device", deviceId);
        return false;
    }
}

bool LedDeviceService::setDeviceStatus(int deviceId, int onlineStatus, const QString& operatorUser) {
    auto deviceRepo = RepositoryFactory::createLedDeviceRepository();
    bool success = deviceRepo->updateOnlineStatus(deviceId, onlineStatus);

    int userId = 0;
    auto userRepo = RepositoryFactory::createUserRepository();
    auto userOpt = userRepo->findByUserName(operatorUser);
    if (userOpt.has_value()) {
        userId = userOpt.value().userId();
    }

    AuditLogService().logOperation(userId, "设备状态变更", success ? "成功" : "失败",
                                   QString("设备 %1 状态变为 %2").arg(deviceId).arg(onlineStatus == 1 ? "在线" : "离线"),
                                   "led_device", deviceId);
    return success;
}