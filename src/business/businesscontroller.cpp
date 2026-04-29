#include "businesscontroller.h"

// #include "BusinessController.h"

#include <QCoreApplication>
#include <QDebug>
#include <QDateTime>

#include "../database/databasemanager.h"
#include "../database/services/UserService.h"
#include "../database/services/LedDeviceService.h"
#include "../database/services/ProjectConfigService.h"
#include "../database/services/PlayListService.h"
#include "../database/services/ProgramInfoService.h"
#include "../database/services/WindowViewService.h"
#include "../database/services/MediaSourceService.h"
#include "../database/services/ScheduleParamService.h"
#include "../database/services/AiModelConfigService.h"
#include "../database/services/SceneStatisticService.h"
#include "../database/services/AuditLogService.h"
#include "../database/services/permissionservice.h"
#include "../database/services/roleservice.h"
using namespace LEDDB;
BusinessController::BusinessController(QObject* parent)
    : QObject(parent)
{
}

BusinessController::~BusinessController()
{
}

bool BusinessController::init()
{
    auto& dbMgr = DatabaseManager::instance();
    if (!dbMgr.initDatabase("LEDControl.db")) {
        qCritical() << "DB init failed";
        return false;
    }
    if (!dbMgr.checkIntegrity()) {
        qWarning() << "DB integrity check failed, but continue";
    }
    return true;
}

// ========== 辅助函数（内部审计） ==========
void BusinessController::recordAudit(int userId, const QString &opType, const QString &opResult,
                                     const QString &opDesc, const QString &targetTable, int targetId)
{
    AuditLogService auditSvc;
    auditSvc.logOperation(userId, opType, opResult, opDesc, targetTable, targetId, "127.0.0.1"); // IP 可从调用处传入
}

// ========== 1. 用户管理 ==========
bool BusinessController::createUser(const QString &userName, const QString &password, int roleId, const QString &operatorUser)
{
    UserService svc;
    User user;
    user.setUserName(userName);
    user.setPassword(password);
    user.setRoleId(roleId);
    user.setStatus(1);
    user.setCreateTime(QDateTime::currentDateTime());
    bool ok = svc.createUser(user, operatorUser);
    if (ok) recordAudit(0, "创建用户", "成功", QString("创建用户 %1").arg(userName), "sys_user", 0);
    return ok;
}

bool BusinessController::updateUser(int userId, const QString &userName, const QString &password, int roleId, int status, const QString &operatorUser)
{
    UserService svc;
    auto user = svc.getUserById(userId);
    if (!user) return false;
    user->setUserName(userName);
    if (!password.isEmpty()) user->setPassword(password);
    user->setRoleId(roleId);
    user->setStatus(status);
    bool ok = svc.updateUser(*user, operatorUser);
    if (ok) recordAudit(0, "更新用户", "成功", QString("更新用户 ID=%1").arg(userId), "sys_user", userId);
    return ok;
}

bool BusinessController::deleteUser(int userId, const QString &operatorUser)
{
    UserService svc;
    bool ok = svc.deleteUser(userId, operatorUser);
    if (ok) recordAudit(0, "删除用户", "成功", QString("删除用户 ID=%1").arg(userId), "sys_user", userId);
    return ok;
}

std::optional<User> BusinessController::getUserById(int userId)
{
    UserService svc;
    return svc.getUserById(userId);
}

std::optional<User> BusinessController::getUserByName(const QString &userName)
{
    UserService svc;
    return svc.getUserByName(userName);
}

QList<User> BusinessController::getAllUsers(int offset, int limit)
{
    UserService svc;
    return svc.getAllUsers(offset, limit);
}

bool BusinessController::authenticate(const QString &userName, const QString &password)
{
    UserService svc;
    bool ok = svc.authenticate(userName, password);
    if (ok) recordAudit(0, "登录", "成功", QString("用户 %1 登录").arg(userName), "sys_user", 0);
    else recordAudit(0, "登录", "失败", QString("用户 %1 登录失败").arg(userName), "sys_user", 0);
    return ok;
}

bool BusinessController::changePassword(int userId, const QString &oldPwd, const QString &newPwd, const QString &operatorUser)
{
    UserService svc;
    bool ok = svc.changePassword(userId, oldPwd, newPwd, operatorUser);
    if (ok) recordAudit(0, "修改密码", "成功", QString("用户 ID=%1 修改密码").arg(userId), "sys_user", userId);
    return ok;
}

