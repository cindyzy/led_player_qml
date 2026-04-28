#ifndef PLAYLISTSERVICE_H
#define PLAYLISTSERVICE_H

// services/PlayListService.h
#pragma once
#include "../entities/playlist.h"
#include <optional>
#include <QList>
#include "../databasemanager.h"
class PlayListService {
public:
    PlayListService();

    bool createPlayList(const LEDDB::PlayList& playlist, const QString& operatorUser);
    bool updatePlayList(const LEDDB::PlayList& playlist, const QString& operatorUser);
    bool deletePlayList(int listId, const QString& operatorUser);
    std::optional<LEDDB::PlayList> getPlayListById(int listId);
    QList<LEDDB::PlayList> getAllPlayLists();
    QList<LEDDB::PlayList> getPlayListsByProject(int projectId);
    QList<LEDDB::PlayList> getPlayListsByProjectId(int projectId);
    bool reorderPlayLists(int projectId, const QList<int>& listIdsInOrder, const QString& operatorUser);
};
#endif // PLAYLISTSERVICE_H
