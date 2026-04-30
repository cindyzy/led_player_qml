#ifndef AIMODELCONFIGMODEL_H
#define AIMODELCONFIGMODEL_H

#include <QAbstractListModel>
#include "../../../business/businesscontroller.h"
#include "../../../database/entities/aimodelconfig.h"

class AiModelConfigModel : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)

public:
    explicit AiModelConfigModel(QObject* parent = nullptr);

    void setBusinessController(BusinessController* controller);
    Q_INVOKABLE bool loadConfigs();
    Q_INVOKABLE QVariant getConfigData(int index) const;
    Q_INVOKABLE bool addConfig(const QString& modelName, const QString& modelPath,
                                const QString& apiEndpoint, const QString& apiKey,
                                int timeout, const QString& modelParams, const QString& operatorUser = "system");
    Q_INVOKABLE bool updateConfig(int configId, const QString& modelName, const QString& modelPath,
                                   const QString& apiEndpoint, const QString& apiKey,
                                   int timeout, const QString& modelParams, int status, const QString& operatorUser = "system");
    Q_INVOKABLE bool deleteConfig(int configId, const QString& operatorUser = "system");
    Q_INVOKABLE QVariant findConfigById(int configId) const;

    int rowCount(const QModelIndex& parent = QModelIndex()) const override;
    QVariant data(const QModelIndex& index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

signals:
    void countChanged();

private:
    BusinessController* m_businessController = nullptr;
    QList<LEDDB::AiModelConfig> m_configs;

    enum ConfigRoles {
        ConfigIdRole = Qt::UserRole + 1,
        ModelNameRole,
        ModelPathRole,
        ApiEndpointRole,
        ApiKeyRole,
        TimeoutRole,
        ModelParamsRole,
        StatusRole,
        CreateTimeRole,
        UpdateTimeRole
    };
};

#endif // AIMODELCONFIGMODEL_H