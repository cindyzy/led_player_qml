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

    void logOperation(const QString& operatorUser, const QString& operateType,
                      const QString& operateContent, const QString& operateResult);
    QList<LEDDB::AuditLog> getLogsByUser(const QString& operatorUser, int limit = 100);
    QList<LEDDB::AuditLog> getLogsByType(const QString& operateType, int limit = 100);
    QList<LEDDB::AuditLog> getLogsByTimeRange(const QDateTime& start, const QDateTime& end);
    QList<LEDDB::AuditLog> getAllLogs(int offset = 0, int limit = 100);
};

#endif // AUDITLOGSERVICE_H
