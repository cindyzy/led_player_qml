// #include "auditlogservice.h"
// services/AuditLogService.cpp
#include "AuditLogService.h"
#include "../repositories/RepositoryFactory.h"
#include "../../utils/datetimehelper.h"
#include <QDateTime>
#include <QDebug>

using namespace Repository;
using namespace LEDDB;

AuditLogService::AuditLogService() = default;

void AuditLogService::logOperation(int userId,
                                   const QString& operationType,
                                   const QString& operateResult,
                                   const QString& operationDesc,
                                   const QString& targetTable,
                                   int targetId,
                                   const QString& clientIp) {
    auto auditRepo = RepositoryFactory::createAuditLogRepository();
    AuditLog log;
    log.setUserId(userId);
    log.setOperationType(operationType);
    log.setOperateResult(operateResult);
    log.setOperationDesc(operationDesc);
    log.setTargetTable(targetTable);
    log.setTargetId(targetId);
    log.setClientIp(clientIp);
    log.setOperateTime(QDateTime::currentDateTime());
    log.setCreateTime(QDateTime::currentDateTime());   // 入库时间

    if (!auditRepo->insert(log)) {
        qWarning() << "AuditLogService: failed to insert log for user" << userId;
    }
}
// void AuditLogService::logSimple(int userId,
//                                 const QString& operationType,
//                                 const QString& operateResult,
//                                 const QString& operationDesc) {
//     logOperation(userId, operationType, operateResult, operationDesc, QString(), 0, QString());
// }

// void AuditLogService::logSimple(const QString& userName,
//                                 const QString& operationType,
//                                 const QString& operateResult,
//                                 const QString& operationDesc) {
//     auto userRepo = RepositoryFactory::createUserRepository();
//     auto users = userRepo->findByUserName(userName);
//     if (!users.isEmpty()) {
//         logSimple(users.first().userId(), operationType, operateResult, operationDesc);
//     } else {
//         logSimple(0, operationType + " [" + userName + "]", operateResult, operationDesc);
//     }
// }
QList<AuditLog> AuditLogService::getLogsByUserId(int userId, int limit) {
    auto auditRepo = RepositoryFactory::createAuditLogRepository();
    return auditRepo->findByUserId(userId, limit);
}

QList<AuditLog> AuditLogService::getLogsByOperationType(const QString& operationType, int limit) {
    auto auditRepo = RepositoryFactory::createAuditLogRepository();
    return auditRepo->findByOperationType(operationType, limit);
}

QList<AuditLog> AuditLogService::getLogsByTimeRange(const QDateTime& start, const QDateTime& end) {
    auto auditRepo = RepositoryFactory::createAuditLogRepository();
    return auditRepo->findByTimeRange(start, end);
}

QList<AuditLog> AuditLogService::getAllLogs(int offset, int limit) {
    auto auditRepo = RepositoryFactory::createAuditLogRepository();
    return auditRepo->findAll(offset, limit);
}