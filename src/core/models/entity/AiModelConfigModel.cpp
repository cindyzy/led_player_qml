#include "AiModelConfigModel.h"
#include <QDebug>

AiModelConfigModel::AiModelConfigModel(QObject* parent) : QAbstractListModel(parent)
{
}

void AiModelConfigModel::setBusinessController(BusinessController* controller)
{
    m_businessController = controller;
}

bool AiModelConfigModel::loadConfigs()
{
    if (!m_businessController) {
        qDebug() << "AiModelConfigModel: BusinessController not set!";
        return false;
    }
    beginResetModel();
    m_configs.clear();
    endResetModel();
    emit countChanged();
    return true;
}

QVariant AiModelConfigModel::getConfigData(int index) const
{
    if (index < 0 || index >= m_configs.size()) return QVariant();
    const LEDDB::AiModelConfig& config = m_configs[index];
    QVariantMap map;
    map["configId"] = config.configId();
    map["modelName"] = config.modelName();
    map["modelPath"] = config.modelPath();
    map["apiEndpoint"] = config.apiEndpoint();
    map["apiKey"] = config.apiKey();
    map["timeout"] = config.timeout();
    map["modelParams"] = config.modelParams();
    map["enableStatus"] = config.enableStatus();
    map["createTime"] = config.createTime().toString();
    map["updateTime"] = config.updateTime().toString();
    return map;
}

bool AiModelConfigModel::addConfig(const QString& modelName, const QString& modelPath,
                                    const QString& apiEndpoint, const QString& apiKey,
                                    int timeout, const QString& modelParams)
{
    if (!m_businessController) {
        qDebug() << "AiModelConfigModel: BusinessController not set!";
        return false;
    }
    qDebug() << "AiModelConfigModel: addConfig called -" << modelName;
    return true;
}

bool AiModelConfigModel::updateConfig(int configId, const QString& modelName, const QString& modelPath,
                                       const QString& apiEndpoint, const QString& apiKey,
                                       int timeout, const QString& modelParams, int status)
{
    if (!m_businessController) {
        qDebug() << "AiModelConfigModel: BusinessController not set!";
        return false;
    }
    qDebug() << "AiModelConfigModel: updateConfig called -" << configId;
    return true;
}

bool AiModelConfigModel::deleteConfig(int configId)
{
    if (!m_businessController) {
        qDebug() << "AiModelConfigModel: BusinessController not set!";
        return false;
    }
    qDebug() << "AiModelConfigModel: deleteConfig called -" << configId;
    return true;
}

QVariant AiModelConfigModel::findConfigById(int configId) const
{
    for (int i = 0; i < m_configs.size(); ++i) {
        if (m_configs[i].configId() == configId) {
            return getConfigData(i);
        }
    }
    return QVariant();
}

int AiModelConfigModel::rowCount(const QModelIndex& parent) const
{
    Q_UNUSED(parent);
    return m_configs.size();
}

QVariant AiModelConfigModel::data(const QModelIndex& index, int role) const
{
    if (!index.isValid() || index.row() >= m_configs.size()) return QVariant();
    const LEDDB::AiModelConfig& config = m_configs[index.row()];
    switch (role) {
    case ConfigIdRole: return config.configId();
    case ModelNameRole: return config.modelName();
    case ModelPathRole: return config.modelPath();
    case ApiEndpointRole: return config.apiEndpoint();
    case ApiKeyRole: return config.apiKey();
    case TimeoutRole: return config.timeout();
    case ModelParamsRole: return config.modelParams();
    case StatusRole: return config.enableStatus();
    case CreateTimeRole: return config.createTime();
    case UpdateTimeRole: return config.updateTime();
    default: return QVariant();
    }
}

QHash<int, QByteArray> AiModelConfigModel::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[ConfigIdRole] = "configId";
    roles[ModelNameRole] = "modelName";
    roles[ModelPathRole] = "modelPath";
    roles[ApiEndpointRole] = "apiEndpoint";
    roles[ApiKeyRole] = "apiKey";
    roles[TimeoutRole] = "timeout";
    roles[ModelParamsRole] = "modelParams";
    roles[StatusRole] = "status";
    roles[CreateTimeRole] = "createTime";
    roles[UpdateTimeRole] = "updateTime";
    return roles;
}