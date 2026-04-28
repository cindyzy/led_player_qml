#include "scheduleparamservice.h"

// services/ScheduleParamService.cpp
// #include "ScheduleParamService.h"
#include "../repositories/RepositoryFactory.h"
#include "AuditLogService.h"

using namespace Repository;
using namespace LEDDB;

ScheduleParamService::ScheduleParamService() = default;

bool ScheduleParamService::saveScheduleParam(const ScheduleParam& param, const QString& operatorUser) {
    auto schedRepo = RepositoryFactory::createScheduleParamRepository();
    bool success;
    if (param.scheduleId() == 0) {
        success = schedRepo->insert(param);
    } else {
        success = schedRepo->update(param);
    }
    AuditLogService().logOperation(operatorUser, "保存调度参数",
                                   QString("场景类型 %1，阈值=%2").arg(param.sceneType()).arg(param.sceneThreshold()), success ? "成功" : "失败");
    return success;
}

bool ScheduleParamService::deleteScheduleParam(int scheduleId, const QString& operatorUser) {
    auto schedRepo = RepositoryFactory::createScheduleParamRepository();
    auto param = schedRepo->findById(scheduleId);
    if (!param) return false;
    bool success = schedRepo->deleteById(scheduleId);
    AuditLogService().logOperation(operatorUser, "删除调度参数",
                                   QString("删除场景 %1 的调度参数").arg(param->sceneType()), success ? "成功" : "失败");
    return success;
}

std::optional<ScheduleParam> ScheduleParamService::getScheduleParam(int scheduleId) {
    auto schedRepo = RepositoryFactory::createScheduleParamRepository();
    return schedRepo->findById(scheduleId);
}

std::optional<ScheduleParam> ScheduleParamService::getScheduleParamBySceneType(const QString& sceneType) {
    auto schedRepo = RepositoryFactory::createScheduleParamRepository();
    return schedRepo->findBySceneType(sceneType);
}

QList<ScheduleParam> ScheduleParamService::getAllScheduleParams() {
    auto schedRepo = RepositoryFactory::createScheduleParamRepository();
    return schedRepo->findAll();
}