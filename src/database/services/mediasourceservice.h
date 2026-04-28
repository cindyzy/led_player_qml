#ifndef MEDIASOURCESERVICE_H
#define MEDIASOURCESERVICE_H

// services/MediaSourceService.h
#pragma once
#include "../entities/mediasource.h"
#include <optional>
#include <QList>

class MediaSourceService {
public:
    MediaSourceService() = default;

    bool addMedia(const LEDDB::MediaSource& media, const QString& operatorUser);
    bool updateMedia(const LEDDB::MediaSource& media, const QString& operatorUser);
    bool removeMedia(int mediaId, const QString& operatorUser);
    std::optional<LEDDB::MediaSource> getMediaById(int mediaId);
    QList<LEDDB::MediaSource> getMediaByWindow(int windowId);
    bool reorderMedia(int windowId, const QList<int>& mediaIdsInOrder, const QString& operatorUser);
};

#endif // MEDIASOURCESERVICE_H