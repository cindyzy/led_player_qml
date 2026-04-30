#ifndef ROLEMODEL_H
#define ROLEMODEL_H

#include <QAbstractListModel>
#include "../../../business/businesscontroller.h"
#include "../../../database/entities/role.h"

class RoleModel : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)

public:
    explicit RoleModel(QObject* parent = nullptr);

    void setBusinessController(BusinessController* controller);
    Q_INVOKABLE bool loadRoles();
    Q_INVOKABLE QVariant getRoleData(int index) const;
    Q_INVOKABLE bool addRole(const QString& roleName, const QString& roleDesc, const QString& operatorUser = "system");
    Q_INVOKABLE bool updateRole(int roleId, const QString& roleName, const QString& roleDesc, const QString& operatorUser = "system");
    Q_INVOKABLE bool deleteRole(int roleId, const QString& operatorUser = "system");
    Q_INVOKABLE QVariant findRoleById(int roleId) const;
    Q_INVOKABLE QVariant findRoleByName(const QString& roleName) const;

    int rowCount(const QModelIndex& parent = QModelIndex()) const override;
    QVariant data(const QModelIndex& index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

signals:
    void countChanged();
    void roleAdded(int index);
    void roleRemoved(int index);
    void roleUpdated(int index);

private:
    BusinessController* m_businessController = nullptr;
    QList<LEDDB::Role> m_roles;

    enum RoleRoles {
        RoleIdRole = Qt::UserRole + 1,
        RoleNameRole,
        RoleDescRole
    };
};

#endif // ROLEMODEL_H