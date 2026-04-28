// repositories/RepositoryFactory.cpp
#include "repositoryfactory.h"
#include "sqliteuserrepository.h"
#include "sqliterolerepository.h"
#include "sqlitepermissionrepository.h"
#include "sqliteleddevicerepository.h"
#include "sqliteprojectconfigrepository.h"
#include "sqliteplaylistrepository.h"
#include "sqliteprograminforepository.h"
#include "sqlitewindowviewrepository.h"
#include "sqlitemediasourcerepository.h"
#include "sqlitescheduleparamrepository.h"
#include "sqliteaimodelconfigrepository.h"
#include "sqlitescenestatisticrepository.h"
#include "sqliteauditlogrepository.h"

namespace Repository {

std::unique_ptr<IUserRepository> RepositoryFactory::createUserRepository() {
    return std::make_unique<SqliteUserRepository>();
}
std::unique_ptr<IRoleRepository> RepositoryFactory::createRoleRepository() {
    return std::make_unique<SqliteRoleRepository>();
}
std::unique_ptr<IPermissionRepository> RepositoryFactory::createPermissionRepository() {
    return std::make_unique<SqlitePermissionRepository>();
}
std::unique_ptr<ILedDeviceRepository> RepositoryFactory::createLedDeviceRepository() {
    return std::make_unique<SqliteLedDeviceRepository>();
}
std::unique_ptr<IProjectConfigRepository> RepositoryFactory::createProjectConfigRepository() {
    return std::make_unique<SqliteProjectConfigRepository>();
}
std::unique_ptr<IPlayListRepository> RepositoryFactory::createPlayListRepository() {
    return std::make_unique<SqlitePlayListRepository>();
}
std::unique_ptr<IProgramInfoRepository> RepositoryFactory::createProgramInfoRepository() {
    return std::make_unique<SqliteProgramInfoRepository>();
}
std::unique_ptr<IWindowViewRepository> RepositoryFactory::createWindowViewRepository() {
    return std::make_unique<SqliteWindowViewRepository>();
}
std::unique_ptr<IMediaSourceRepository> RepositoryFactory::createMediaSourceRepository() {
    return std::make_unique<SqliteMediaSourceRepository>();
}
std::unique_ptr<IScheduleParamRepository> RepositoryFactory::createScheduleParamRepository() {
    return std::make_unique<SqliteScheduleParamRepository>();
}
std::unique_ptr<IAiModelConfigRepository> RepositoryFactory::createAiModelConfigRepository() {
    return std::make_unique<SqliteAiModelConfigRepository>();
}
std::unique_ptr<ISceneStatisticRepository> RepositoryFactory::createSceneStatisticRepository() {
    return std::make_unique<SqliteSceneStatisticRepository>();
}
std::unique_ptr<IAuditLogRepository> RepositoryFactory::createAuditLogRepository() {
    return std::make_unique<SqliteAuditLogRepository>();
}

} // namespace Repository