#include "sqliteleddevicerepository.h"
// repositories/sqlite_leddevice_repository.cpp
// #include "sqlite_leddevice_repository.h"
#include "../databasemanager.h"
#include "../../utils/datetimehelper.h"
#include <QSqlQuery>

using namespace Repository;

bool SqliteLedDeviceRepository::insert(const LEDDB::LedDevice& device) {
    QSqlQuery query(DatabaseManager::instance().getDatabase());
    query.prepare(R"(
        INSERT INTO led_device (device_id, device_name, device_type, ip_addr, port,
        brightness, online_status, config_json, update_time)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
    )");
    query.addBindValue(device.deviceId());
    query.addBindValue(device.deviceName());
    query.addBindValue(device.deviceType());
    query.addBindValue(device.ipAddr());
    query.addBindValue(device.port());
    query.addBindValue(device.brightness());
    query.addBindValue(device.onlineStatus());
    query.addBindValue(device.configJson());
    query.addBindValue(toIsoString(device.updateTime()));
    return query.exec();
}

bool SqliteLedDeviceRepository::update(const LEDDB::LedDevice& device) {
    QSqlQuery query(DatabaseManager::instance().getDatabase());
    query.prepare(R"(
        UPDATE led_device SET device_name=?, device_type=?, ip_addr=?, port=?,
        brightness=?, online_status=?, config_json=?, update_time=?
        WHERE device_id=?
    )");
    query.addBindValue(device.deviceName());
    query.addBindValue(device.deviceType());
    query.addBindValue(device.ipAddr());
    query.addBindValue(device.port());
    query.addBindValue(device.brightness());
    query.addBindValue(device.onlineStatus());
    query.addBindValue(device.configJson());
    query.addBindValue(toIsoString(device.updateTime()));
    query.addBindValue(device.deviceId());
    return query.exec();
}

bool SqliteLedDeviceRepository::deleteById(const QString& deviceId) {
    QSqlQuery query(DatabaseManager::instance().getDatabase());
    query.prepare("DELETE FROM led_device WHERE device_id = ?");
    query.addBindValue(deviceId);
    return query.exec();
}

std::optional<LEDDB::LedDevice> SqliteLedDeviceRepository::findById(const QString& deviceId) {
    QSqlQuery query(DatabaseManager::instance().getDatabase());
    query.prepare("SELECT * FROM led_device WHERE device_id = ?");
    query.addBindValue(deviceId);
    if (!query.exec() || !query.next()) return std::nullopt;
    return LEDDB::LedDevice::fromSqlRecord(query.record());
}

QList<LEDDB::LedDevice> SqliteLedDeviceRepository::findByOnlineStatus(int onlineStatus) {
    QList<LEDDB::LedDevice> list;
    QSqlQuery query(DatabaseManager::instance().getDatabase());
    query.prepare("SELECT * FROM led_device WHERE online_status = ?");
    query.addBindValue(onlineStatus);
    if (!query.exec()) return list;
    while (query.next()) list.append(LEDDB::LedDevice::fromSqlRecord(query.record()));
    return list;
}

QList<LEDDB::LedDevice> SqliteLedDeviceRepository::findByIp(const QString& ip) {
    QList<LEDDB::LedDevice> list;
    QSqlQuery query(DatabaseManager::instance().getDatabase());
    query.prepare("SELECT * FROM led_device WHERE ip_addr = ?");
    query.addBindValue(ip);
    if (!query.exec()) return list;
    while (query.next()) list.append(LEDDB::LedDevice::fromSqlRecord(query.record()));
    return list;
}

QList<LEDDB::LedDevice> SqliteLedDeviceRepository::findAll(int offset, int limit) {
    QList<LEDDB::LedDevice> list;
    QSqlQuery query(DatabaseManager::instance().getDatabase());
    query.prepare("SELECT * FROM led_device LIMIT ? OFFSET ?");
    query.addBindValue(limit);
    query.addBindValue(offset);
    if (!query.exec()) return list;
    while (query.next()) list.append(LEDDB::LedDevice::fromSqlRecord(query.record()));
    return list;
}

bool SqliteLedDeviceRepository::updateBrightness(const QString& deviceId, int brightness) {
    QSqlQuery query(DatabaseManager::instance().getDatabase());
    query.prepare("UPDATE led_device SET brightness=?, update_time=? WHERE device_id=?");
    query.addBindValue(brightness);
    query.addBindValue(toIsoString(QDateTime::currentDateTime()));
    query.addBindValue(deviceId);
    return query.exec();
}

bool SqliteLedDeviceRepository::updateOnlineStatus(const QString& deviceId, int status) {
    QSqlQuery query(DatabaseManager::instance().getDatabase());
    query.prepare("UPDATE led_device SET online_status=?, update_time=? WHERE device_id=?");
    query.addBindValue(status);
    query.addBindValue(toIsoString(QDateTime::currentDateTime()));
    query.addBindValue(deviceId);
    return query.exec();
}