#include "RoleModel.h"
#include <QDebug>

RoleModel::RoleModel(QObject* parent) : QAbstractListModel(parent)
{
}

void RoleModel::setBusinessController(BusinessController* controller)
{
    m_businessController = controller;
}

bool RoleModel::loadRoles()
{
    if (!m_businessController) {
        qDebug() << "RoleModel: BusinessController not set!";
        return false;
    }

    beginResetModel();
    m_roles.clear();
    endResetModel();
    emit countChanged();
    return true;
}

QVariant RoleModel::getRoleData(int index) const
{
    if (index < 0 || index >= m_roles.size()) {
        return QVariant();
    }

    const LEDDB::Role& role = m_roles[index];
    QVariantMap map;
    map["roleId"] = role.roleId();
    map["roleName"] = role.roleName();
    map["roleDesc"] = role.roleDesc();
    return map;
}

bool RoleModel::addRole(const QString& roleName, const QString& roleDesc)
{
    if (!m_businessController) {
        qDebug() << "RoleModel: BusinessController not set!";
        return false;
    }
    qDebug() << "RoleModel: addRole called -" << roleName;
    return true;
}

bool RoleModel::updateRole(int roleId, const QString& roleName, const QString& roleDesc)
{
    if (!m_businessController) {
        qDebug() << "RoleModel: BusinessController not set!";
        return false;
    }
    qDebug() << "RoleModel: updateRole called -" << roleId;
    return true;
}

bool RoleModel::deleteRole(int roleId)
{
    if (!m_businessController) {
        qDebug() << "RoleModel: BusinessController not set!";
        return false;
    }
    qDebug() << "RoleModel: deleteRole called -" << roleId;
    return true;
}

QVariant RoleModel::findRoleById(int roleId) const
{
    for (int i = 0; i < m_roles.size(); ++i) {
        if (m_roles[i].roleId() == roleId) {
            return getRoleData(i);
        }
    }
    return QVariant();
}

QVariant RoleModel::findRoleByName(const QString& roleName) const
{
    for (int i = 0; i < m_roles.size(); ++i) {
        if (m_roles[i].roleName() == roleName) {
            return getRoleData(i);
        }
    }
    return QVariant();
}

int RoleModel::rowCount(const QModelIndex& parent) const
{
    Q_UNUSED(parent);
    return m_roles.size();
}

QVariant RoleModel::data(const QModelIndex& index, int role) const
{
    if (!index.isValid() || index.row() >= m_roles.size()) {
        return QVariant();
    }

    const LEDDB::Role& ledRole = m_roles[index.row()];

    switch (role) {
    case RoleIdRole:
        return ledRole.roleId();
    case RoleNameRole:
        return ledRole.roleName();
    case RoleDescRole:
        return ledRole.roleDesc();
    default:
        return QVariant();
    }
}

QHash<int, QByteArray> RoleModel::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[RoleIdRole] = "roleId";
    roles[RoleNameRole] = "roleName";
    roles[RoleDescRole] = "roleDesc";
    return roles;
}