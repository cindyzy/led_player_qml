#include "projectconfigservice.h"

// services/ProjectConfigService.cpp
// #include "ProjectConfigService.h"
#include "../repositories/RepositoryFactory.h"
#include "../../utils/datetimehelper.h"
#include "AuditLogService.h"
#include <QDateTime>

using namespace Repository;
using namespace LEDDB;

ProjectConfigService::ProjectConfigService() = default;

bool ProjectConfigService::createProject(const ProjectConfig& project, const QString& operatorUser) {
    auto projRepo = RepositoryFactory::createProjectConfigRepository();
    ProjectConfig newProj = project;
    newProj.setCreateTime(QDateTime::currentDateTime());
    bool success = projRepo->insert(newProj);
    int userId = 0;
    auto userRepo = RepositoryFactory::createUserRepository();
    auto userOpt = userRepo->findByUserName(operatorUser);
    if (userOpt.has_value()) {
        userId = userOpt.value().userId();
    }
    AuditLogService().logOperation(userId, "创建项目", success ? "成功" : "失败",
                                   QString("创建项目 %1").arg(project.projectName()),
                                   "project_config", newProj.projectId());
    return success;
}

bool ProjectConfigService::updateProject(const ProjectConfig& project, const QString& operatorUser) {
    auto projRepo = RepositoryFactory::createProjectConfigRepository();
    bool success = projRepo->update(project);
    int userId = 0;
    auto userRepo = RepositoryFactory::createUserRepository();
    auto userOpt = userRepo->findByUserName(operatorUser);
    if (userOpt.has_value()) {
        userId = userOpt.value().userId();
    }
    AuditLogService().logOperation(userId, "更新项目", success ? "成功" : "失败",
                                   QString("更新项目 %1").arg(project.projectName()),
                                   "project_config", project.projectId());
    return success;
}

bool ProjectConfigService::deleteProject(int projectId, const QString& operatorUser) {
    auto projRepo = RepositoryFactory::createProjectConfigRepository();
    auto project = projRepo->findById(projectId);
    if (!project) return false;

    int userId = 0;
    auto userRepo = RepositoryFactory::createUserRepository();
    auto userOpt = userRepo->findByUserName(operatorUser);
    if (userOpt.has_value()) {
        userId = userOpt.value().userId();
    }

    // 检查是否存在关联的播放列表（若有，不能简单删除）
    auto plRepo = RepositoryFactory::createPlayListRepository();
    auto playLists = plRepo->findByProjectId(projectId);
    if (!playLists.isEmpty()) {
        AuditLogService().logOperation(userId, "删除项目", "失败",
                                       QString("项目 %1 仍有播放列表，无法删除").arg(project->projectName()),
                                       "project_config", projectId);
        return false;
    }

    bool success = projRepo->deleteById(projectId);
    AuditLogService().logOperation(userId, "删除项目", success ? "成功" : "失败",
                                   QString("删除项目 %1").arg(project->projectName()),
                                   "project_config", projectId);
    return success;
}

bool ProjectConfigService::cascadeDeleteProject(int projectId, const QString& operatorUser) {
    auto projRepo = RepositoryFactory::createProjectConfigRepository();
    auto project = projRepo->findById(projectId);
    if (!project) return false;

    int userId = 0;
    auto userRepo = RepositoryFactory::createUserRepository();
    auto userOpt = userRepo->findByUserName(operatorUser);
    if (userOpt.has_value()) {
        userId = userOpt.value().userId();
    }

    bool success = projRepo->cascadeDeleteById(projectId);
    AuditLogService().logOperation(userId, "级联删除项目", success ? "成功" : "失败",
                                   QString("级联删除项目 %1 及所有关联内容").arg(project->projectName()),
                                   "project_config", projectId);
    return success;
}

std::optional<ProjectConfig> ProjectConfigService::getProjectById(int projectId) {
    auto projRepo = RepositoryFactory::createProjectConfigRepository();
    return projRepo->findById(projectId);
}

QList<ProjectConfig> ProjectConfigService::getValidProjects() {
    auto projRepo = RepositoryFactory::createProjectConfigRepository();
    return projRepo->findByValid(1);
}

QList<ProjectConfig> ProjectConfigService::getAllProjects() {
    auto projRepo = RepositoryFactory::createProjectConfigRepository();
    return projRepo->findAll();
}