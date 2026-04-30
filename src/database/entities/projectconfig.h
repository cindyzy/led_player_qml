#ifndef PROJECTCONFIG_H
#define PROJECTCONFIG_H
// entities/projectconfig.h
#pragma once
#include <QString>
#include <QDateTime>
#include <QSqlRecord>
namespace LEDDB {

class ProjectConfig {
public:
    ProjectConfig() = default;
    ProjectConfig(int projectId, const QString& projectName, const QString& projectPath,
                  const QString& windowLayout, const QString& lightMapping, 
                  const QString& cronStrategy, const QDateTime& createTime, int isValid);

    int projectId() const { return m_projectId; }
    void setProjectId(int id) { m_projectId = id; }

    QString projectName() const { return m_projectName; }
    void setProjectName(const QString& name) { m_projectName = name; }

    QString projectPath() const { return m_projectPath; }
    void setProjectPath(const QString& path) { m_projectPath = path; }

    QString windowLayout() const { return m_windowLayout; }
    void setWindowLayout(const QString& layout) { m_windowLayout = layout; }

    QString lightMapping() const { return m_lightMapping; }
    void setLightMapping(const QString& mapping) { m_lightMapping = mapping; }

    QString cronStrategy() const { return m_cronStrategy; }
    void setCronStrategy(const QString& strategy) { m_cronStrategy = strategy; }

    QDateTime createTime() const { return m_createTime; }
    void setCreateTime(const QDateTime& dt) { m_createTime = dt; }

    int isValid() const { return m_isValid; }
    void setIsValid(int valid) { m_isValid = valid; }   // 0失效 1启用

    static ProjectConfig fromSqlRecord(const QSqlRecord& record);

private:
    int m_projectId = 0;
    QString m_projectName;
    QString m_projectPath;       // 项目文件路径
    QString m_windowLayout;      // JSON
    QString m_lightMapping;      // JSON
    QString m_cronStrategy;
    QDateTime m_createTime;
    int m_isValid = 1;
};

} // namespace LEDDB

#endif // PROJECTCONFIG_H