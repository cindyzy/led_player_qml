#ifndef PERMISSIONMODEL_H
#define PERMISSIONMODEL_H

#include <QAbstractListModel>
#include "../../../business/businesscontroller.h"
#include "../../../database/entities/permission.h"

class PermissionModel : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)

public:
    explicit PermissionModel(QObject* parent = nullptr);

    void setBusinessController(BusinessController* controller);
    Q_INVOKABLE bool loadPermissions();
    Q_INVOKABLE QVariant getPermissionData(int index) const;
    Q_INVOKABLE bool addPermission(int roleId, const QString& permCode, const QString& permDesc);
    Q_INVOKABLE bool updatePermission(int permId, int roleId, const QString& permCode, const QString& permDesc);
    Q_INVOKABLE bool deletePermission(int permId);
    Q_INVOKABLE QVariant findPermissionById(int permId) const;
    Q_INVOKABLE QList<QVariant> getPermissionsByRole(int roleId) const;

    int rowCount(const QModelIndex& parent = QModelIndex()) const override;
    QVariant data(const QModelIndex& index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

signals:
    void countChanged();

private:
    BusinessController* m_businessController = nullptr;
    QList<LEDDB::Permission> m_permissions;

    enum PermissionRoles {
        PermIdRole = Qt::UserRole + 1,
        RoleIdRole,
        PermCodeRole,
        PermDescRole
    };
};

#endif // PERMISSIONMODEL_H