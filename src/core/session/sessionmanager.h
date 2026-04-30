// core/session/SessionManager.h
#ifndef SESSIONMANAGER_H
#define SESSIONMANAGER_H

#include <QObject>
#include <QDateTime>
#include <optional>
#include "../../database/entities/user.h"
class SessionManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool isLoggedIn READ isLoggedIn NOTIFY loginStateChanged)
    Q_PROPERTY(QString currentUserName READ currentUserName NOTIFY userInfoChanged)
    Q_PROPERTY(int currentUserId READ currentUserId NOTIFY userInfoChanged)
    Q_PROPERTY(int currentRoleId READ currentRoleId NOTIFY userInfoChanged)

public:
    static SessionManager& instance();

    // 登录/登出
    bool login(int userId, const QString& userName, int roleId);
    void logout();

    // 状态查询
    bool isLoggedIn() const { return m_isLoggedIn; }
    QString currentUserName() const { return m_currentUserName; }
    int currentUserId() const { return m_currentUserId; }
    int currentRoleId() const { return m_currentRoleId; }
    QDateTime loginTime() const { return m_loginTime; }

signals:
    void loginStateChanged(bool loggedIn);
    void userInfoChanged();

private:
    explicit SessionManager(QObject* parent = nullptr);
    ~SessionManager();
    SessionManager(const SessionManager&) = delete;
    SessionManager& operator=(const SessionManager&) = delete;

    bool m_isLoggedIn = false;
    QString m_currentUserName;
    int m_currentUserId = 0;
    int m_currentRoleId = 0;
    QDateTime m_loginTime;
};

#endif // SESSIONMANAGER_H