// ========== 2. 角色管理 ==========
bool BusinessController::createRole(const QString &roleName, const QString &roleDesc, const QString &operatorUser)
{
    RoleService svc;
    Role role;
    role.setRoleName(roleName);
    role.setRoleDesc(roleDesc);
    bool ok = svc.createRole(role, operatorUser);
    if (ok) recordAudit(0, "创建角色", "成功", QString("创建角色 %1").arg(roleName), "sys_role", 0);
    return ok;
}

bool BusinessController::updateRole(int roleId, const QString &roleName, const QString &roleDesc, const QString &operatorUser)
{
    RoleService svc;
    auto role = svc.getRoleById(roleId);
    if (!role) return false;
    role->setRoleName(roleName);
    role->setRoleDesc(roleDesc);
    bool ok = svc.updateRole(*role, operatorUser);
    if (ok) recordAudit(0, "更新角色", "成功", QString("更新角色 ID=%1").arg(roleId), "sys_role", roleId);
    return ok;
}

bool BusinessController::deleteRole(int roleId, const QString &operatorUser)
{
    RoleService svc;
    bool ok = svc.deleteRole(roleId, operatorUser);
    if (ok) recordAudit(0, "删除角色", "成功", QString("删除角色 ID=%1").arg(roleId), "sys_role", roleId);
    return ok;
}

std::optional<Role> BusinessController::getRoleById(int roleId)
{
    RoleService svc;
    return svc.getRoleById(roleId);
}

QList<Role> BusinessController::getAllRoles()
{
    RoleService svc;
    return svc.getAllRoles();
}

// ========== 3. 权限管理 ==========
bool BusinessController::assignPermission(int roleId, const QString &permCode, const QString &permDesc, const QString &operatorUser)
{
    PermissionService svc;
    bool ok = svc.assignPermission(roleId, permCode, permDesc, operatorUser);
    if (ok) recordAudit(0, "分配权限", "成功", QString("角色 %1 分配权限 %2").arg(roleId).arg(permCode), "sys_permission", 0);
    return ok;
}

bool BusinessController::revokePermission(int permId, const QString &operatorUser)
{
    PermissionService svc;
    bool ok = svc.revokePermission(permId, operatorUser);
    if (ok) recordAudit(0, "撤销权限", "成功", QString("撤销权限 ID=%1").arg(permId), "sys_permission", permId);
    return ok;
}

QList<Permission> BusinessController::getPermissionsByRole(int roleId)
{
    PermissionService svc;
    return svc.getPermissionsByRole(roleId);
}

bool BusinessController::hasPermission(int roleId, const QString &permCode)
{
    PermissionService svc;
    return svc.hasPermission(roleId, permCode);
}

// ========== 4. LED设备管理 ==========
bool BusinessController::addDevice(const LedDevice &device, const QString &operatorUser)
{
    LedDeviceService svc;
    bool ok = svc.addDevice(device, operatorUser);
    if (ok) recordAudit(0, "添加设备", "成功", QString("添加设备 %1").arg(device.deviceName()), "led_device", 0);
    return ok;
}

bool BusinessController::updateDevice(const LedDevice &device, const QString &operatorUser)
{
    LedDeviceService svc;
    bool ok = svc.updateDevice(device, operatorUser);
    if (ok) recordAudit(0, "更新设备", "成功", QString("更新设备 %1").arg(device.deviceId()), "led_device", 0);
    return ok;
}

bool BusinessController::removeDevice(int deviceId, const QString &operatorUser)
{
    LedDeviceService svc;
    bool ok = svc.removeDevice(deviceId, operatorUser);
    if (ok) recordAudit(0, "删除设备", "成功", QString("删除设备 %1").arg(deviceId), "led_device", 0);
    return ok;
}

std::optional<LedDevice> BusinessController::getDeviceById(int deviceId)
{
    LedDeviceService svc;
    return svc.getDeviceById(deviceId);
}

QList<LedDevice> BusinessController::getAllDevices(int offset, int limit)
{
    LedDeviceService svc;
    return svc.getAllDevices(offset, limit);
}

QList<LedDevice> BusinessController::getOnlineDevices()
{
    LedDeviceService svc;
    return svc.getOnlineDevices();
}

