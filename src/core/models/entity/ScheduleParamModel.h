#ifndef SCHEDULEPARAMMODEL_H
#define SCHEDULEPARAMMODEL_H

#include <QAbstractListModel>
#include "../../../business/businesscontroller.h"
#include "../../../database/entities/scheduleparam.h"

class ScheduleParamModel : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)

public:
    explicit ScheduleParamModel(QObject* parent = nullptr);

    void setBusinessController(BusinessController* controller);
    Q_INVOKABLE bool loadParams();
    Q_INVOKABLE QVariant getParamData(int index) const;
    Q_INVOKABLE bool addParam(const QString& sceneType, double sceneThreshold, int predictCycle,
                               double envWeight, double sceneWeight, int brightnessMin, int brightnessMax,
                               const QString& strategyJson);
    Q_INVOKABLE bool updateParam(int scheduleId, const QString& sceneType, double sceneThreshold,
                                  int predictCycle, double envWeight, double sceneWeight,
                                  int brightnessMin, int brightnessMax, const QString& strategyJson);
    Q_INVOKABLE bool deleteParam(int scheduleId);
    Q_INVOKABLE QVariant findParamById(int scheduleId) const;

    int rowCount(const QModelIndex& parent = QModelIndex()) const override;
    QVariant data(const QModelIndex& index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

signals:
    void countChanged();

private:
    BusinessController* m_businessController = nullptr;
    QList<LEDDB::ScheduleParam> m_params;

    enum ParamRoles {
        ScheduleIdRole = Qt::UserRole + 1,
        SceneTypeRole,
        SceneThresholdRole,
        PredictCycleRole,
        EnvWeightRole,
        SceneWeightRole,
        BrightnessMinRole,
        BrightnessMaxRole,
        StrategyJsonRole
    };
};

#endif // SCHEDULEPARAMMODEL_H