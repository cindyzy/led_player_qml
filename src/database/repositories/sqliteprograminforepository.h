#ifndef SQLITEPROGRAMINFOREPOSITORY_H
#define SQLITEPROGRAMINFOREPOSITORY_H

// repositories/sqlite_programinfo_repository.h
#pragma once
#include "interfaces/IProgramInfoRepository.h"

namespace Repository {

class SqliteProgramInfoRepository : public IProgramInfoRepository {
public:
    bool insert(const LEDDB::ProgramInfo& program) override;
    bool update(const LEDDB::ProgramInfo& program) override;
    bool deleteById(int programId) override;
    bool deleteByListId(int listId) override;
    std::optional<LEDDB::ProgramInfo> findById(int programId) override;
    QList<LEDDB::ProgramInfo> findByListId(int listId) override;
    QList<LEDDB::ProgramInfo> findByListIdAndStatus(int listId, int status) override;
};

} // namespace Repository

#endif // SQLITEPROGRAMINFOREPOSITORY_H
