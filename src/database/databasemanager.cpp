// databasemanager.cpp
#include "databasemanager.h"
#include <QSqlQuery>
#include <QSqlRecord>
#include <QSqlError>
#include <QFile>
#include <QFileInfo>
#include <QDebug>
#include <QDateTime>
#include <QDir>

DatabaseManager& DatabaseManager::instance()
{
    static DatabaseManager instance;
    return instance;
}

DatabaseManager::DatabaseManager(QObject* parent)
    : QObject(parent)
{
    m_db = QSqlDatabase::addDatabase("QSQLITE");
}

DatabaseManager::~DatabaseManager()
{
    closeDatabase();
}

bool DatabaseManager::initDatabase(const QString& path)
{
    m_dbPath = path;
    m_db.setDatabaseName(path);
    if (!m_db.open()) {
        qCritical() << "Open database failed:" << m_db.lastError().text();
        return false;
    }
    enableWALMode();
    if (!createTables()) {
        qCritical() << "Create tables failed";
        return false;
    }
    createIndexes();
    return true;
}

void DatabaseManager::closeDatabase()
{
    if (m_db.isOpen()) {
        m_db.close();
    }
}

void DatabaseManager::enableWALMode()
{
    QSqlQuery query(m_db);
    query.exec("PRAGMA journal_mode=WAL");
    query.exec("PRAGMA synchronous=NORMAL");
    query.exec("PRAGMA cache_size=-65536"); // 64MB
}

