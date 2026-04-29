#include "WindowViewModel.h"
#include <QDebug>

WindowViewModel::WindowViewModel(QObject* parent) : QAbstractListModel(parent)
{
}

void WindowViewModel::setBusinessController(BusinessController* controller)
{
    m_businessController = controller;
}

bool WindowViewModel::loadWindows(int programId)
{
    if (!m_businessController) {
        qDebug() << "WindowViewModel: BusinessController not set!";
        return false;
    }
    beginResetModel();
    m_windows.clear();
    endResetModel();
    emit countChanged();
    return true;
}

QVariant WindowViewModel::getWindowData(int index) const
{
    if (index < 0 || index >= m_windows.size()) return QVariant();
    const LEDDB::WindowView& win = m_windows[index];
    QVariantMap map;
    map["windowId"] = win.windowId();
    map["programId"] = win.programId();
    map["windowName"] = win.windowName();
    map["xPos"] = win.xPos();
    map["yPos"] = win.yPos();
    map["width"] = win.width();
    map["height"] = win.height();
    map["createTime"] = win.createTime().toString();
    map["updateTime"] = win.updateTime().toString();
    return map;
}

bool WindowViewModel::addWindow(int programId, const QString& windowName, int xPos, int yPos, int width, int height)
{
    if (!m_businessController) {
        qDebug() << "WindowViewModel: BusinessController not set!";
        return false;
    }
    qDebug() << "WindowViewModel: addWindow called -" << windowName;
    return true;
}

bool WindowViewModel::updateWindow(int windowId, const QString& windowName, int xPos, int yPos, int width, int height)
{
    if (!m_businessController) {
        qDebug() << "WindowViewModel: BusinessController not set!";
        return false;
    }
    qDebug() << "WindowViewModel: updateWindow called -" << windowId;
    return true;
}

bool WindowViewModel::deleteWindow(int windowId)
{
    if (!m_businessController) {
        qDebug() << "WindowViewModel: BusinessController not set!";
        return false;
    }
    qDebug() << "WindowViewModel: deleteWindow called -" << windowId;
    return true;
}

QVariant WindowViewModel::findWindowById(int windowId) const
{
    for (int i = 0; i < m_windows.size(); ++i) {
        if (m_windows[i].windowId() == windowId) {
            return getWindowData(i);
        }
    }
    return QVariant();
}

int WindowViewModel::rowCount(const QModelIndex& parent) const
{
    Q_UNUSED(parent);
    return m_windows.size();
}

QVariant WindowViewModel::data(const QModelIndex& index, int role) const
{
    if (!index.isValid() || index.row() >= m_windows.size()) return QVariant();
    const LEDDB::WindowView& win = m_windows[index.row()];
    switch (role) {
    case WindowIdRole: return win.windowId();
    case ProgramIdRole: return win.programId();
    case WindowNameRole: return win.windowName();
    case XPosRole: return win.xPos();
    case YPosRole: return win.yPos();
    case WidthRole: return win.width();
    case HeightRole: return win.height();
    case CreateTimeRole: return win.createTime();
    case UpdateTimeRole: return win.updateTime();
    default: return QVariant();
    }
}

QHash<int, QByteArray> WindowViewModel::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[WindowIdRole] = "windowId";
    roles[ProgramIdRole] = "programId";
    roles[WindowNameRole] = "windowName";
    roles[XPosRole] = "xPos";
    roles[YPosRole] = "yPos";
    roles[WidthRole] = "width";
    roles[HeightRole] = "height";
    roles[CreateTimeRole] = "createTime";
    roles[UpdateTimeRole] = "updateTime";
    return roles;
}