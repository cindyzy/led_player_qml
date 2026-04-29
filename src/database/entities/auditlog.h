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
    AuditLog(int logId, int userId, const QString& operationType,
             const QString& operateResult, const QDateTime& operateTime,
             const QString& operationDesc, const QString& targetTable,
             int targetId, const QString& clientIp, const QDateTime& createTime);

    // ---------- getters ----------
    int logId() const { return m_logId; }
    int userId() const { return m_userId; }
    QString operationType() const { return m_operationType; }
    QString operateResult() const { return m_operateResult; }
    QDateTime operateTime() const { return m_operateTime; }
    QString operationDesc() const { return m_operationDesc; }
    QString targetTable() const { return m_targetTable; }
    int targetId() const { return m_targetId; }
    QString clientIp() const { return m_clientIp; }
    QDateTime createTime() const { return m_createTime; }

    // ---------- setters ----------
    void setLogId(int id) { m_logId = id; }
    void setUserId(int id) { m_userId = id; }
    void setOperationType(const QString& type) { m_operationType = type; }
    void setOperateResult(const QString& result) { m_operateResult = result; }
    void setOperateTime(const QDateTime& dt) { m_operateTime = dt; }
    void setOperationDesc(const QString& desc) { m_operationDesc = desc; }
    void setTargetTable(const QString& table) { m_targetTable = table; }
    void setTargetId(int id) { m_targetId = id; }
    void setClientIp(const QString& ip) { m_clientIp = ip; }
    void setCreateTime(const QDateTime& dt) { m_createTime = dt; }

    // 从 SQL 查询记录构建对象
    static AuditLog fromSqlRecord(const QSqlRecord& record);

private:
    int m_logId = 0;
    int m_userId = 0;               // 操作人用户ID
    QString m_operationType;          // 操作类型（如"登录"、"修改设备"）
    QString m_operateResult;        // 操作结果（成功/失败）
    QDateTime m_operateTime;        // 操作发生的时间（用户触发操作的时间）
    QString m_operationDesc;        // 操作详细描述
    QString m_targetTable;          // 操作目标表名（如"led_device"）
    int m_targetId = 0;             // 操作目标记录ID
    QString m_clientIp;             // 客户端IP地址
    QDateTime m_createTime;         // 日志记录创建时间（入库时间）
};

} // namespace LEDDB
#endif // AUDITLOG_H
