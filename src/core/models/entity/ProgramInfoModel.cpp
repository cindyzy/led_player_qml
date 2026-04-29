#include "ProgramInfoModel.h"
#include <QDebug>

ProgramInfoModel::ProgramInfoModel(QObject* parent) : QAbstractListModel(parent)
{
}

void ProgramInfoModel::setBusinessController(BusinessController* controller)
{
    m_businessController = controller;
}

bool ProgramInfoModel::loadPrograms(int listId)
{
    if (!m_businessController) {
        qDebug() << "ProgramInfoModel: BusinessController not set!";
        return false;
    }
    beginResetModel();
    m_programs.clear();
    endResetModel();
    emit countChanged();
    return true;
}

QVariant ProgramInfoModel::getProgramData(int index) const
{
    if (index < 0 || index >= m_programs.size()) return QVariant();
    const LEDDB::ProgramInfo& prog = m_programs[index];
    QVariantMap map;
    map["programId"] = prog.programId();
    map["listId"] = prog.listId();
    map["programName"] = prog.programName();
    map["startTime"] = prog.startTime();
    map["endTime"] = prog.endTime();
    map["createTime"] = prog.createTime().toString();
    map["updateTime"] = prog.updateTime().toString();
    return map;
}

bool ProgramInfoModel::addProgram(int listId, const QString& programName, double startTime, double endTime)
{
    if (!m_businessController) {
        qDebug() << "ProgramInfoModel: BusinessController not set!";
        return false;
    }
    qDebug() << "ProgramInfoModel: addProgram called -" << programName;
    return true;
}

bool ProgramInfoModel::updateProgram(int programId, const QString& programName, double startTime, double endTime)
{
    if (!m_businessController) {
        qDebug() << "ProgramInfoModel: BusinessController not set!";
        return false;
    }
    qDebug() << "ProgramInfoModel: updateProgram called -" << programId;
    return true;
}

bool ProgramInfoModel::deleteProgram(int programId)
{
    if (!m_businessController) {
        qDebug() << "ProgramInfoModel: BusinessController not set!";
        return false;
    }
    qDebug() << "ProgramInfoModel: deleteProgram called -" << programId;
    return true;
}

QVariant ProgramInfoModel::findProgramById(int programId) const
{
    for (int i = 0; i < m_programs.size(); ++i) {
        if (m_programs[i].programId() == programId) {
            return getProgramData(i);
        }
    }
    return QVariant();
}

int ProgramInfoModel::rowCount(const QModelIndex& parent) const
{
    Q_UNUSED(parent);
    return m_programs.size();
}

QVariant ProgramInfoModel::data(const QModelIndex& index, int role) const
{
    if (!index.isValid() || index.row() >= m_programs.size()) return QVariant();
    const LEDDB::ProgramInfo& prog = m_programs[index.row()];
    switch (role) {
    case ProgramIdRole: return prog.programId();
    case ListIdRole: return prog.listId();
    case ProgramNameRole: return prog.programName();
    case StartTimeRole: return prog.startTime();
    case EndTimeRole: return prog.endTime();
    case CreateTimeRole: return prog.createTime();
    case UpdateTimeRole: return prog.updateTime();
    default: return QVariant();
    }
}

QHash<int, QByteArray> ProgramInfoModel::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[ProgramIdRole] = "programId";
    roles[ListIdRole] = "listId";
    roles[ProgramNameRole] = "programName";
    roles[StartTimeRole] = "startTime";
    roles[EndTimeRole] = "endTime";
    roles[CreateTimeRole] = "createTime";
    roles[UpdateTimeRole] = "updateTime";
    return roles;
}