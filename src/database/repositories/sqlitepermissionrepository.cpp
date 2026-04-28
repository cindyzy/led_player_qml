#include "sqlitepermissionrepository.h"

// repositories/sqlite_permission_repository.cpp
#include "../databasemanager.h"
#include <QSqlQuery>

using namespace Repository;

bool SqlitePermissionRepository::insert(const LEDDB::Permission& perm) {
    QSqlQuery query(DatabaseManager::instance().getDatabase());
    query.prepare("INSERT INTO sys_permission (role_id, perm_code, perm_desc) VALUES (?, ?, ?)");
    query.addBindValue(perm.roleId());
    query.addBindValue(perm.permCode());
    query.addBindValue(perm.permDesc());
    return query.exec();
}

bool SqlitePermissionRepository::update(const LEDDB::Permission& perm) {
    QSqlQuery query(DatabaseManager::instance().getDatabase());
    query.prepare("UPDATE sys_permission SET role_id=?, perm_code=?, perm_desc=? WHERE perm_id=?");
    query.addBindValue(perm.roleId());
    query.addBindValue(perm.permCode());
    query.addBindValue(perm.permDesc());
    query.addBindValue(perm.permId());
    return query.exec();
}

bool SqlitePermissionRepository::deleteById(int permId) {
    QSqlQuery query(DatabaseManager::instance().getDatabase());
    query.prepare("DELETE FROM sys_permission WHERE perm_id = ?");
    query.addBindValue(permId);
    return query.exec();
}

bool SqlitePermissionRepository::deleteByRoleId(int roleId) {
    QSqlQuery query(DatabaseManager::instance().getDatabase());
    query.prepare("DELETE FROM sys_permission WHERE role_id = ?");
    query.addBindValue(roleId);
    return query.exec();
}

QList<LEDDB::Permission> SqlitePermissionRepository::findByRoleId(int roleId) {
    QList<LEDDB::Permission> list;
    QSqlQuery query(DatabaseManager::instance().getDatabase());
    query.prepare("SELECT * FROM sys_permission WHERE role_id = ?");
    query.addBindValue(roleId);
    if (!query.exec()) return list;
    while (query.next()) list.append(LEDDB::Permission::fromSqlRecord(query.record()));
    return list;
}