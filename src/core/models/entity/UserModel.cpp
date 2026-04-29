#include "UserModel.h"
// 假设 BusinessController 已暴露所需方法
#include <QDebug>
#include <QDateTime>

UserModel::UserModel(QObject* parent)
    : QAbstractListModel(parent)
{
}

void UserModel::setBusinessController(BusinessController* controller)
{
    m_businessController = controller;
}

bool UserModel::loadUsers()
{
    if (!m_businessController) {
        qDebug() << "UserModel: BusinessController not set!";
        return false;
    }

    QList<LEDDB::User> users = m_businessController->getAllUsers();
    updateUserList(users);
    return true;
}

QVariant UserModel::getUserData(int index) const
{
    if (index < 0 || index >= m_users.size())
        return QVariant();

    const LEDDB::User& user = m_users[index];
    QVariantMap map;
    map["userId"]         = user.userId();
    map["userName"]       = user.userName();
    map["password"]       = user.password();   // 密文，一般不暴露给前端
    map["roleId"]         = user.roleId();
    map["status"]         = user.status();
    map["createTime"]     = user.createTime();
    map["lastLoginTime"]  = user.lastLoginTime();
    map["updateTime"]     = user.updateTime();
    return map;
}

bool UserModel::addUser(const QString& userName, const QString& password, int roleId, const QString& operatorUser)
{
    if (!m_businessController) {
        qDebug() << "UserModel: BusinessController not set!";
        return false;
    }

    bool success = m_businessController->createUser(userName, password, roleId, operatorUser);
    if (success) {
        // 刷新模型
        loadUsers();
    } else {
        qDebug() << "UserModel: addUser failed";
    }
    return success;
}

bool UserModel::updateUser(int userId, const QString& userName, const QString& password, int roleId, int status, const QString& operatorUser)
{
    if (!m_businessController) {
        qDebug() << "UserModel: BusinessController not set!";
        return false;
    }

    bool success = m_businessController->updateUser(userId, userName, password, roleId, status, operatorUser);
    if (success) {
        // 更新模型中的对应行
        int idx = indexOfUserId(userId);
        if (idx >= 0) {
            // 从数据库重新获取最新数据（简单方式）
            loadUsers();
        }
    } else {
        qDebug() << "UserModel: updateUser failed";
    }
    return success;
}

bool UserModel::deleteUser(int userId, const QString& operatorUser)
{
    if (!m_businessController) {
        qDebug() << "UserModel: BusinessController not set!";
        return false;
    }

    int idx = indexOfUserId(userId);
    if (idx < 0) {
        qDebug() << "UserModel: user not found in model, id=" << userId;
        return false;
    }

    bool success = m_businessController->deleteUser(userId, operatorUser);
    if (success) {
        beginRemoveRows(QModelIndex(), idx, idx);
        m_users.removeAt(idx);
        endRemoveRows();
        emit countChanged();
    } else {
        qDebug() << "UserModel: deleteUser failed";
    }
    return success;
}

QVariant UserModel::findUserById(int userId) const
{
    int idx = indexOfUserId(userId);
    return (idx >= 0) ? getUserData(idx) : QVariant();
}

QVariant UserModel::findUserByName(const QString& userName) const
{
    for (int i = 0; i < m_users.size(); ++i) {
        if (m_users[i].userName() == userName)
            return getUserData(i);
    }
    return QVariant();
}

bool UserModel::authenticate(const QString& userName, const QString& password)
{
    if (!m_businessController) {
        qDebug() << "UserModel: BusinessController not set!";
        return false;
    }
    return m_businessController->authenticate(userName, password);
}

int UserModel::rowCount(const QModelIndex& parent) const
{
    return parent.isValid() ? 0 : m_users.size();
}

QVariant UserModel::data(const QModelIndex& index, int role) const
{
    if (!index.isValid() || index.row() >= m_users.size())
        return QVariant();

    const LEDDB::User& user = m_users[index.row()];
    switch (role) {
    case UserIdRole:         return user.userId();
    case UserNameRole:       return user.userName();
    case PasswordRole:       return user.password();
    case RoleIdRole:         return user.roleId();
    case StatusRole:         return user.status();
    case CreateTimeRole:     return user.createTime();
    case LastLoginTimeRole:  return user.lastLoginTime();
    case UpdateTimeRole:     return user.updateTime();
    default:                 return QVariant();
    }
}

QHash<int, QByteArray> UserModel::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[UserIdRole]        = "userId";
    roles[UserNameRole]      = "userName";
    roles[PasswordRole]      = "password";
    roles[RoleIdRole]        = "roleId";
    roles[StatusRole]        = "status";
    roles[CreateTimeRole]    = "createTime";
    roles[LastLoginTimeRole] = "lastLoginTime";
    roles[UpdateTimeRole]    = "updateTime";
    return roles;
}

// ---------- private helpers ----------
void UserModel::updateUserList(const QList<LEDDB::User>& newList)
{
    beginResetModel();
    m_users = newList;
    endResetModel();
    emit countChanged();
}

int UserModel::indexOfUserId(int userId) const
{
    for (int i = 0; i < m_users.size(); ++i) {
        if (m_users[i].userId() == userId)
            return i;
    }
    return -1;
}