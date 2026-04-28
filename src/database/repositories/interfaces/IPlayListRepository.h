#ifndef IPLAYLISTREPOSITORY_H
#define IPLAYLISTREPOSITORY_H

// repositories/interfaces/IPlayListRepository.h
#pragma once
#include "../../entities/playlist.h"
#include <optional>
#include <QList>

namespace Repository {

class IPlayListRepository {
public:
    virtual ~IPlayListRepository() = default;

    virtual bool insert(const LEDDB::PlayList& playlist) = 0;
    virtual bool update(const LEDDB::PlayList& playlist) = 0;
    virtual bool deleteById(int listId) = 0;
    virtual bool deleteByProjectId(int projectId) = 0;
    virtual std::optional<LEDDB::PlayList> findById(int listId) = 0;
    virtual QList<LEDDB::PlayList> findByProjectId(int projectId) = 0;
    virtual QList<LEDDB::PlayList> findByProjectAndStatus(int projectId, int status) = 0;
};

} // namespace Repository

#endif // IPLAYLISTREPOSITORY_H
