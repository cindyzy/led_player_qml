#ifndef PROGRAMINFOMODEL_H
#define PROGRAMINFOMODEL_H

#include <QAbstractListModel>
#include "../../../business/businesscontroller.h"
#include "../../../database/entities/programinfo.h"

class ProgramInfoModel : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)

public:
    explicit ProgramInfoModel(QObject* parent = nullptr);

    void setBusinessController(BusinessController* controller);
    Q_INVOKABLE bool loadPrograms(int listId = 0);
    Q_INVOKABLE QVariant getProgramData(int index) const;
    Q_INVOKABLE bool addProgram(int listId, const QString& programName, double startTime, double endTime, const QString& operatorUser = "system");
    Q_INVOKABLE bool updateProgram(int programId, const QString& programName, double startTime, double endTime, const QString& operatorUser = "system");
    Q_INVOKABLE bool deleteProgram(int programId, const QString& operatorUser = "system");
    Q_INVOKABLE QVariant findProgramById(int programId) const;

    int rowCount(const QModelIndex& parent = QModelIndex()) const override;
    QVariant data(const QModelIndex& index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

signals:
    void countChanged();

private:
    BusinessController* m_businessController = nullptr;
    QList<LEDDB::ProgramInfo> m_programs;

    enum ProgramRoles {
        ProgramIdRole = Qt::UserRole + 1,
        ListIdRole,
        ProgramNameRole,
        StartTimeRole,
        EndTimeRole,
        CreateTimeRole,
        UpdateTimeRole
    };
};

#endif // PROGRAMINFOMODEL_H