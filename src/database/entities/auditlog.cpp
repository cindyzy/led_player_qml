#include "auditlog.h"

// entities/auditlog.cpp
// #include "auditlog.h"
#include "../../utils/datetimehelper.h"


namespace LEDDB {

AuditLog::AuditLog(int logId, const QString& operatorUser, const QString& operateType,
                   const QString& operateContent, const QString& operateResult,
                   const QDateTime& operateTime)
    : m_logId(logId), m_operatorUser(operatorUser), m_operateType(operateType),
    m_operateContent(operateContent), m_operateResult(operateResult), m_operateTime(operateTime) {}

AuditLog AuditLog::fromSqlRecord(const QSqlRecord& rec)
{
    AuditLog al;
    al.setLogId(rec.value("log_id").toInt());
    al.setOperatorUser(rec.value("operator_user").toString());
    al.setOperateType(rec.value("operate_type").toString());
    al.setOperateContent(rec.value("operate_content").toString());
    al.setOperateResult(rec.value("operate_result").toString());
    al.setOperateTime(fromIsoString(rec.value("operate_time").toString()));
    return al;
}

} // namespace LEDDB
