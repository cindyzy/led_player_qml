#ifndef LEDDEVICEMODEL_H
#define LEDDEVICEMODEL_H

#include <QAbstractListModel>
#include "../../../business/businesscontroller.h"
#include "../../../database/entities/leddevice.h"

class LedDeviceModel : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)

public:
    explicit LedDeviceModel(QObject* parent = nullptr);

    void setBusinessController(BusinessController* controller);
    Q_INVOKABLE bool loadDevices();
    Q_INVOKABLE QVariant getDeviceData(int index) const;
    Q_INVOKABLE bool addDevice(const QString& deviceName, const QString& deviceType,
                               const QString& ipAddr, int port, int brightness, const QString& operatorUser = "system");
    Q_INVOKABLE bool updateDevice(int deviceId, const QString& deviceName,
                                   const QString& deviceType, const QString& ipAddr,
                                   int port, int brightness, int onlineStatus, const QString& operatorUser = "system");
    Q_INVOKABLE bool deleteDevice(int deviceId, const QString& operatorUser = "system");
    Q_INVOKABLE QVariant findDeviceById(int deviceId) const;
    Q_INVOKABLE bool updateBrightness(int deviceId, int brightness, const QString& operatorUser = "system");

    int rowCount(const QModelIndex& parent = QModelIndex()) const override;
    QVariant data(const QModelIndex& index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

signals:
    void countChanged();

private:
    BusinessController* m_businessController = nullptr;
    QList<LEDDB::LedDevice> m_devices;

    enum DeviceRoles {
        DeviceIdRole = Qt::UserRole + 1,
        DeviceNameRole,
        DeviceTypeRole,
        IpAddrRole,
        PortRole,
        BrightnessRole,
        OnlineStatusRole,
        ConfigJsonRole,
        UpdateTimeRole
    };
};

#endif // LEDDEVICEMODEL_H