// repositories/RepositoryFactory.h
#pragma once
#include <memory>
#include "interfaces/IUserRepository.h"
#include "interfaces/IRoleRepository.h"
#include "interfaces/IPermissionRepository.h"
#include "interfaces/ILedDeviceRepository.h"
#include "interfaces/IProjectConfigRepository.h"
#include "interfaces/IPlayListRepository.h"
#include "interfaces/IProgramInfoRepository.h"
#include "interfaces/IWindowViewRepository.h"
#include "interfaces/IMediaSourceRepository.h"
#include "interfaces/IScheduleParamRepository.h"
#include "interfaces/IAiModelConfigRepository.h"
#include "interfaces/ISceneStatisticRepository.h"
#include "interfaces/IAuditLogRepository.h"

namespace Repository {

class RepositoryFactory {
public:
    static std::unique_ptr<IUserRepository> createUserRepository();
    static std::unique_ptr<IRoleRepository> createRoleRepository();
    static std::unique_ptr<IPermissionRepository> createPermissionRepository();
    static std::unique_ptr<ILedDeviceRepository> createLedDeviceRepository();
    static std::unique_ptr<IProjectConfigRepository> createProjectConfigRepository();
    static std::unique_ptr<IPlayListRepository> createPlayListRepository();
    static std::unique_ptr<IProgramInfoRepository> createProgramInfoRepository();
    static std::unique_ptr<IWindowViewRepository> createWindowViewRepository();
    static std::unique_ptr<IMediaSourceRepository> createMediaSourceRepository();
    static std::unique_ptr<IScheduleParamRepository> createScheduleParamRepository();
    static std::unique_ptr<IAiModelConfigRepository> createAiModelConfigRepository();
    static std::unique_ptr<ISceneStatisticRepository> createSceneStatisticRepository();
    static std::unique_ptr<IAuditLogRepository> createAuditLogRepository();
};

} // namespace Repository