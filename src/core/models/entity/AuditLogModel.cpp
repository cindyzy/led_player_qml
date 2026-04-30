#include "AuditLogModel.h"
#include <QDebug>

AuditLogModel::AuditLogModel(QObject* parent) : QAbstractListModel(parent)
{
}

void AuditLogModel::setBusinessController(BusinessController* controller)
{
    m_businessController = controller;
}

bool AuditLogModel::loadLogs(int userId, const QDateTime& startTime, const QDateTime& endTime)
{
    if (!m_businessController) {
        qDebug() << "AuditLogModel: BusinessController not set!";
        return false;
    }
    QList<LEDDB::AuditLog> logs;
    if (userId > 0) {
        logs = m_businessController->getLogsByUser(userId,0);
    } else if (startTime.isValid() && endTime.isValid()) {
        logs = m_businessController->getLogsByTimeRange(startTime, endTime);
    } else {
        logs = m_businessController->getAllLogs();
    }
    beginResetModel();
    m_logs = logs;
    endResetModel();
    emit countChanged();
    return true;
}

QVariant AuditLogModel::getLogData(int index) const
{
    if (index < 0 || index >= m_logs.size()) return QVariant();
    const LEDDB::AuditLog& log = m_logs[index];
    QVariantMap map;
    map["logId"] = log.logId();
    map["userId"] = log.userId();
    map["operationType"] = log.operationType();
    map["operationDesc"] = log.operationDesc();
    map["targetTable"] = log.targetTable();
    map["targetId"] = log.targetId();
    map["clientIp"] = log.clientIp();
    map["createTime"] = log.createTime().toString();
    return map;
}

bool AuditLogModel::addLog(int userId, const QString& operationType,const QString& operateResult, const QString& operationDesc,
                           const QString& targetTable, int targetId, const QString& clientIp)
{
    if (!m_businessController) {
        qDebug() << "AuditLogModel: BusinessController not set!";
        return false;
    }
     m_businessController->logOperation(userId, operationType,operateResult, operationDesc, targetTable, targetId, clientIp);
    // if (success) {
    //     loadLogs(0, QDateTime(), QDateTime());
    // }
    return true;
}

QVariant AuditLogModel::findLogById(int logId) const
{
    for (int i = 0; i < m_logs.size(); ++i) {
        if (m_logs[i].logId() == logId) {
            return getLogData(i);
        }
    }
    return QVariant();
}

int AuditLogModel::rowCount(const QModelIndex& parent) const
{
    Q_UNUSED(parent);
    return m_logs.size();
}

QVariant AuditLogModel::data(const QModelIndex& index, int role) const
{
    if (!index.isValid() || index.row() >= m_logs.size()) return QVariant();
    const LEDDB::AuditLog& log = m_logs[index.row()];
    switch (role) {
    case LogIdRole: return log.logId();
    case UserIdRole: return log.userId();
    case OperationTypeRole: return log.operationType();
    case OperationDescRole: return log.operationDesc();
    case TargetTableRole: return log.targetTable();
    case TargetIdRole: return log.targetId();
    case ClientIpRole: return log.clientIp();
    case CreateTimeRole: return log.createTime();
    default: return QVariant();
    }
}

QHash<int, QByteArray> AuditLogModel::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[LogIdRole] = "logId";
    roles[UserIdRole] = "userId";
    roles[OperationTypeRole] = "operationType";
    roles[OperationDescRole] = "operationDesc";
    roles[TargetTableRole] = "targetTable";
    roles[TargetIdRole] = "targetId";
    roles[ClientIpRole] = "clientIp";
    roles[CreateTimeRole] = "createTime";
    return roles;
}