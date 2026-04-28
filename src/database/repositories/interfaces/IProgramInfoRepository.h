#ifndef IPROGRAMINFOREPOSITORY_H
#define IPROGRAMINFOREPOSITORY_H

// repositories/interfaces/IProgramInfoRepository.h
#pragma once
#include "../../entities/programinfo.h"
#include <optional>
#include <QList>

namespace Repository {

class IProgramInfoRepository {
public:
    virtual ~IProgramInfoRepository() = default;

    virtual bool insert(const LEDDB::ProgramInfo& program) = 0;
    virtual bool update(const LEDDB::ProgramInfo& program) = 0;
    virtual bool deleteById(int programId) = 0;
    virtual bool deleteByListId(int listId) = 0;
    virtual std::optional<LEDDB::ProgramInfo> findById(int programId) = 0;
    virtual QList<LEDDB::ProgramInfo> findByListId(int listId) = 0;
    virtual QList<LEDDB::ProgramInfo> findByListIdAndStatus(int listId, int status) = 0;
};

} // namespace Repository
#endif // IPROGRAMINFOREPOSITORY_H
