#ifndef PROJECTCONFIGSERVICE_H
#define PROJECTCONFIGSERVICE_H

// services/ProjectConfigService.h
#pragma once
#include "../entities/projectconfig.h"
#include <optional>
#include <QList>

class ProjectConfigService {
public:
    ProjectConfigService();

    bool createProject(const LEDDB::ProjectConfig& project, const QString& operatorUser);
    bool updateProject(const LEDDB::ProjectConfig& project, const QString& operatorUser);
    bool deleteProject(int projectId, const QString& operatorUser);          // 普通删除（要求无关联数据）
    bool cascadeDeleteProject(int projectId, const QString& operatorUser);   // 级联删除所有关联内容
    std::optional<LEDDB::ProjectConfig> getProjectById(int projectId);
    QList<LEDDB::ProjectConfig> getValidProjects();
    QList<LEDDB::ProjectConfig> getAllProjects();
};

#endif // PROJECTCONFIGSERVICE_H
