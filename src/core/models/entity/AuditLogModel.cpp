#include "AuditLogModel.h"
#include <QDebug>

AuditLogModel::AuditLogModel(QObject* parent) : QAbstractListModel(parent)
{
}

void AuditLogModel::setBusinessController(BusinessController* controller)
{
    m_businessController = controller;
}

bool AuditLogModel::loadLogs(int userId, const QDateTime& startTime, const QDateTime& endTime, const QString& operationType)
{
    if (!m_businessController) {
        qDebug() << "AuditLogModel: BusinessController not set!";
        return false;
    }
    QList<LEDDB::AuditLog> logs;
    
    if (!operationType.isEmpty()) {
        logs = m_businessController->getLogsByType(operationType, 0);
    } else if (userId > 0) {
        logs = m_businessController->getLogsByUser(userId, 0);
    } else if (startTime.isValid() && endTime.isValid()) {
        logs = m_businessController->getLogsByTimeRange(startTime, endTime);
    } else {
        logs = m_businessController->getAllLogs(0, 1000);
    }
    
    beginResetModel();
    m_logs = logs;
    m_totalCount = logs.size();
    endResetModel();
    emit countChanged();
    emit totalCountChanged();
    return true;
}

bool AuditLogModel::loadLogsByPage(int offset, int limit)
{
    if (!m_businessController) {
        qDebug() << "AuditLogModel: BusinessController not set!";
        return false;
    }
    
    QList<LEDDB::AuditLog> logs = m_businessController->getAllLogs(offset, limit);
    
    if (offset == 0) {
        beginResetModel();
        m_logs = logs;
    } else {
        int start = m_logs.size();
        beginInsertRows(QModelIndex(), start, start + logs.size() - 1);
        m_logs.append(logs);
        endInsertRows();
    }
    
    // 估算总数（实际应从数据库查询）
    if (m_totalCount == 0) {
        m_totalCount = 1000; // 默认值，实际应查询
    }
    
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
    map["operateResult"] = log.operateResult();
    map["operateTime"] = log.operateTime().toString("yyyy-MM-dd HH:mm:ss");
    map["operationDesc"] = log.operationDesc();
    map["targetTable"] = log.targetTable();
    map["targetId"] = log.targetId();
    map["clientIp"] = log.clientIp();
    map["createTime"] = log.createTime().toString("yyyy-MM-dd HH:mm:ss");
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

void AuditLogModel::clearLogs()
{
    beginResetModel();
    m_logs.clear();
    m_totalCount = 0;
    endResetModel();
    emit countChanged();
    emit totalCountChanged();
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
    case OperateResultRole: return log.operateResult();
    case OperateTimeRole: return log.operateTime().toString("yyyy-MM-dd HH:mm:ss");
    case OperationDescRole: return log.operationDesc();
    case TargetTableRole: return log.targetTable();
    case TargetIdRole: return log.targetId();
    case ClientIpRole: return log.clientIp();
    case CreateTimeRole: return log.createTime().toString("yyyy-MM-dd HH:mm:ss");
    default: return QVariant();
    }
}

QHash<int, QByteArray> AuditLogModel::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[LogIdRole] = "logId";
    roles[UserIdRole] = "userId";
    roles[OperationTypeRole] = "operationType";
    roles[OperateResultRole] = "operateResult";
    roles[OperateTimeRole] = "operateTime";
    roles[OperationDescRole] = "operationDesc";
    roles[TargetTableRole] = "targetTable";
    roles[TargetIdRole] = "targetId";
    roles[ClientIpRole] = "clientIp";
    roles[CreateTimeRole] = "createTime";
    return roles;
}