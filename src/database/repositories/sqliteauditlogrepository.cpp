#include "sqliteauditlogrepository.h"
// repositories/sqlite_auditlog_repository.cpp
// #include "sqlite_auditlog_repository.h"
#include "../databasemanager.h"
#include "../../utils/datetimehelper.h"
#include <QSqlQuery>

using namespace Repository;

bool SqliteAuditLogRepository::insert(const LEDDB::AuditLog& log) {
    QSqlDatabase db = DatabaseManager::instance().getDatabase();
    QSqlQuery query(db);
    query.prepare(R"(
        INSERT INTO sys_audit_log (
            user_id, operation_type, operate_result, operate_time,
            operation_desc, target_table, target_id, client_ip, create_time
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
    )");
    query.addBindValue(log.userId());
    query.addBindValue(log.operationType());
    query.addBindValue(log.operateResult());
    query.addBindValue(toIsoString(log.operateTime()));
    query.addBindValue(log.operationDesc());
    query.addBindValue(log.targetTable());
    query.addBindValue(log.targetId());
    query.addBindValue(log.clientIp());
    query.addBindValue(toIsoString(log.createTime()));

    if (!query.exec()) {
        qCritical() << "insert AuditLog failed:" << query.lastError().text();
        return false;
    }
    return true;
}
QList<LEDDB::AuditLog> SqliteAuditLogRepository::findByUserId(int userId, int limit) {
    QList<LEDDB::AuditLog> list;
    QSqlQuery query(DatabaseManager::instance().getDatabase());
    query.prepare("SELECT * FROM sys_audit_log WHERE user_id = ? ORDER BY operate_time DESC LIMIT ?");
    query.addBindValue(userId);
    query.addBindValue(limit);
    if (!query.exec()) {
        qCritical() << "findByUserId failed:" << query.lastError().text();
        return list;
    }
    while (query.next()) {
        list.append(LEDDB::AuditLog::fromSqlRecord(query.record()));
    }
    return list;
}

QList<LEDDB::AuditLog> SqliteAuditLogRepository::findByTimeRange(const QDateTime& start, const QDateTime& end) {
    QList<LEDDB::AuditLog> list;
    QSqlQuery query(DatabaseManager::instance().getDatabase());
    query.prepare("SELECT * FROM sys_audit_log WHERE operate_time BETWEEN ? AND ? ORDER BY operate_time");
    query.addBindValue(toIsoString(start));
    query.addBindValue(toIsoString(end));
    if (!query.exec()) {
        qCritical() << "findByTimeRange failed:" << query.lastError().text();
        return list;
    }
    while (query.next()) {
        list.append(LEDDB::AuditLog::fromSqlRecord(query.record()));
    }
    return list;
}

QList<LEDDB::AuditLog> SqliteAuditLogRepository::findByOperationType(const QString& operationType, int limit) {
    QList<LEDDB::AuditLog> list;
    QSqlQuery query(DatabaseManager::instance().getDatabase());
    query.prepare("SELECT * FROM sys_audit_log WHERE operation_type = ? ORDER BY operate_time DESC LIMIT ?");
    query.addBindValue(operationType);
    query.addBindValue(limit);
    if (!query.exec()) {
        qCritical() << "findByOperationType failed:" << query.lastError().text();
        return list;
    }
    while (query.next()) {
        list.append(LEDDB::AuditLog::fromSqlRecord(query.record()));
    }
    return list;
}

QList<LEDDB::AuditLog> SqliteAuditLogRepository::findAll(int offset, int limit) {
    QList<LEDDB::AuditLog> list;
    QSqlQuery query(DatabaseManager::instance().getDatabase());
    query.prepare("SELECT * FROM sys_audit_log ORDER BY operate_time DESC LIMIT ? OFFSET ?");
    query.addBindValue(limit);
    query.addBindValue(offset);
    if (!query.exec()) {
        qCritical() << "findAll failed:" << query.lastError().text();
        return list;
    }
    while (query.next()) {
        list.append(LEDDB::AuditLog::fromSqlRecord(query.record()));
    }
    return list;
}