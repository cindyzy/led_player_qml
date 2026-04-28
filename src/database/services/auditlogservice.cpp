// #include "auditlogservice.h"
// services/AuditLogService.cpp
#include "AuditLogService.h"
#include "../repositories/RepositoryFactory.h"
#include "../../utils/datetimehelper.h"
#include <QDateTime>

using namespace Repository;
using namespace LEDDB;

AuditLogService::AuditLogService() = default;

void AuditLogService::logOperation(const QString& operatorUser, const QString& operateType,
                                   const QString& operateContent, const QString& operateResult) {
    auto auditRepo = RepositoryFactory::createAuditLogRepository();
    AuditLog log;
    log.setOperatorUser(operatorUser);
    log.setOperateType(operateType);
    log.setOperateContent(operateContent);
    log.setOperateResult(operateResult);
    log.setOperateTime(QDateTime::currentDateTime());
    auditRepo->insert(log);
}

QList<AuditLog> AuditLogService::getLogsByUser(const QString& operatorUser, int limit) {
    auto auditRepo = RepositoryFactory::createAuditLogRepository();
    return auditRepo->findByUser(operatorUser, limit);
}

QList<AuditLog> AuditLogService::getLogsByType(const QString& operateType, int limit) {
    auto auditRepo = RepositoryFactory::createAuditLogRepository();
    return auditRepo->findByType(operateType, limit);
}

QList<AuditLog> AuditLogService::getLogsByTimeRange(const QDateTime& start, const QDateTime& end) {
    auto auditRepo = RepositoryFactory::createAuditLogRepository();
    return auditRepo->findByTimeRange(start, end);
}

QList<AuditLog> AuditLogService::getAllLogs(int offset, int limit) {
    auto auditRepo = RepositoryFactory::createAuditLogRepository();
    return auditRepo->findAll(offset, limit);
}