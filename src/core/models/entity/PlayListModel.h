#ifndef PLAYLISTMODEL_H
#define PLAYLISTMODEL_H

#include <QAbstractListModel>
#include "../../../business/businesscontroller.h"
#include "../../../database/entities/playlist.h"

class PlayListModel : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)

public:
    explicit PlayListModel(QObject* parent = nullptr);

    void setBusinessController(BusinessController* controller);
    Q_INVOKABLE bool loadPlayLists(int projectId = 0);
    Q_INVOKABLE QVariant getPlayListData(int index) const;
    Q_INVOKABLE bool addPlayList(int projectId, const QString& listName, int playSort, int loopType);
    Q_INVOKABLE bool updatePlayList(int listId, const QString& listName, int playSort, int loopType, int status);
    Q_INVOKABLE bool deletePlayList(int listId);
    Q_INVOKABLE QVariant findPlayListById(int listId) const;

    int rowCount(const QModelIndex& parent = QModelIndex()) const override;
    QVariant data(const QModelIndex& index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

signals:
    void countChanged();

private:
    BusinessController* m_businessController = nullptr;
    QList<LEDDB::PlayList> m_playLists;

    enum PlayListRoles {
        ListIdRole = Qt::UserRole + 1,
        ProjectIdRole,
        ListNameRole,
        PlaySortRole,
        LoopTypeRole,
        StatusRole,
        CreateTimeRole,
        UpdateTimeRole,
        // 新增字段
        ProgramCountRole,
        TotalFramesRole,
        TotalDurationRole
    };
};

#endif // PLAYLISTMODEL_H