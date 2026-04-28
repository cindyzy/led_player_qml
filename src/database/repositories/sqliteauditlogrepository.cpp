#include "sqliteauditlogrepository.h"
// repositories/sqlite_auditlog_repository.cpp
// #include "sqlite_auditlog_repository.h"
#include "../databasemanager.h"
#include "../../utils/datetimehelper.h"
#include <QSqlQuery>

using namespace Repository;

bool SqliteAuditLogRepository::insert(const LEDDB::AuditLog& log) {
    QSqlQuery query(DatabaseManager::instance().getDatabase());
    query.prepare(R"(
        INSERT INTO sys_audit_log (operator_user, operate_type, operate_content, operate_result, operate_time)
        VALUES (?, ?, ?, ?, ?)
    )");
    query.addBindValue(log.operatorUser());
    query.addBindValue(log.operateType());
    query.addBindValue(log.operateContent());
    query.addBindValue(log.operateResult());
    query.addBindValue(toIsoString(log.operateTime()));
    return query.exec();
}

QList<LEDDB::AuditLog> SqliteAuditLogRepository::findByUser(const QString& operatorUser, int limit) {
    QList<LEDDB::AuditLog> list;
    QSqlQuery query(DatabaseManager::instance().getDatabase());
    query.prepare("SELECT * FROM sys_audit_log WHERE operator_user = ? ORDER BY operate_time DESC LIMIT ?");
    query.addBindValue(operatorUser);
    query.addBindValue(limit);
    if (!query.exec()) return list;
    while (query.next()) list.append(LEDDB::AuditLog::fromSqlRecord(query.record()));
    return list;
}

QList<LEDDB::AuditLog> SqliteAuditLogRepository::findByTimeRange(const QDateTime& start, const QDateTime& end) {
    QList<LEDDB::AuditLog> list;
    QSqlQuery query(DatabaseManager::instance().getDatabase());
    query.prepare("SELECT * FROM sys_audit_log WHERE operate_time BETWEEN ? AND ? ORDER BY operate_time");
    query.addBindValue(toIsoString(start));
    query.addBindValue(toIsoString(end));
    if (!query.exec()) return list;
    while (query.next()) list.append(LEDDB::AuditLog::fromSqlRecord(query.record()));
    return list;
}

QList<LEDDB::AuditLog> SqliteAuditLogRepository::findByType(const QString& operateType, int limit) {
    QList<LEDDB::AuditLog> list;
    QSqlQuery query(DatabaseManager::instance().getDatabase());
    query.prepare("SELECT * FROM sys_audit_log WHERE operate_type = ? ORDER BY operate_time DESC LIMIT ?");
    query.addBindValue(operateType);
    query.addBindValue(limit);
    if (!query.exec()) return list;
    while (query.next()) list.append(LEDDB::AuditLog::fromSqlRecord(query.record()));
    return list;
}

QList<LEDDB::AuditLog> SqliteAuditLogRepository::findAll(int offset, int limit) {
    QList<LEDDB::AuditLog> list;
    QSqlQuery query(DatabaseManager::instance().getDatabase());
    query.prepare("SELECT * FROM sys_audit_log ORDER BY operate_time DESC LIMIT ? OFFSET ?");
    query.addBindValue(limit);
    query.addBindValue(offset);
    if (!query.exec()) return list;
    while (query.next()) list.append(LEDDB::AuditLog::fromSqlRecord(query.record()));
    return list;
}