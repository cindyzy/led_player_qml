#ifndef WINDOWVIEWMODEL_H
#define WINDOWVIEWMODEL_H

#include <QAbstractListModel>
#include "../../../business/businesscontroller.h"
#include "../../../database/entities/windowview.h"

class WindowViewModel : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)

public:
    explicit WindowViewModel(QObject* parent = nullptr);

    void setBusinessController(BusinessController* controller);
    Q_INVOKABLE bool loadWindows(int programId = 0);
    Q_INVOKABLE QVariant getWindowData(int index) const;
    Q_INVOKABLE bool addWindow(int programId, const QString& windowName, int xPos, int yPos, int width, int height,
                             int blendType, const QString& windowColor, int lockPosition, const QString& operatorUser = "system");
    Q_INVOKABLE bool updateWindow(int windowId, const QString& windowName, int xPos, int yPos, int width, int height,
                                int blendType, const QString& windowColor, int lockPosition, const QString& operatorUser = "system");
    Q_INVOKABLE bool deleteWindow(int windowId, const QString& operatorUser = "system");
    Q_INVOKABLE QVariant findWindowById(int windowId) const;

    int rowCount(const QModelIndex& parent = QModelIndex()) const override;
    QVariant data(const QModelIndex& index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

signals:
    void countChanged();

private:
    BusinessController* m_businessController = nullptr;
    QList<LEDDB::WindowView> m_windows;

    enum WindowRoles {
        WindowIdRole = Qt::UserRole + 1,
        ProgramIdRole,
        WindowNameRole,
        XPosRole,
        YPosRole,
        WidthRole,
        HeightRole,
        BlendTypeRole,
        WindowColorRole,
        LockPositionRole,
        PlayCountRole,
        CreateTimeRole,
        UpdateTimeRole
    };
};

#endif // WINDOWVIEWMODEL_H