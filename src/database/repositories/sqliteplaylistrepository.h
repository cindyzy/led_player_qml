#ifndef SQLITEPLAYLISTREPOSITORY_H
#define SQLITEPLAYLISTREPOSITORY_H

// repositories/sqlite_playlist_repository.h
#pragma once
#include "interfaces/IPlayListRepository.h"

namespace Repository {

class SqlitePlayListRepository : public IPlayListRepository {
public:
    bool insert(const LEDDB::PlayList& playlist) override;
    bool update(const LEDDB::PlayList& playlist) override;
    bool deleteById(int listId) override;
    bool deleteByProjectId(int projectId) override;
    std::optional<LEDDB::PlayList> findById(int listId) override;
    QList<LEDDB::PlayList> findByProjectId(int projectId) override;
    QList<LEDDB::PlayList> findByProjectAndStatus(int projectId, int status) override;
};

} // namespace Repository

#endif // SQLITEPLAYLISTREPOSITORY_H
