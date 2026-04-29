#ifndef AUDITLOGSERVICE_H
#define AUDITLOGSERVICE_H

// services/AuditLogService.h
#pragma once
#include "../entities/auditlog.h"
#include <QList>
#include <QDateTime>

class AuditLogService {
public:
    AuditLogService();

    // 完整版：记录操作日志
    void logOperation(int userId,
                      const QString& operationType,
                      const QString& operateResult,
                      const QString& operationDesc,
                      const QString& targetTable,
                      int targetId,
                      const QString& clientIp = QString());

    // // 简化版：仅记录基本操作（不关联具体表）
    // void logSimple(int userId,
    //                const QString& operationType,
    //                const QString& operateResult,
    //                const QString& operationDesc);

    // // 简化版重载：使用用户名而非用户ID
    // void logSimple(const QString& userName,
    //                const QString& operationType,
    //                const QString& operateResult,
    //                const QString& operationDesc);

    // 查询方法
    QList<LEDDB::AuditLog> getLogsByUserId(int userId, int limit = 100);
    QList<LEDDB::AuditLog> getLogsByOperationType(const QString& operationType, int limit = 100);
    QList<LEDDB::AuditLog> getLogsByTimeRange(const QDateTime& start, const QDateTime& end);
    QList<LEDDB::AuditLog> getAllLogs(int offset = 0, int limit = 100);
};

#endif // AUDITLOGSERVICE_H
