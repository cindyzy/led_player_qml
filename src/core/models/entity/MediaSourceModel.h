#ifndef MEDIASOURCEMODEL_H
#define MEDIASOURCEMODEL_H

#include <QAbstractListModel>
#include "../../../business/businesscontroller.h"
#include "../../../database/entities/mediasource.h"

class MediaSourceModel : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)

public:
    explicit MediaSourceModel(QObject* parent = nullptr);

    void setBusinessController(BusinessController* controller);
    Q_INVOKABLE bool loadMedias(int windowId = 0);
    Q_INVOKABLE QVariant getMediaData(int index) const;
    Q_INVOKABLE bool addMedia(int windowId, const QString& filePath, const QString& mediaName,
                               double duration, const QString& mediaType, const QString& thumbnailPath, const QString& operatorUser = "system");
    Q_INVOKABLE bool updateMedia(int mediaId, const QString& mediaName, double duration, int status, const QString& operatorUser = "system");
    Q_INVOKABLE bool deleteMedia(int mediaId, const QString& operatorUser = "system");
    Q_INVOKABLE QVariant findMediaById(int mediaId) const;

    int rowCount(const QModelIndex& parent = QModelIndex()) const override;
    QVariant data(const QModelIndex& index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

signals:
    void countChanged();

private:
    BusinessController* m_businessController = nullptr;
    QList<LEDDB::MediaSource> m_medias;

    enum MediaRoles {
        MediaIdRole = Qt::UserRole + 1,
        WindowIdRole,
        FilePathRole,
        MediaNameRole,
        DurationRole,
        MediaTypeRole,
        ThumbnailPathRole,
        StatusRole,
        CreateTimeRole,
        UpdateTimeRole
    };
};

#endif // MEDIASOURCEMODEL_H