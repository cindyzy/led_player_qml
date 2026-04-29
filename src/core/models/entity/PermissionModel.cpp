#include "PermissionModel.h"
#include <QDebug>

PermissionModel::PermissionModel(QObject* parent) : QAbstractListModel(parent)
{
}

void PermissionModel::setBusinessController(BusinessController* controller)
{
    m_businessController = controller;
}

bool PermissionModel::loadPermissions()
{
    if (!m_businessController) {
        qDebug() << "PermissionModel: BusinessController not set!";
        return false;
    }

    beginResetModel();
    m_permissions.clear();
    endResetModel();
    emit countChanged();
    return true;
}

QVariant PermissionModel::getPermissionData(int index) const
{
    if (index < 0 || index >= m_permissions.size()) {
        return QVariant();
    }

    const LEDDB::Permission& perm = m_permissions[index];
    QVariantMap map;
    map["permId"] = perm.permId();
    map["roleId"] = perm.roleId();
    map["permCode"] = perm.permCode();
    map["permDesc"] = perm.permDesc();
    return map;
}

bool PermissionModel::addPermission(int roleId, const QString& permCode, const QString& permDesc)
{
    if (!m_businessController) {
        qDebug() << "PermissionModel: BusinessController not set!";
        return false;
    }
    qDebug() << "PermissionModel: addPermission called -" << permCode;
    return true;
}

bool PermissionModel::updatePermission(int permId, int roleId, const QString& permCode, const QString& permDesc)
{
    if (!m_businessController) {
        qDebug() << "PermissionModel: BusinessController not set!";
        return false;
    }
    qDebug() << "PermissionModel: updatePermission called -" << permId;
    return true;
}

bool PermissionModel::deletePermission(int permId)
{
    if (!m_businessController) {
        qDebug() << "PermissionModel: BusinessController not set!";
        return false;
    }
    qDebug() << "PermissionModel: deletePermission called -" << permId;
    return true;
}

QVariant PermissionModel::findPermissionById(int permId) const
{
    for (int i = 0; i < m_permissions.size(); ++i) {
        if (m_permissions[i].permId() == permId) {
            return getPermissionData(i);
        }
    }
    return QVariant();
}

QList<QVariant> PermissionModel::getPermissionsByRole(int roleId) const
{
    QList<QVariant> result;
    for (int i = 0; i < m_permissions.size(); ++i) {
        if (m_permissions[i].roleId() == roleId) {
            result.append(getPermissionData(i));
        }
    }
    return result;
}

int PermissionModel::rowCount(const QModelIndex& parent) const
{
    Q_UNUSED(parent);
    return m_permissions.size();
}

QVariant PermissionModel::data(const QModelIndex& index, int role) const
{
    if (!index.isValid() || index.row() >= m_permissions.size()) {
        return QVariant();
    }

    const LEDDB::Permission& perm = m_permissions[index.row()];

    switch (role) {
    case PermIdRole:
        return perm.permId();
    case RoleIdRole:
        return perm.roleId();
    case PermCodeRole:
        return perm.permCode();
    case PermDescRole:
        return perm.permDesc();
    default:
        return QVariant();
    }
}

QHash<int, QByteArray> PermissionModel::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[PermIdRole] = "permId";
    roles[RoleIdRole] = "roleId";
    roles[PermCodeRole] = "permCode";
    roles[PermDescRole] = "permDesc";
    return roles;
}