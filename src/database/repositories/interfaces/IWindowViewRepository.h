#ifndef IWINDOWVIEWREPOSITORY_H
#define IWINDOWVIEWREPOSITORY_H

// repositories/interfaces/IWindowViewRepository.h
#pragma once
#include "../../entities/windowview.h"
#include <optional>
#include <QList>

namespace Repository {

class IWindowViewRepository {
public:
    virtual ~IWindowViewRepository() = default;

    virtual bool insert(const LEDDB::WindowView& view) = 0;
    virtual bool update(const LEDDB::WindowView& view) = 0;
    virtual bool deleteById(int windowId) = 0;
    virtual bool deleteByProgramId(int programId) = 0;
    virtual std::optional<LEDDB::WindowView> findById(int windowId) = 0;
    virtual QList<LEDDB::WindowView> findByProgramId(int programId) = 0;
    virtual QList<LEDDB::WindowView> findByProgramAndStatus(int programId, int status) = 0;
    virtual QList<LEDDB::WindowView> getWindowsByProgramId(int programId) = 0;


};

} // namespace Repository
#endif // IWINDOWVIEWREPOSITORY_H
