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
    QList<LEDDB::WindowView> windows;
    if (programId > 0) {
        windows = m_businessController->getWindowsByProgram(programId);
    }
    beginResetModel();
    m_windows = windows;
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
    map["blendType"] = win.blendType();
    map["windowColor"] = win.windowColor();
    map["lockPosition"] = win.lockPosition();
    map["playCount"] = win.playCount();
    map["createTime"] = win.createTime().toString();
    map["updateTime"] = win.updateTime().toString();
    return map;
}

bool WindowViewModel::addWindow(int programId, const QString& windowName, int xPos, int yPos, int width, int height,
                             int blendType, const QString& windowColor, int lockPosition, const QString& operatorUser)
{
    if (!m_businessController) {
        qDebug() << "WindowViewModel: BusinessController not set!";
        return false;
    }
    bool success = m_businessController->createWindow(programId, windowName, xPos, yPos, width, height, blendType, windowColor, lockPosition, operatorUser);
    if (success) {
        loadWindows(programId);
    }
    return success;
}

bool WindowViewModel::updateWindow(int windowId, const QString& windowName, int xPos, int yPos, int width, int height,
                                int blendType, const QString& windowColor, int lockPosition, const QString& operatorUser)
{
    if (!m_businessController) {
        qDebug() << "WindowViewModel: BusinessController not set!";
        return false;
    }
    bool success = m_businessController->updateWindow(windowId, windowName, xPos, yPos, width, height, blendType, windowColor, lockPosition, operatorUser);
    if (success) {
        loadWindows(0);
    }
    return success;
}

bool WindowViewModel::deleteWindow(int windowId, const QString& operatorUser)
{
    if (!m_businessController) {
        qDebug() << "WindowViewModel: BusinessController not set!";
        return false;
    }
    bool success = m_businessController->deleteWindow(windowId, operatorUser);
    if (success) {
        loadWindows(0);
    }
    return success;
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
    case BlendTypeRole: return win.blendType();
    case WindowColorRole: return win.windowColor();
    case LockPositionRole: return win.lockPosition();
    case PlayCountRole: return win.playCount();
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
    roles[BlendTypeRole] = "blendType";
    roles[WindowColorRole] = "windowColor";
    roles[LockPositionRole] = "lockPosition";
    roles[PlayCountRole] = "playCount";
    roles[CreateTimeRole] = "createTime";
    roles[UpdateTimeRole] = "updateTime";
    return roles;
}