// entities/projectconfig.cpp
#include "projectconfig.h"
#include "../../utils/datetimehelper.h"
#include <QSqlRecord>

namespace LEDDB {

ProjectConfig::ProjectConfig(int projectId, const QString& projectName, const QString& projectPath,
                             const QString& windowLayout, const QString& lightMapping,
                             const QString& cronStrategy, const QDateTime& createTime, int isValid)
    : m_projectId(projectId), m_projectName(projectName), m_projectPath(projectPath),
    m_windowLayout(windowLayout), m_lightMapping(lightMapping), m_cronStrategy(cronStrategy), 
    m_createTime(createTime), m_isValid(isValid) {}

ProjectConfig ProjectConfig::fromSqlRecord(const QSqlRecord& rec)
{
    ProjectConfig p;
    p.setProjectId(rec.value("project_id").toInt());
    p.setProjectName(rec.value("project_name").toString());
    p.setProjectPath(rec.value("project_path").toString());
    p.setWindowLayout(rec.value("window_layout").toString());
    p.setLightMapping(rec.value("light_mapping").toString());
    p.setCronStrategy(rec.value("cron_strategy").toString());
    p.setCreateTime(fromIsoString(rec.value("create_time").toString()));
    p.setIsValid(rec.value("is_valid").toInt());
    return p;
}

} // namespace LEDDB