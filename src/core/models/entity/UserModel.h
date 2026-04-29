#ifndef USERMODEL_H
#define USERMODEL_H

#include <QAbstractListModel>
#include "../../../business/businesscontroller.h"
#include "../../../database/entities/user.h"

class UserModel : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)

public:
    enum Roles {
        UserIdRole = Qt::UserRole + 1,
        UserNameRole,
        PasswordRole,
        RoleIdRole,
        StatusRole,
        CreateTimeRole,
        LastLoginTimeRole,
        UpdateTimeRole
    };

    explicit UserModel(QObject *parent = nullptr);
    void setBusinessController(BusinessController* controller);

    Q_INVOKABLE bool loadUsers();
    Q_INVOKABLE QVariant getUserData(int index) const;
    Q_INVOKABLE bool addUser(const QString& userName, const QString& password, int roleId, const QString& operatorUser);
    Q_INVOKABLE bool updateUser(int userId, const QString& userName, const QString& password, int roleId, int status, const QString& operatorUser);
    Q_INVOKABLE bool deleteUser(int userId, const QString& operatorUser);
    Q_INVOKABLE QVariant findUserById(int userId) const;
    Q_INVOKABLE QVariant findUserByName(const QString& userName) const;
    Q_INVOKABLE bool authenticate(const QString& userName, const QString& password);

    // QAbstractListModel 接口
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

signals:
    void countChanged();

private:
    BusinessController* m_businessController = nullptr;
    QList<LEDDB::User> m_users;

    void updateUserList(const QList<LEDDB::User>& newList);
    int indexOfUserId(int userId) const;
};


#endif // USERMODEL_H