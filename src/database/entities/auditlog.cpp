#include "auditlog.h"

// entities/auditlog.cpp
// #include "auditlog.h"
#include "../../utils/datetimehelper.h"


namespace LEDDB {

AuditLog::AuditLog(int logId, int userId, const QString& operationType,
                   const QString& operateResult, const QDateTime& operateTime,
                   const QString& operationDesc, const QString& targetTable,
                   int targetId, const QString& clientIp, const QDateTime& createTime)
    : m_logId(logId)
    , m_userId(userId)
    , m_operationType(operationType)
    , m_operateResult(operateResult)
    , m_operateTime(operateTime)
    , m_operationDesc(operationDesc)
    , m_targetTable(targetTable)
    , m_targetId(targetId)
    , m_clientIp(clientIp)
    , m_createTime(createTime)
{
}

AuditLog AuditLog::fromSqlRecord(const QSqlRecord& record)
{
    AuditLog log;
    log.setLogId(record.value("log_id").toInt());
    log.setUserId(record.value("user_id").toInt());
    log.setOperationType(record.value("operation_type").toString());
    log.setOperateResult(record.value("operate_result").toString());
    log.setOperateTime(fromIsoString(record.value("operate_time").toString()));
    log.setOperationDesc(record.value("operation_desc").toString());
    log.setTargetTable(record.value("target_table").toString());
    log.setTargetId(record.value("target_id").toInt());
    log.setClientIp(record.value("client_ip").toString());
    log.setCreateTime(fromIsoString(record.value("create_time").toString()));
    return log;
}

} // namespace LEDDB
