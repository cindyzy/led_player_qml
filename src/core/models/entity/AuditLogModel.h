#ifndef AUDITLOGMODEL_H
#define AUDITLOGMODEL_H

#include <QAbstractListModel>
#include "../../../business/businesscontroller.h"
#include "../../../database/entities/auditlog.h"

class AuditLogModel : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)

public:
    explicit AuditLogModel(QObject* parent = nullptr);

    void setBusinessController(BusinessController* controller);
    Q_INVOKABLE bool loadLogs(int userId = 0, const QDateTime& startTime = QDateTime(),
                               const QDateTime& endTime = QDateTime());
    Q_INVOKABLE QVariant getLogData(int index) const;
    Q_INVOKABLE bool addLog(int userId, const QString& operationType,const QString& operateResult, const QString& operationDesc,
                            const QString& targetTable, int targetId, const QString& clientIp);
    Q_INVOKABLE QVariant findLogById(int logId) const;

    int rowCount(const QModelIndex& parent = QModelIndex()) const override;
    QVariant data(const QModelIndex& index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

signals:
    void countChanged();

private:
    BusinessController* m_businessController = nullptr;
    QList<LEDDB::AuditLog> m_logs;

    enum LogRoles {
        LogIdRole = Qt::UserRole + 1,
        UserIdRole,
        OperationTypeRole,
        OperationDescRole,
        TargetTableRole,
        TargetIdRole,
        ClientIpRole,
        CreateTimeRole
    };
};

#endif // AUDITLOGMODEL_H