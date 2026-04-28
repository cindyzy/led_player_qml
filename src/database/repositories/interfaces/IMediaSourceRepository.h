#ifndef IMEDIASOURCEREPOSITORY_H
#define IMEDIASOURCEREPOSITORY_H

// repositories/interfaces/IMediaSourceRepository.h
#pragma once
#include "../../entities/mediasource.h"
#include <optional>
#include <QList>

namespace Repository {

class IMediaSourceRepository {
public:
    virtual ~IMediaSourceRepository() = default;

    virtual bool insert(const LEDDB::MediaSource& media) = 0;
    virtual bool update(const LEDDB::MediaSource& media) = 0;
    virtual bool deleteById(int mediaId) = 0;
    virtual bool deleteByWindowId(int windowId) = 0;
    virtual std::optional<LEDDB::MediaSource> findById(int mediaId) = 0;
    virtual QList<LEDDB::MediaSource> findByWindowId(int windowId) = 0;
    virtual QList<LEDDB::MediaSource> findByWindowAndType(int windowId, const QString& fileType) = 0;
};

} // namespace Repository

#endif // IMEDIASOURCEREPOSITORY_H
