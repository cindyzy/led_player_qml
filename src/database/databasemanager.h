// databasemanager.h
#pragma once
#include <QObject>
#include <QSqlDatabase>
#include <QSqlError>
#include <QString>

class DatabaseManager : public QObject
{
    Q_OBJECT
public:
    static DatabaseManager& instance();
    bool initDatabase(const QString& path);
    void closeDatabase();
    void createIndexes();
    QSqlDatabase getDatabase() const { return m_db; }

    // 事务管理
    bool beginTransaction();
    bool commitTransaction();
    bool rollbackTransaction();

    // 备份恢复
    bool backupTo(const QString& backupPath);
    bool restoreFrom(const QString& backupPath);
    bool checkIntegrity();

    // 开启WAL模式（在init后调用一次）
    void enableWALMode();

private:
    explicit DatabaseManager(QObject* parent = nullptr);
    ~DatabaseManager();
    DatabaseManager(const DatabaseManager&) = delete;
    DatabaseManager& operator=(const DatabaseManager&) = delete;

    bool createTables();          // 根据文档建13张表

    QSqlDatabase m_db;
    QString m_dbPath;
};