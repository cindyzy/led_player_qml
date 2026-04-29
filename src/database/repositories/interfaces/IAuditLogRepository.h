#ifndef IAUDITLOGREPOSITORY_H
#define IAUDITLOGREPOSITORY_H

// repositories/interfaces/IAuditLogRepository.h
#pragma once
#include "../../entities/auditlog.h"
#include <QList>
#include <QDateTime>

namespace Repository {

class IAuditLogRepository {
public:
    virtual ~IAuditLogRepository() = default;

    virtual bool insert(const LEDDB::AuditLog& log) = 0;
    virtual QList<LEDDB::AuditLog> findByUserId(int userId,int limit = 100) = 0;
    virtual QList<LEDDB::AuditLog> findByTimeRange(const QDateTime& start, const QDateTime& end) = 0;
    virtual QList<LEDDB::AuditLog> findByOperationType(const QString& operationType,int limit = 100) = 0;
    virtual QList<LEDDB::AuditLog> findAll(int offset = 0, int limit = 100) = 0;
};

} // namespace Repository

#endif // IAUDITLOGREPOSITORY_H
