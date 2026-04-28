#ifndef SQLITEMEDIASOURCEREPOSITORY_H
#define SQLITEMEDIASOURCEREPOSITORY_H

// repositories/sqlite_mediasource_repository.h
#pragma once
#include "interfaces/IMediaSourceRepository.h"

namespace Repository {

class SqliteMediaSourceRepository : public IMediaSourceRepository {
public:
    bool insert(const LEDDB::MediaSource& media) override;
    bool update(const LEDDB::MediaSource& media) override;
    bool deleteById(int mediaId) override;
    bool deleteByWindowId(int windowId) override;
    std::optional<LEDDB::MediaSource> findById(int mediaId) override;
    QList<LEDDB::MediaSource> findByWindowId(int windowId) override;
    QList<LEDDB::MediaSource> findByWindowAndType(int windowId, const QString& fileType) override;
};

} // namespace Repository

#endif // SQLITEMEDIASOURCEREPOSITORY_H
