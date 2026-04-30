// repositories/sqlite_role_repository.cpp
#include "sqliterolerepository.h"
#include "../databasemanager.h"
#include <QSqlQuery>
#include <QSqlRecord>

using namespace Repository;

bool SqliteRoleRepository::insert(const LEDDB::Role& role) {
    QSqlQuery query(DatabaseManager::instance().getDatabase());
    query.prepare("INSERT INTO sys_role (role_name, role_desc) VALUES (?, ?)");
    query.addBindValue(role.roleName());
    query.addBindValue(role.roleDesc());
    return query.exec();
}

bool SqliteRoleRepository::update(const LEDDB::Role& role) {
    QSqlQuery query(DatabaseManager::instance().getDatabase());
    query.prepare("UPDATE sys_role SET role_name=?, role_desc=? WHERE role_id=?");
    query.addBindValue(role.roleName());
    query.addBindValue(role.roleDesc());
    query.addBindValue(role.roleId());
    return query.exec();
}

bool SqliteRoleRepository::deleteById(int roleId) {
    QSqlQuery query(DatabaseManager::instance().getDatabase());
    query.prepare("DELETE FROM sys_role WHERE role_id = ?");
    query.addBindValue(roleId);
    return query.exec();
}

std::optional<LEDDB::Role> SqliteRoleRepository::findById(int roleId) {
    QSqlQuery query(DatabaseManager::instance().getDatabase());
    query.prepare("SELECT * FROM sys_role WHERE role_id = ?");
    query.addBindValue(roleId);
    if (!query.exec() || !query.next()) return std::nullopt;
    return LEDDB::Role::fromSqlRecord(query.record());
}

std::optional<LEDDB::Role> SqliteRoleRepository::findByName(const QString& roleName) {
    QSqlQuery query(DatabaseManager::instance().getDatabase());
    query.prepare("SELECT * FROM sys_role WHERE role_name = ?");
    query.addBindValue(roleName);
    if (!query.exec() || !query.next()) return std::nullopt;
    return LEDDB::Role::fromSqlRecord(query.record());
}

QList<LEDDB::Role> SqliteRoleRepository::findAll() {
    QList<LEDDB::Role> list;
    QSqlQuery query("SELECT * FROM sys_role", DatabaseManager::instance().getDatabase());
    while (query.next()) list.append(LEDDB::Role::fromSqlRecord(query.record()));
    return list;
}