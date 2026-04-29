#include "ProjectConfigModel.h"
#include <QDebug>

ProjectConfigModel::ProjectConfigModel(QObject* parent) : QAbstractListModel(parent)
{
}

void ProjectConfigModel::setBusinessController(BusinessController* controller)
{
    m_businessController = controller;
}

bool ProjectConfigModel::loadProjects()
{
    if (!m_businessController) {
        qDebug() << "ProjectConfigModel: BusinessController not set!";
        return false;
    }
    beginResetModel();
    m_projects.clear();
    endResetModel();
    emit countChanged();
    return true;
}

QVariant ProjectConfigModel::getProjectData(int index) const
{
    if (index < 0 || index >= m_projects.size()) return QVariant();
    const LEDDB::ProjectConfig& proj = m_projects[index];
    QVariantMap map;
    map["projectId"] = proj.projectId();
    map["projectName"] = proj.projectName();
    map["windowLayout"] = proj.windowLayout();
    map["lightMapping"] = proj.lightMapping();
    map["cronStrategy"] = proj.cronStrategy();
    map["createTime"] = proj.createTime().toString();
    map["isValid"] = proj.isValid();
    return map;
}

bool ProjectConfigModel::addProject(const QString& projectName, const QString& windowLayout,
                                     const QString& lightMapping, const QString& cronStrategy)
{
    if (!m_businessController) {
        qDebug() << "ProjectConfigModel: BusinessController not set!";
        return false;
    }
    qDebug() << "ProjectConfigModel: addProject called -" << projectName;
    return true;
}

bool ProjectConfigModel::updateProject(int projectId, const QString& projectName,
                                       const QString& windowLayout, const QString& lightMapping,
                                       const QString& cronStrategy, int isValid)
{
    if (!m_businessController) {
        qDebug() << "ProjectConfigModel: BusinessController not set!";
        return false;
    }
    qDebug() << "ProjectConfigModel: updateProject called -" << projectId;
    return true;
}

bool ProjectConfigModel::deleteProject(int projectId)
{
    if (!m_businessController) {
        qDebug() << "ProjectConfigModel: BusinessController not set!";
        return false;
    }
    qDebug() << "ProjectConfigModel: deleteProject called -" << projectId;
    return true;
}

QVariant ProjectConfigModel::findProjectById(int projectId) const
{
    for (int i = 0; i < m_projects.size(); ++i) {
        if (m_projects[i].projectId() == projectId) {
            return getProjectData(i);
        }
    }
    return QVariant();
}

int ProjectConfigModel::rowCount(const QModelIndex& parent) const
{
    Q_UNUSED(parent);
    return m_projects.size();
}

QVariant ProjectConfigModel::data(const QModelIndex& index, int role) const
{
    if (!index.isValid() || index.row() >= m_projects.size()) return QVariant();
    const LEDDB::ProjectConfig& proj = m_projects[index.row()];
    switch (role) {
    case ProjectIdRole: return proj.projectId();
    case ProjectNameRole: return proj.projectName();
    case WindowLayoutRole: return proj.windowLayout();
    case LightMappingRole: return proj.lightMapping();
    case CronStrategyRole: return proj.cronStrategy();
    case CreateTimeRole: return proj.createTime();
    case IsValidRole: return proj.isValid();
    default: return QVariant();
    }
}

QHash<int, QByteArray> ProjectConfigModel::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[ProjectIdRole] = "projectId";
    roles[ProjectNameRole] = "projectName";
    roles[WindowLayoutRole] = "windowLayout";
    roles[LightMappingRole] = "lightMapping";
    roles[CronStrategyRole] = "cronStrategy";
    roles[CreateTimeRole] = "createTime";
    roles[IsValidRole] = "isValid";
    return roles;
}