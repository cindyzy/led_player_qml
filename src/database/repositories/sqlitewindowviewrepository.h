#ifndef SQLITEWINDOWVIEWREPOSITORY_H
#define SQLITEWINDOWVIEWREPOSITORY_H

// repositories/sqlite_windowview_repository.h
#pragma once
#include "interfaces/IWindowViewRepository.h"

namespace Repository {

class SqliteWindowViewRepository : public IWindowViewRepository {
public:
    bool insert(const LEDDB::WindowView& view) override;
    bool update(const LEDDB::WindowView& view) override;
    bool deleteById(int windowId) override;
    bool deleteByProgramId(int programId) override;
    std::optional<LEDDB::WindowView> findById(int windowId) override;
    QList<LEDDB::WindowView> findByProgramId(int programId) override;
    QList<LEDDB::WindowView> findByProgramAndStatus(int programId, int status) override;
    QList<LEDDB::WindowView> getWindowsByProgramId(int programId) override;

};

} // namespace Repository

#endif // SQLITEWINDOWVIEWREPOSITORY_H