bool BusinessController::setDeviceBrightness(int deviceId, int brightness, const QString &operatorUser)
{
    LedDeviceService svc;
    bool ok = svc.setBrightness(deviceId, brightness, operatorUser);
    if (ok) recordAudit(0, "调节亮度", "成功", QString("设备 %1 亮度调为 %2").arg(deviceId).arg(brightness), "led_device", 0);
    return ok;
}

bool BusinessController::setDeviceOnlineStatus(int deviceId, int status, const QString &operatorUser)
{
    LedDeviceService svc;
    bool ok = svc.setDeviceStatus(deviceId, status, operatorUser);
    if (ok) recordAudit(0, "设备状态", "成功", QString("设备 %1 状态变为 %2").arg(deviceId).arg(status), "led_device", 0);
    return ok;
}

// ========== 5. 项目组态管理 ==========
bool BusinessController::createProject(const ProjectConfig &project, const QString &operatorUser)
{
    ProjectConfigService svc;
    bool ok = svc.createProject(project, operatorUser);
    if (ok) recordAudit(0, "创建项目", "成功", QString("创建项目 %1").arg(project.projectName()), "project_config", 0);
    return ok;
}

bool BusinessController::updateProject(const ProjectConfig &project, const QString &operatorUser)
{
    ProjectConfigService svc;
    bool ok = svc.updateProject(project, operatorUser);
    if (ok) recordAudit(0, "更新项目", "成功", QString("更新项目 %1").arg(project.projectName()), "project_config", project.projectId());
    return ok;
}

bool BusinessController::deleteProject(int projectId, const QString &operatorUser)
{
    ProjectConfigService svc;
    bool ok = svc.deleteProject(projectId, operatorUser);
    if (ok) recordAudit(0, "删除项目", "成功", QString("删除项目 ID=%1").arg(projectId), "project_config", projectId);
    return ok;
}

bool BusinessController::cascadeDeleteProject(int projectId, const QString &operatorUser)
{
    ProjectConfigService svc;
    bool ok = svc.cascadeDeleteProject(projectId, operatorUser);
    if (ok) recordAudit(0, "级联删除项目", "成功", QString("级联删除项目 ID=%1").arg(projectId), "project_config", projectId);
    return ok;
}

std::optional<ProjectConfig> BusinessController::getProjectById(int projectId)
{
    ProjectConfigService svc;
    return svc.getProjectById(projectId);
}

QList<ProjectConfig> BusinessController::getValidProjects()
{
    ProjectConfigService svc;
    return svc.getValidProjects();
}

QList<ProjectConfig> BusinessController::getAllProjects()
{
    ProjectConfigService svc;
    return svc.getAllProjects();
}

// ========== 6. 播放列表管理 ==========
bool BusinessController::createPlaylist(int projectId, const QString &listName, int loopType, const QString &operatorUser)
{
    PlayListService svc;
    PlayList pl;
    pl.setProjectId(projectId);
    pl.setListName(listName);
    pl.setLoopType(loopType);
    pl.setStatus(1);
    pl.setPlaySort(svc.getPlayListsByProjectId(projectId).size());
    bool ok = svc.createPlayList(pl, operatorUser);
    if (ok) recordAudit(0, "创建播放列表", "成功", QString("在项目 %1 下创建列表 %2").arg(projectId).arg(listName), "play_list", 0);
    return ok;
}

bool BusinessController::updatePlaylist(int listId, const QString &listName, int loopType, const QString &operatorUser)
{
    PlayListService svc;
    auto pl = svc.getPlayListById(listId);
    if (!pl) return false;
    pl->setListName(listName);
    pl->setLoopType(loopType);
    bool ok = svc.updatePlayList(*pl, operatorUser);
    if (ok) recordAudit(0, "更新播放列表", "成功", QString("更新列表 ID=%1").arg(listId), "play_list", listId);
    return ok;
}

bool BusinessController::deletePlaylist(int listId, const QString &operatorUser)
{
    PlayListService svc;
    bool ok = svc.deletePlayList(listId, operatorUser);
    if (ok) recordAudit(0, "删除播放列表", "成功", QString("删除列表 ID=%1").arg(listId), "play_list", listId);
    return ok;
}

std::optional<PlayList> BusinessController::getPlaylistById(int listId)
{
    PlayListService svc;
    return svc.getPlayListById(listId);
}

QList<PlayList> BusinessController::getPlaylistsByProject(int projectId)
{
    PlayListService svc;
    return svc.getPlayListsByProjectId(projectId);
}