bool DatabaseManager::createTables()
{
    QStringList createStmts;

    // 1. sys_user
    createStmts << R"(
        CREATE TABLE IF NOT EXISTS sys_user (
            user_id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_name TEXT UNIQUE NOT NULL,
            password TEXT NOT NULL,
            role_id INTEGER NOT NULL DEFAULT 0,
            status INTEGER NOT NULL DEFAULT 1,
            create_time TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
            last_login_time TEXT,
            update_time TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
        )
    )";

    // 2. sys_role
    createStmts << R"(
        CREATE TABLE IF NOT EXISTS sys_role (
            role_id INTEGER PRIMARY KEY AUTOINCREMENT,
            role_name TEXT NOT NULL,
            role_desc TEXT
        )
    )";

    // 3. sys_permission
    createStmts << R"(
        CREATE TABLE IF NOT EXISTS sys_permission (
            perm_id INTEGER PRIMARY KEY AUTOINCREMENT,
            role_id INTEGER NOT NULL DEFAULT 0,
            perm_code TEXT NOT NULL,
            perm_desc TEXT
        )
    )";

    // 4. led_device
    createStmts << R"(
        CREATE TABLE IF NOT EXISTS led_device (
            device_id TEXT PRIMARY KEY,
            device_name TEXT NOT NULL,
            device_type TEXT NOT NULL,
            ip_addr TEXT NOT NULL,
            port INTEGER NOT NULL DEFAULT 0,
            brightness INTEGER NOT NULL DEFAULT 50,
            online_status INTEGER NOT NULL DEFAULT 0,
            config_json TEXT,
            update_time TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
        )
    )";

    // 5. project_config
    createStmts << R"(
        CREATE TABLE IF NOT EXISTS project_config (
            project_id INTEGER PRIMARY KEY AUTOINCREMENT,
            project_name TEXT NOT NULL,
            window_layout TEXT,
            light_mapping TEXT,
            cron_strategy TEXT,
            create_time TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
            is_valid INTEGER NOT NULL DEFAULT 1
        )
    )";

    // 6. play_list
    createStmts << R"(
        CREATE TABLE IF NOT EXISTS play_list (
            list_id INTEGER PRIMARY KEY AUTOINCREMENT,
            project_id INTEGER NOT NULL DEFAULT 0,
            list_name TEXT NOT NULL,
            play_sort INTEGER NOT NULL DEFAULT 0,
            loop_type INTEGER NOT NULL DEFAULT 1,
            status INTEGER NOT NULL DEFAULT 1,
            create_time TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
            update_time TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
        )
    )";

    // 7. program_info
    createStmts << R"(
        CREATE TABLE IF NOT EXISTS program_info (
            program_id INTEGER PRIMARY KEY AUTOINCREMENT,
            list_id INTEGER NOT NULL DEFAULT 0,
            program_name TEXT NOT NULL,
            program_sort INTEGER NOT NULL DEFAULT 0,
            play_duration REAL NOT NULL DEFAULT 0.0,
            interval_time REAL NOT NULL DEFAULT 0.0,
            status INTEGER NOT NULL DEFAULT 1,
            create_time TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
            update_time TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
        )
    )";

    // 8. window_view
    createStmts << R"(
        CREATE TABLE IF NOT EXISTS window_view (
            window_id INTEGER PRIMARY KEY AUTOINCREMENT,
            program_id INTEGER NOT NULL DEFAULT 0,
            window_name TEXT NOT NULL,
            x_pos INTEGER NOT NULL DEFAULT 0,
            y_pos INTEGER NOT NULL DEFAULT 0,
            width INTEGER NOT NULL DEFAULT 1920,
            height INTEGER NOT NULL DEFAULT 1080,
            z_index INTEGER NOT NULL DEFAULT 0,
            status INTEGER NOT NULL DEFAULT 1,
            create_time TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
            update_time TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
        )
    )";

    // 9. media_source (包含 window_id 和 media_sort)
    createStmts << R"(
        CREATE TABLE IF NOT EXISTS media_source (
            media_id INTEGER PRIMARY KEY AUTOINCREMENT,
            file_path TEXT NOT NULL,
            file_type TEXT NOT NULL,
            duration REAL NOT NULL DEFAULT 0.0,
            quality_param TEXT,
            ai_edit_param TEXT,
            create_time TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
            window_id INTEGER NOT NULL DEFAULT 0,
            media_sort INTEGER NOT NULL DEFAULT 0
        )
    )";

    // 10. schedule_param
    createStmts << R"(
        CREATE TABLE IF NOT EXISTS schedule_param (
            schedule_id INTEGER PRIMARY KEY AUTOINCREMENT,
            scene_type TEXT NOT NULL,
            scene_threshold REAL NOT NULL DEFAULT 0.5,
            predict_cycle INTEGER NOT NULL DEFAULT 5,
            env_weight REAL NOT NULL DEFAULT 0.5,
            scene_weight REAL NOT NULL DEFAULT 0.5,
            brightness_min INTEGER NOT NULL DEFAULT 10,
            brightness_max INTEGER NOT NULL DEFAULT 100,
            strategy_json TEXT
        )
    )";

    // 11. ai_model_config
    createStmts << R"(
        CREATE TABLE IF NOT EXISTS ai_model_config (
            model_id INTEGER PRIMARY KEY AUTOINCREMENT,
            model_name TEXT NOT NULL,
            api_url TEXT NOT NULL,
            api_key TEXT NOT NULL,
            timeout INTEGER NOT NULL DEFAULT 10000,
            offline_strategy TEXT NOT NULL DEFAULT 'local',
            enable_status INTEGER NOT NULL DEFAULT 1
        )
    )";

    // 12. scene_statistics
    createStmts << R"(
        CREATE TABLE IF NOT EXISTS scene_statistics (
            stat_id INTEGER PRIMARY KEY AUTOINCREMENT,
            project_id INTEGER NOT NULL DEFAULT 0,
            scene_type TEXT NOT NULL,
            collect_time TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
            env_brightness INTEGER NOT NULL DEFAULT 0,
            scene_status TEXT,
            schedule_result TEXT,
            play_count INTEGER NOT NULL DEFAULT 0,
            total_duration REAL NOT NULL DEFAULT 0.0,
            stat_date TEXT,
            create_time TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
            update_time TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
        )
    )";

    // 13. sys_audit_log
    createStmts << R"(
        CREATE TABLE IF NOT EXISTS sys_audit_log (
            log_id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER NOT NULL DEFAULT 0,
            operation_type TEXT NOT NULL,
            operate_result TEXT NOT NULL,
            operate_time TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
            operation_desc TEXT,
            target_table TEXT,
            target_id INTEGER NOT NULL DEFAULT 0,
            client_ip TEXT,
            create_time TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
        )
    )";

    QSqlQuery query(m_db);
    for (const QString& sql : createStmts) {
        if (!query.exec(sql)) {
            qCritical() << "Create table failed:" << sql << query.lastError().text();
            return false;
        }
    }
    return true;
}

