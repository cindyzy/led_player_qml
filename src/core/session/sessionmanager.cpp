// core/session/SessionManager.cpp
#include "SessionManager.h"

SessionManager& SessionManager::instance()
{
    static SessionManager instance;
    return instance;
}

SessionManager::SessionManager(QObject* parent) : QObject(parent) {}

SessionManager::~SessionManager() {}

bool SessionManager::login(int userId, const QString& userName, int roleId)
{
    m_currentUserId = userId;
    m_currentUserName = userName;
    m_currentRoleId = roleId;
    m_loginTime = QDateTime::currentDateTime();
    m_isLoggedIn = true;
    emit loginStateChanged(true);
    emit userInfoChanged();
    return true;
}

void SessionManager::logout()
{
    m_isLoggedIn = false;
    m_currentUserId = 0;
    m_currentUserName.clear();
    m_currentRoleId = 0;
    m_loginTime = QDateTime();
    emit loginStateChanged(false);
    emit userInfoChanged();
}