#ifndef AUDITLOG_H
#define AUDITLOG_H

// entities/auditlog.h
#pragma once
#include <QString>
#include <QDateTime>
#include <QSqlRecord>
namespace LEDDB {

class AuditLog {
public:
    AuditLog() = default;
    AuditLog(int logId, const QString& operatorUser, const QString& operateType,
             const QString& operateContent, const QString& operateResult,
             const QDateTime& operateTime);

    int logId() const { return m_logId; }
    void setLogId(int id) { m_logId = id; }

    QString operatorUser() const { return m_operatorUser; }
    void setOperatorUser(const QString& user) { m_operatorUser = user; }

    QString operateType() const { return m_operateType; }
    void setOperateType(const QString& type) { m_operateType = type; }

    QString operateContent() const { return m_operateContent; }
    void setOperateContent(const QString& content) { m_operateContent = content; }

    QString operateResult() const { return m_operateResult; }
    void setOperateResult(const QString& result) { m_operateResult = result; }

    QDateTime operateTime() const { return m_operateTime; }
    void setOperateTime(const QDateTime& dt) { m_operateTime = dt; }

    static AuditLog fromSqlRecord(const QSqlRecord& record);

private:
    int m_logId = 0;
    QString m_operatorUser;
    QString m_operateType;
    QString m_operateContent;
    QString m_operateResult;
    QDateTime m_operateTime;
};

} // namespace LEDDB
#endif // AUDITLOG_H
