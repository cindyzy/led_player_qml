#ifndef SCENESTATISTICMODEL_H
#define SCENESTATISTICMODEL_H

#include <QAbstractListModel>
#include "../../../business/businesscontroller.h"
#include "../../../database/entities/scenestatistic.h"

class SceneStatisticModel : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)

public:
    explicit SceneStatisticModel(QObject* parent = nullptr);

    void setBusinessController(BusinessController* controller);
    Q_INVOKABLE bool loadStatistics(int projectId = 0);
    Q_INVOKABLE QVariant getStatisticData(int index) const;
    Q_INVOKABLE bool addStatistic(int projectId, const QString& sceneType, int playCount,
                                   double totalDuration, const QDateTime& statDate, const QString& operatorUser = "system");
    Q_INVOKABLE bool updateStatistic(int statId, int playCount, double totalDuration, const QString& operatorUser = "system");
    Q_INVOKABLE bool deleteStatistic(int statId, const QString& operatorUser = "system");
    Q_INVOKABLE QVariant findStatisticById(int statId) const;

    int rowCount(const QModelIndex& parent = QModelIndex()) const override;
    QVariant data(const QModelIndex& index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

signals:
    void countChanged();

private:
    BusinessController* m_businessController = nullptr;
    QList<LEDDB::SceneStatistic> m_statistics;

    enum StatisticRoles {
        StatIdRole = Qt::UserRole + 1,
        ProjectIdRole,
        SceneTypeRole,
        CollectTimeRole,
        EnvBrightnessRole,
        SceneStatusRole,
        ScheduleResultRole,
        PlayCountRole,
        TotalDurationRole,
        StatDateRole,
        CreateTimeRole,
        UpdateTimeRole
    };
};

#endif // SCENESTATISTICMODEL_H