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
    AuditLogService().logOperation(operatorUser, "添加设备", QString("添加设备 %1").arg(device.deviceName()), success ? "成功" : "失败");
    return success;
}

bool LedDeviceService::updateDevice(const LedDevice& device, const QString& operatorUser) {
    auto deviceRepo = RepositoryFactory::createLedDeviceRepository();
    LedDevice updated = device;
    updated.setUpdateTime(QDateTime::currentDateTime());
    bool success = deviceRepo->update(updated);
    AuditLogService().logOperation(operatorUser, "更新设备", QString("更新设备 %1").arg(device.deviceId()), success ? "成功" : "失败");
    return success;
}

bool LedDeviceService::removeDevice(const QString& deviceId, const QString& operatorUser) {
    auto deviceRepo = RepositoryFactory::createLedDeviceRepository();
    auto device = deviceRepo->findById(deviceId);
    if (!device) return false;
    bool success = deviceRepo->deleteById(deviceId);
    AuditLogService().logOperation(operatorUser, "删除设备", QString("删除设备 %1").arg(device->deviceName()), success ? "成功" : "失败");
    return success;
}

std::optional<LedDevice> LedDeviceService::getDeviceById(const QString& deviceId) {
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

bool LedDeviceService::setBrightness(const QString& deviceId, int brightness, const QString& operatorUser) {
    if (brightness < 0 || brightness > 100) return false;
    auto deviceRepo = RepositoryFactory::createLedDeviceRepository();
    auto device = deviceRepo->findById(deviceId);
    if (!device) return false;

    auto& dbMgr = DatabaseManager::instance();
    if (!dbMgr.beginTransaction()) return false;

    bool success = deviceRepo->updateBrightness(deviceId, brightness);
    if (success) {
        AuditLogService().logOperation(operatorUser, "调节亮度",
                                       QString("设备 %1 亮度从 %2 调整为 %3").arg(deviceId).arg(device->brightness()).arg(brightness), "成功");
        dbMgr.commitTransaction();
        return true;
    } else {
        dbMgr.rollbackTransaction();
        AuditLogService().logOperation(operatorUser, "调节亮度",
                                       QString("设备 %1 亮度调节失败").arg(deviceId), "失败");
        return false;
    }
}

bool LedDeviceService::setDeviceStatus(const QString& deviceId, int onlineStatus, const QString& operatorUser) {
    auto deviceRepo = RepositoryFactory::createLedDeviceRepository();
    bool success = deviceRepo->updateOnlineStatus(deviceId, onlineStatus);
    AuditLogService().logOperation(operatorUser, "设备状态变更",
                                   QString("设备 %1 状态变为 %2").arg(deviceId).arg(onlineStatus == 1 ? "在线" : "离线"), success ? "成功" : "失败");
    return success;
}