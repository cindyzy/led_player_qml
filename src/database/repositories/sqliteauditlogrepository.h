#ifndef SQLITEAUDITLOGREPOSITORY_H
#define SQLITEAUDITLOGREPOSITORY_H

// repositories/sqlite_auditlog_repository.h
#pragma once
#include "interfaces/IAuditLogRepository.h"

namespace Repository {

class SqliteAuditLogRepository : public IAuditLogRepository {
public:
    bool insert(const LEDDB::AuditLog& log) override;
    QList<LEDDB::AuditLog> findByUserId(int userId, int limit) override;
    QList<LEDDB::AuditLog> findByTimeRange(const QDateTime& start, const QDateTime& end) override;
    QList<LEDDB::AuditLog> findByOperationType(const QString& operationType, int limit = 100) override;
    QList<LEDDB::AuditLog> findAll(int offset = 0, int limit = 100) override;
};

} // namespace Repository
#endif // SQLITEAUDITLOGREPOSITORY_H
