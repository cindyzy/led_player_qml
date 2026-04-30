#ifndef PROJECTCONFIGMODEL_H
#define PROJECTCONFIGMODEL_H

#include <QAbstractListModel>
#include "../../../business/businesscontroller.h"
#include "../../../database/entities/projectconfig.h"

class ProjectConfigModel : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)

public:
    explicit ProjectConfigModel(QObject* parent = nullptr);

    void setBusinessController(BusinessController* controller);
    Q_INVOKABLE bool loadProjects();
    Q_INVOKABLE QVariant getProjectData(int index) const;
    Q_INVOKABLE bool addProject(const QString& projectName, const QString& projectPath,
                                 const QString& windowLayout, const QString& lightMapping,
                                 const QString& cronStrategy, const QString& operatorUser = "system");
    Q_INVOKABLE bool updateProject(int projectId, const QString& projectName,
                                   const QString& projectPath, const QString& windowLayout,
                                   const QString& lightMapping, const QString& cronStrategy,
                                   int isValid, const QString& operatorUser = "system");
    Q_INVOKABLE bool deleteProject(int projectId, const QString& operatorUser = "system");
    Q_INVOKABLE QVariant findProjectById(int projectId) const;

    int rowCount(const QModelIndex& parent = QModelIndex()) const override;
    QVariant data(const QModelIndex& index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

signals:
    void countChanged();

private:
    BusinessController* m_businessController = nullptr;
    QList<LEDDB::ProjectConfig> m_projects;

    enum ProjectRoles {
        ProjectIdRole = Qt::UserRole + 1,
        ProjectNameRole,
        ProjectPathRole,
        WindowLayoutRole,
        LightMappingRole,
        CronStrategyRole,
        CreateTimeRole,
        IsValidRole
    };
};

#endif // PROJECTCONFIGMODEL_H