// repositories/sqlite_user_repository.cpp
#include "sqliteuserrepository.h"
#include "../databasemanager.h"
#include "../../utils/datetimehelper.h"
#include "../../utils/cryptohelper.h"
#include <QSqlQuery>
#include <QSqlRecord>
#include <QSqlError>

using namespace LEDDB;
using namespace Repository;

bool SqliteUserRepository::insert(const User& user) {
    QSqlQuery query(DatabaseManager::instance().getDatabase());
    query.prepare(R"(
        INSERT INTO sys_user (user_name, password, role_id, status, create_time, last_login_time)
        VALUES (:un, :pwd, :rid, :st, :ct, :lt)
    )");
    query.bindValue(":un", user.userName());
    query.bindValue(":pwd", CryptoHelper::aesEncrypt(user.password()));
    query.bindValue(":rid", user.roleId());
    query.bindValue(":st", user.status());
    query.bindValue(":ct", toIsoString(user.createTime()));
    query.bindValue(":lt", toIsoString(user.lastLoginTime()));
    return query.exec();
}

bool SqliteUserRepository::update(const User& user) {
    QSqlQuery query(DatabaseManager::instance().getDatabase());
    query.prepare(R"(
        UPDATE sys_user SET user_name=:un, password=:pwd, role_id=:rid,
        status=:st, last_login_time=:lt WHERE user_id=:uid
    )");
    query.bindValue(":un", user.userName());
    query.bindValue(":pwd", CryptoHelper::aesEncrypt(user.password()));
    query.bindValue(":rid", user.roleId());
    query.bindValue(":st", user.status());
    query.bindValue(":lt", toIsoString(user.lastLoginTime()));
    query.bindValue(":uid", user.userId());
    return query.exec();
}

bool SqliteUserRepository::deleteById(int userId) {
    QSqlQuery query(DatabaseManager::instance().getDatabase());
    query.prepare("DELETE FROM sys_user WHERE user_id = ?");
    query.addBindValue(userId);
    return query.exec();
}

std::optional<User> SqliteUserRepository::findById(int userId) {
    QSqlQuery query(DatabaseManager::instance().getDatabase());
    query.prepare("SELECT * FROM sys_user WHERE user_id = ?");
    query.addBindValue(userId);
    if (!query.exec() || !query.next()) return std::nullopt;
    User u = User::fromSqlRecord(query.record());
    // 注意：密码保持密文，上层如需明文自行解密
    return u;
}

std::optional<User> SqliteUserRepository::findByUserName(const QString& userName) {
    QSqlQuery query(DatabaseManager::instance().getDatabase());
    query.prepare("SELECT * FROM sys_user WHERE user_name = ?");
    query.addBindValue(userName);
    if (!query.exec() || !query.next()) return std::nullopt;
    return User::fromSqlRecord(query.record());
}

QList<User> SqliteUserRepository::findAll(int offset, int limit) {
    QList<User> list;
    QSqlQuery query(DatabaseManager::instance().getDatabase());
    query.prepare("SELECT * FROM sys_user LIMIT ? OFFSET ?");
    query.addBindValue(limit);
    query.addBindValue(offset);
    if (!query.exec()) return list;
    while (query.next()) {
        list.append(User::fromSqlRecord(query.record()));
    }
    return list;
}

bool SqliteUserRepository::authenticate(const QString& userName, const QString& plainPassword) {
    auto user = findByUserName(userName);
    if (!user) return false;
    QString decrypted = CryptoHelper::aesDecrypt(user->password().toLocal8Bit());
    return decrypted == plainPassword;
}

bool SqliteUserRepository::exists(const QString& userName) {
    QSqlQuery query(DatabaseManager::instance().getDatabase());
    query.prepare("SELECT 1 FROM sys_user WHERE user_name = ?");
    query.addBindValue(userName);
    return query.exec() && query.next();
}