void DatabaseManager::createIndexes()
{
    QSqlQuery query(m_db);

    // 用户表索引
    query.exec("CREATE INDEX IF NOT EXISTS idx_user_name ON sys_user(user_name)");
    query.exec("CREATE INDEX IF NOT EXISTS idx_user_role ON sys_user(role_id)");

    // 权限表索引
    query.exec("CREATE INDEX IF NOT EXISTS idx_perm_role ON sys_permission(role_id)");

    // LED设备表索引
    query.exec("CREATE INDEX IF NOT EXISTS idx_device_ip_status ON led_device(ip_addr, online_status)");
    query.exec("CREATE INDEX IF NOT EXISTS idx_device_type ON led_device(device_type)");

    // 项目表索引
    query.exec("CREATE INDEX IF NOT EXISTS idx_project_isvalid ON project_config(project_name, is_valid)");
    query.exec("CREATE INDEX IF NOT EXISTS idx_project_valid ON project_config(is_valid)");

    // 播放列表索引
    query.exec("CREATE INDEX IF NOT EXISTS idx_playlist_project ON play_list(project_id)");
    query.exec("CREATE INDEX IF NOT EXISTS idx_playlist_status ON play_list(project_id, status)");

    // 节目表索引
    query.exec("CREATE INDEX IF NOT EXISTS idx_program_list ON program_info(list_id)");
    query.exec("CREATE INDEX IF NOT EXISTS idx_program_status ON program_info(list_id, status)");

    // 视窗表索引
    query.exec("CREATE INDEX IF NOT EXISTS idx_window_program ON window_view(program_id)");
    query.exec("CREATE INDEX IF NOT EXISTS idx_window_status ON window_view(program_id, status)");

    // 素材表索引
    query.exec("CREATE INDEX IF NOT EXISTS idx_media_window ON media_source(window_id)");
    query.exec("CREATE INDEX IF NOT EXISTS idx_media_type ON media_source(file_type)");
    query.exec("CREATE INDEX IF NOT EXISTS idx_media_window_type ON media_source(window_id, file_type)");

    // 调度参数索引
    query.exec("CREATE INDEX IF NOT EXISTS idx_schedule_scene ON schedule_param(scene_type)");

    // AI模型索引
    query.exec("CREATE INDEX IF NOT EXISTS idx_ai_enable ON ai_model_config(enable_status)");

    // 场景统计索引
    query.exec("CREATE INDEX IF NOT EXISTS idx_scene_project ON scene_statistics(project_id)");
    query.exec("CREATE INDEX IF NOT EXISTS idx_scene_time ON scene_statistics(collect_time)");
    query.exec("CREATE INDEX IF NOT EXISTS idx_scene_status ON scene_statistics(scene_status)");
    query.exec("CREATE INDEX IF NOT EXISTS idx_scene_type ON scene_statistics(scene_type)");
    query.exec("CREATE INDEX IF NOT EXISTS idx_scene_date ON scene_statistics(stat_date)");

    // 审计日志索引
    query.exec("CREATE INDEX IF NOT EXISTS idx_audit_user ON sys_audit_log(user_id)");
    query.exec("CREATE INDEX IF NOT EXISTS idx_audit_time ON sys_audit_log(operate_time)");
    query.exec("CREATE INDEX IF NOT EXISTS idx_audit_type ON sys_audit_log(operation_type)");
    query.exec("CREATE INDEX IF NOT EXISTS idx_audit_target ON sys_audit_log(target_table, target_id)");
}

bool DatabaseManager::beginTransaction()
{
    return m_db.transaction();
}

bool DatabaseManager::commitTransaction()
{
    return m_db.commit();
}

bool DatabaseManager::rollbackTransaction()
{
    return m_db.rollback();
}

bool DatabaseManager::backupTo(const QString& backupPath)
{
    // 先确保数据库没有活动事务
    if (m_db.isOpen()) {
        // 方法1: 使用 VACUUM INTO (SQLite 3.27.0+)
        QSqlQuery query(m_db);
        if (query.exec(QString("VACUUM INTO '%1'").arg(backupPath))) {
            return true;
        }
        // 方法2: 如果 VACUUM INTO 不支持，则回退到文件复制
        qWarning() << "VACUUM INTO failed, fallback to file copy:" << query.lastError().text();
    }
    // 文件复制方式
    QFile::remove(backupPath); // 删除可能存在的旧备份
    return QFile::copy(m_dbPath, backupPath);
}

bool DatabaseManager::restoreFrom(const QString& backupPath)
{
    if (!QFile::exists(backupPath)) {
        qCritical() << "Backup file not found:" << backupPath;
        return false;
    }

    // 关闭当前连接
    closeDatabase();

    // 删除当前数据库文件
    if (QFile::exists(m_dbPath)) {
        if (!QFile::remove(m_dbPath)) {
            qCritical() << "Failed to remove current database file:" << m_dbPath;
            return false;
        }
    }

    // 复制备份文件到当前路径
    if (!QFile::copy(backupPath, m_dbPath)) {
        qCritical() << "Failed to copy backup file to" << m_dbPath;
        return false;
    }

    // 重新打开数据库
    if (!m_db.open()) {
        qCritical() << "Failed to open restored database:" << m_db.lastError().text();
        return false;
    }

    // 重新启用WAL模式（可选）
    enableWALMode();
    return true;
}

bool DatabaseManager::checkIntegrity()
{
    QSqlQuery query(m_db);
    if (!query.exec("PRAGMA integrity_check")) {
        qCritical() << "Integrity check failed to execute:" << query.lastError().text();
        return false;
    }
    if (query.next()) {
        QString result = query.value(0).toString();
        if (result == "ok") {
            qDebug() << "Database integrity check passed.";
            return true;
        } else {
            qCritical() << "Database integrity check failed:" << result;
            return false;
        }
    }
    return false;
}