QList<PlayList> BusinessController::getAllPlaylists()
{
    PlayListService svc;
    return svc.getAllPlayLists();
}

bool BusinessController::reorderPlaylists(int projectId, const QList<int>& listIdsInOrder, const QString& operatorUser)
{
    PlayListService svc;
    bool ok = svc.reorderPlayLists(projectId, listIdsInOrder, operatorUser);
    if (ok) recordAudit(0, "重排播放列表", "成功", QString("项目 %1 播放列表顺序调整").arg(projectId), "play_list", 0);
    return ok;
}

// ========== 7. 节目管理 ==========
bool BusinessController::createProgram(int listId, const QString &programName, double playDuration, double intervalTime, const QString &operatorUser)
{
    ProgramInfoService svc;
    ProgramInfo prog;
    prog.setListId(listId);
    prog.setProgramName(programName);
    prog.setProgramSort(0);
    prog.setPlayDuration(playDuration);
    prog.setIntervalTime(intervalTime);
    prog.setStatus(1);
    bool ok = svc.createProgram(prog, operatorUser);
    if (ok) recordAudit(0, "创建节目", "成功", QString("在列表 %1 下创建节目 %2").arg(listId).arg(programName), "program_info", 0);
    return ok;
}

bool BusinessController::updateProgram(int programId, const QString &programName, double playDuration, double intervalTime, const QString &operatorUser)
{
    ProgramInfoService svc;
    auto prog = svc.getProgramById(programId);
    if (!prog) return false;
    prog->setProgramName(programName);
    prog->setPlayDuration(playDuration);
    prog->setIntervalTime(intervalTime);
    bool ok = svc.updateProgram(*prog, operatorUser);
    if (ok) recordAudit(0, "更新节目", "成功", QString("更新节目 ID=%1").arg(programId), "program_info", programId);
    return ok;
}

bool BusinessController::deleteProgram(int programId, const QString &operatorUser)
{
    ProgramInfoService svc;
    bool ok = svc.deleteProgram(programId, operatorUser);
    if (ok) recordAudit(0, "删除节目", "成功", QString("删除节目 ID=%1").arg(programId), "program_info", programId);
    return ok;
}

std::optional<ProgramInfo> BusinessController::getProgramById(int programId)
{
    ProgramInfoService svc;
    return svc.getProgramById(programId);
}

QList<ProgramInfo> BusinessController::getProgramsByPlaylist(int listId)
{
    ProgramInfoService svc;
    return svc.getProgramsByListId(listId);
}

bool BusinessController::reorderPrograms(int listId, const QList<int>& programIdsInOrder, const QString& operatorUser)
{
    ProgramInfoService svc;
    bool ok = svc.reorderPrograms(listId, programIdsInOrder, operatorUser);
    if (ok) recordAudit(0, "重排节目", "成功", QString("列表 %1 节目顺序调整").arg(listId), "program_info", 0);
    return ok;
}

// ========== 8. 视窗管理 ==========
bool BusinessController::createWindow(int programId, const QString &windowName, int x, int y, int width, int height, int zIndex, const QString &operatorUser)
{
    WindowViewService svc;
    WindowView win;
    win.setProgramId(programId);
    win.setWindowName(windowName);
    win.setXPos(x);
    win.setYPos(y);
    win.setWidth(width);
    win.setHeight(height);
    win.setZIndex(zIndex);
    win.setStatus(1);
    bool ok = svc.createWindow(win, operatorUser);
    if (ok) recordAudit(0, "创建视窗", "成功", QString("在节目 %1 下创建视窗 %2").arg(programId).arg(windowName), "window_view", 0);
    return ok;
}

bool BusinessController::updateWindow(int windowId, const QString &windowName, int x, int y, int width, int height, int zIndex, const QString &operatorUser)
{
    WindowViewService svc;
    auto win = svc.getWindowById(windowId);
    if (!win) return false;
    win->setWindowName(windowName);
    win->setXPos(x);
    win->setYPos(y);
    win->setWidth(width);
    win->setHeight(height);
    win->setZIndex(zIndex);
    bool ok = svc.updateWindow(*win, operatorUser);
    if (ok) recordAudit(0, "更新视窗", "成功", QString("更新视窗 ID=%1").arg(windowId), "window_view", windowId);
    return ok;
}

