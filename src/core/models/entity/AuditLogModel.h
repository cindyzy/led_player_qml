#ifndef AUDITLOGMODEL_H
#define AUDITLOGMODEL_H

#include <QAbstractListModel>
#include "../../../business/businesscontroller.h"
#include "../../../database/entities/auditlog.h"

class AuditLogModel : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)
    Q_PROPERTY(int totalCount READ totalCount NOTIFY totalCountChanged)

public:
    explicit AuditLogModel(QObject* parent = nullptr);

    void setBusinessController(BusinessController* controller);
    Q_INVOKABLE bool loadLogs(int userId = 0, const QDateTime& startTime = QDateTime(),
                               const QDateTime& endTime = QDateTime(), const QString& operationType = QString());
    Q_INVOKABLE bool loadLogsByPage(int offset, int limit);
    Q_INVOKABLE QVariant getLogData(int index) const;
    Q_INVOKABLE bool addLog(int userId, const QString& operationType,const QString& operateResult, const QString& operationDesc,
                            const QString& targetTable, int targetId, const QString& clientIp);
    Q_INVOKABLE QVariant findLogById(int logId) const;
    Q_INVOKABLE void clearLogs();

    int rowCount(const QModelIndex& parent = QModelIndex()) const override;
    QVariant data(const QModelIndex& index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    int totalCount() const { return m_totalCount; }

signals:
    void countChanged();
    void totalCountChanged();

private:
    BusinessController* m_businessController = nullptr;
    QList<LEDDB::AuditLog> m_logs;
    int m_totalCount = 0;

    enum LogRoles {
        LogIdRole = Qt::UserRole + 1,
        UserIdRole,
        OperationTypeRole,
        OperateResultRole,
        OperateTimeRole,
        OperationDescRole,
        TargetTableRole,
        TargetIdRole,
        ClientIpRole,
        CreateTimeRole
    };
};

#endif // AUDITLOGMODEL_H