bool BusinessController::deleteWindow(int windowId, const QString &operatorUser)
{
    WindowViewService svc;
    bool ok = svc.deleteWindow(windowId, operatorUser);
    if (ok) recordAudit(0, "删除视窗", "成功", QString("删除视窗 ID=%1").arg(windowId), "window_view", windowId);
    return ok;
}

std::optional<WindowView> BusinessController::getWindowById(int windowId)
{
    WindowViewService svc;
    return svc.getWindowById(windowId);
}

QList<WindowView> BusinessController::getWindowsByProgram(int programId)
{
    WindowViewService svc;
    return svc.getWindowsByProgramId(programId);
}

bool BusinessController::reorderWindows(int programId, const QList<int>& windowIdsInOrder, const QString& operatorUser)
{
    // 通过调整 zIndex 实现重排
    WindowViewService svc;
    bool ok = true;
    for (int i = 0; i < windowIdsInOrder.size(); ++i) {
        auto win = svc.getWindowById(windowIdsInOrder[i]);
        if (!win || win->programId() != programId) {
            ok = false;
            break;
        }
        win->setZIndex(i);
        if (!svc.updateWindow(*win, operatorUser)) {
            ok = false;
            break;
        }
    }
    if (ok) recordAudit(0, "重排视窗", "成功", QString("节目 %1 视窗顺序调整").arg(programId), "window_view", 0);
    return ok;
}

// ========== 9. 素材管理 ==========
bool BusinessController::addMedia(int windowId, const QString &filePath, const QString &fileType, double duration, int mediaSort, const QString &operatorUser)
{
    MediaSourceService svc;
    MediaSource media;
    media.setWindowId(windowId);
    media.setFilePath(filePath);
    media.setFileType(fileType);
    media.setDuration(duration);
    media.setMediaSort(mediaSort);
    bool ok = svc.addMedia(media, operatorUser);
    if (ok) recordAudit(0, "添加素材", "成功", QString("向视窗 %1 添加素材 %2").arg(windowId).arg(filePath), "media_source", 0);
    return ok;
}

bool BusinessController::updateMedia(int mediaId, const QString &filePath, const QString &fileType, double duration, int mediaSort, const QString &operatorUser)
{
    MediaSourceService svc;
    auto media = svc.getMediaById(mediaId);
    if (!media) return false;
    media->setFilePath(filePath);
    media->setFileType(fileType);
    media->setDuration(duration);
    media->setMediaSort(mediaSort);
    bool ok = svc.updateMedia(*media, operatorUser);
    if (ok) recordAudit(0, "更新素材", "成功", QString("更新素材 ID=%1").arg(mediaId), "media_source", mediaId);
    return ok;
}

bool BusinessController::deleteMedia(int mediaId, const QString &operatorUser)
{
    MediaSourceService svc;
    bool ok = svc.removeMedia(mediaId, operatorUser);
    if (ok) recordAudit(0, "删除素材", "成功", QString("删除素材 ID=%1").arg(mediaId), "media_source", mediaId);
    return ok;
}

std::optional<MediaSource> BusinessController::getMediaById(int mediaId)
{
    MediaSourceService svc;
    return svc.getMediaById(mediaId);
}

QList<MediaSource> BusinessController::getMediaByWindow(int windowId)
{
    MediaSourceService svc;
    return svc.getMediaByWindow(windowId);
}

bool BusinessController::reorderMedia(int windowId, const QList<int>& mediaIdsInOrder, const QString& operatorUser)
{
    MediaSourceService svc;
    bool ok = svc.reorderMedia(windowId, mediaIdsInOrder, operatorUser);
    if (ok) recordAudit(0, "重排素材", "成功", QString("视窗 %1 素材顺序调整").arg(windowId), "media_source", 0);
    return ok;
}

// ========== 10. 智能调度参数 ==========
bool BusinessController::saveScheduleParam(const ScheduleParam &param, const QString &operatorUser)
{
    ScheduleParamService svc;
    bool ok = svc.saveScheduleParam(param, operatorUser);
    if (ok) recordAudit(0, "保存调度参数", "成功", QString("保存场景 %1 参数").arg(param.sceneType()), "schedule_param", param.scheduleId());
    return ok;
}

bool BusinessController::deleteScheduleParam(int scheduleId, const QString &operatorUser)
{
    ScheduleParamService svc;
    bool ok = svc.deleteScheduleParam(scheduleId, operatorUser);
    if (ok) recordAudit(0, "删除调度参数", "成功", QString("删除调度参数 ID=%1").arg(scheduleId), "schedule_param", scheduleId);
    return ok;
}

std::optional<ScheduleParam> BusinessController::getScheduleParamById(int scheduleId)
{
    ScheduleParamService svc;
    return svc.getScheduleParam(scheduleId);
}

std::optional<ScheduleParam> BusinessController::getScheduleParamBySceneType(const QString &sceneType)
{
    ScheduleParamService svc;
    return svc.getScheduleParamBySceneType(sceneType);
}

QList<ScheduleParam> BusinessController::getAllScheduleParams()
{
    ScheduleParamService svc;
    return svc.getAllScheduleParams();
}

// ========== 11. AI模型配置 ==========
bool BusinessController::addAiModelConfig(const AiModelConfig &config, const QString &operatorUser)
{
    AiModelConfigService svc;
    bool ok = svc.addModelConfig(config, operatorUser);
    if (ok) recordAudit(0, "添加AI模型", "成功", QString("添加模型 %1").arg(config.modelName()), "ai_model_config", 0);
    return ok;
}

bool BusinessController::updateAiModelConfig(const AiModelConfig &config, const QString &operatorUser)
{
    AiModelConfigService svc;
    bool ok = svc.updateModelConfig(config, operatorUser);
    if (ok) recordAudit(0, "更新AI模型", "成功", QString("更新模型 %1").arg(config.modelName()), "ai_model_config", config.configId());
    return ok;
}

bool BusinessController::deleteAiModelConfig(int configId, const QString &operatorUser)
{
    AiModelConfigService svc;
    bool ok = svc.removeModelConfig(configId, operatorUser);
    if (ok) recordAudit(0, "删除AI模型", "成功", QString("删除模型配置 ID=%1").arg(configId), "ai_model_config", configId);
    return ok;
}

std::optional<AiModelConfig> BusinessController::getAiModelConfigById(int configId)
{
    AiModelConfigService svc;
    return svc.getModelConfig(configId);
}

QList<AiModelConfig> BusinessController::getEnabledAiModels()
{
    AiModelConfigService svc;
    return svc.getEnabledModels();
}

QList<AiModelConfig> BusinessController::getAllAiModels()
{
    AiModelConfigService svc;
    return svc.getAllModels();
}

// ========== 12. 场景统计 ==========
bool BusinessController::recordSceneData(const SceneStatistic &stat)
{
    SceneStatisticService svc;
    return svc.recordSceneData(stat);
}

QList<SceneStatistic> BusinessController::getStatisticsByProject(int projectId)
{
    SceneStatisticService svc;
    return svc.getStatisticsByProject(projectId);
}

QList<SceneStatistic> BusinessController::getStatisticsByTimeRange(const QDateTime &start, const QDateTime &end)
{
    SceneStatisticService svc;
    return svc.getStatisticsByTimeRange(start, end);
}

QList<SceneStatistic> BusinessController::getLatestStatistics(int limit)
{
    SceneStatisticService svc;
    return svc.getLatestStatistics(limit);
}

bool BusinessController::archiveStatisticsOlderThan(int daysToKeep)
{
    SceneStatisticService svc;
    return svc.archiveOldData(daysToKeep);
}

// ========== 13. 审计日志 ==========
void BusinessController::logOperation(int userId, const QString &operationType, const QString &operateResult,
                                      const QString &operationDesc, const QString &targetTable, int targetId, const QString &clientIp)
{
    AuditLogService svc;
    svc.logOperation(userId, operationType, operateResult, operationDesc, targetTable, targetId, clientIp);
}

QList<AuditLog> BusinessController::getLogsByUser(int userId, int limit)
{
    AuditLogService svc;
    return svc.getLogsByUserId(userId, limit);
}

QList<AuditLog> BusinessController::getLogsByType(const QString &operationType, int limit)
{
    AuditLogService svc;
    return svc.getLogsByOperationType(operationType, limit);
}

QList<AuditLog> BusinessController::getLogsByTimeRange(const QDateTime &start, const QDateTime &end)
{
    AuditLogService svc;
    return svc.getLogsByTimeRange(start, end);
}

QList<AuditLog> BusinessController::getAllLogs(int offset, int limit)
{
    AuditLogService svc;
    return svc.getAllLogs(offset, limit);
}

// ========== 辅助方法 ==========
QString BusinessController::getCurrentOperator()
{
    // 实际应用中应从登录会话中获取当前用户名，这里简单返回一个固定值
    return "system";
}

