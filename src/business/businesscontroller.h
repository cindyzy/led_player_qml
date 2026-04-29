#ifndef BUSINESSCONTROLLER_H
#define BUSINESSCONTROLLER_H

#include <QString>
#include <QList>

// 前向声明所有用到的实体类（避免在头文件中包含所有 service 头文件？但方法参数中使用了这些实体类，所以必须包含实体类定义）
// 为了减少编译依赖，可以包含实体类头文件或前向声明 + 引用。但这里由于方法参数使用值类型，必须包含完整定义。
// 简单起见，直接包含所需头文件。
#include "../database/entities/user.h"
#include "../database/entities/role.h"
#include "../database/entities/permission.h"
#include "../database/entities/leddevice.h"
#include "../database/entities/projectconfig.h"
#include "../database/entities/playlist.h"
#include "../database/entities/programinfo.h"
#include "../database/entities/windowview.h"
#include "../database/entities/mediasource.h"
#include "../database/entities/scheduleparam.h"
#include "../database/entities/aimodelconfig.h"
#include "../database/entities/scenestatistic.h"
#include "../database/entities/auditlog.h"

class BusinessController: public QObject {
public:
    explicit BusinessController(QObject* parent = nullptr);
    ~BusinessController();
    // 初始化数据库
    Q_INVOKABLE bool init();

    // ========================= 1. 用户管理 =========================
    Q_INVOKABLE bool createUser(const QString &userName, const QString &password, int roleId, const QString &operatorUser);
    Q_INVOKABLE bool updateUser(int userId, const QString &userName, const QString &password, int roleId, int status, const QString &operatorUser);
    Q_INVOKABLE bool deleteUser(int userId, const QString &operatorUser);
    Q_INVOKABLE std::optional<LEDDB::User> getUserById(int userId);
    Q_INVOKABLE std::optional<LEDDB::User> getUserByName(const QString &userName);
    Q_INVOKABLE QList<LEDDB::User> getAllUsers(int offset = 0, int limit = 100);
    Q_INVOKABLE bool authenticate(const QString &userName, const QString &password);
    Q_INVOKABLE bool changePassword(int userId, const QString &oldPwd, const QString &newPwd, const QString &operatorUser);

    // ========================= 2. 角色管理 =========================
    Q_INVOKABLE bool createRole(const QString &roleName, const QString &roleDesc, const QString &operatorUser);
    Q_INVOKABLE bool updateRole(int roleId, const QString &roleName, const QString &roleDesc, const QString &operatorUser);
    Q_INVOKABLE bool deleteRole(int roleId, const QString &operatorUser);
    Q_INVOKABLE std::optional<LEDDB::Role> getRoleById(int roleId);
    Q_INVOKABLE QList<LEDDB::Role> getAllRoles();

    // ========================= 3. 权限管理 =========================
    Q_INVOKABLE bool assignPermission(int roleId, const QString &permCode, const QString &permDesc, const QString &operatorUser);
    Q_INVOKABLE bool revokePermission(int permId, const QString &operatorUser);
    Q_INVOKABLE QList<LEDDB::Permission> getPermissionsByRole(int roleId);
    Q_INVOKABLE bool hasPermission(int roleId, const QString &permCode);

    // ========================= 4. LED设备管理 =========================
    Q_INVOKABLE bool addDevice(const LEDDB::LedDevice &device, const QString &operatorUser);
    Q_INVOKABLE bool updateDevice(const LEDDB::LedDevice &device, const QString &operatorUser);
    Q_INVOKABLE bool removeDevice(int deviceId, const QString &operatorUser);
    Q_INVOKABLE std::optional<LEDDB::LedDevice> getDeviceById(int deviceId);
    Q_INVOKABLE QList<LEDDB::LedDevice> getAllDevices(int offset = 0, int limit = 100);
    Q_INVOKABLE QList<LEDDB::LedDevice> getOnlineDevices();
    Q_INVOKABLE bool setDeviceBrightness(int deviceId, int brightness, const QString &operatorUser);
    Q_INVOKABLE bool setDeviceOnlineStatus(int deviceId, int status, const QString &operatorUser);

    // ========================= 5. 项目组态管理 =========================
    Q_INVOKABLE bool createProject(const LEDDB::ProjectConfig &project, const QString &operatorUser);
    Q_INVOKABLE bool updateProject(const LEDDB::ProjectConfig &project, const QString &operatorUser);
    Q_INVOKABLE bool deleteProject(int projectId, const QString &operatorUser);
    Q_INVOKABLE bool cascadeDeleteProject(int projectId, const QString &operatorUser);
    Q_INVOKABLE std::optional<LEDDB::ProjectConfig> getProjectById(int projectId);
    Q_INVOKABLE QList<LEDDB::ProjectConfig> getValidProjects();
    Q_INVOKABLE QList<LEDDB::ProjectConfig> getAllProjects();

    // ========================= 6. 播放列表管理 =========================
    Q_INVOKABLE bool createPlaylist(int projectId, const QString &listName, int loopType, const QString &operatorUser);
    Q_INVOKABLE bool updatePlaylist(int listId, const QString &listName, int loopType, const QString &operatorUser);
    Q_INVOKABLE bool deletePlaylist(int listId, const QString &operatorUser);
    Q_INVOKABLE std::optional<LEDDB::PlayList> getPlaylistById(int listId);
    Q_INVOKABLE QList<LEDDB::PlayList> getPlaylistsByProject(int projectId);
    Q_INVOKABLE QList<LEDDB::PlayList> getAllPlaylists();
    Q_INVOKABLE bool reorderPlaylists(int projectId, const QList<int> &listIdsInOrder, const QString &operatorUser);

    // ========================= 7. 节目管理 =========================
    Q_INVOKABLE bool createProgram(int listId, const QString &programName, double playDuration, double intervalTime, const QString &operatorUser);
    Q_INVOKABLE bool updateProgram(int programId, const QString &programName, double playDuration, double intervalTime, const QString &operatorUser);
    Q_INVOKABLE bool deleteProgram(int programId, const QString &operatorUser);
    Q_INVOKABLE std::optional<LEDDB::ProgramInfo> getProgramById(int programId);
    Q_INVOKABLE QList<LEDDB::ProgramInfo> getProgramsByPlaylist(int listId);
    Q_INVOKABLE bool reorderPrograms(int listId, const QList<int> &programIdsInOrder, const QString &operatorUser);

    // ========================= 8. 视窗管理 =========================
    Q_INVOKABLE bool createWindow(int programId, const QString &windowName, int x, int y, int width, int height, int zIndex, const QString &operatorUser);
    Q_INVOKABLE bool updateWindow(int windowId, const QString &windowName, int x, int y, int width, int height, int zIndex, const QString &operatorUser);
    Q_INVOKABLE bool deleteWindow(int windowId, const QString &operatorUser);
    Q_INVOKABLE std::optional<LEDDB::WindowView> getWindowById(int windowId);
    Q_INVOKABLE QList<LEDDB::WindowView> getWindowsByProgram(int programId);
    Q_INVOKABLE bool reorderWindows(int programId, const QList<int> &windowIdsInOrder, const QString &operatorUser);

    // ========================= 9. 素材管理 =========================
    Q_INVOKABLE bool addMedia(int windowId, const QString &filePath, const QString &fileType, double duration, int mediaSort, const QString &operatorUser);
    Q_INVOKABLE bool updateMedia(int mediaId, const QString &filePath, const QString &fileType, double duration, int mediaSort, const QString &operatorUser);
    Q_INVOKABLE bool deleteMedia(int mediaId, const QString &operatorUser);
    Q_INVOKABLE std::optional<LEDDB::MediaSource> getMediaById(int mediaId);
    Q_INVOKABLE QList<LEDDB::MediaSource> getMediaByWindow(int windowId);
    Q_INVOKABLE bool reorderMedia(int windowId, const QList<int> &mediaIdsInOrder, const QString &operatorUser);

    // ========================= 10. 智能调度参数 =========================
    Q_INVOKABLE bool saveScheduleParam(const LEDDB::ScheduleParam &param, const QString &operatorUser);
    Q_INVOKABLE bool deleteScheduleParam(int scheduleId, const QString &operatorUser);
    Q_INVOKABLE std::optional<LEDDB::ScheduleParam> getScheduleParamById(int scheduleId);
    Q_INVOKABLE std::optional<LEDDB::ScheduleParam> getScheduleParamBySceneType(const QString &sceneType);
    Q_INVOKABLE QList<LEDDB::ScheduleParam> getAllScheduleParams();

    // ========================= 11. AI模型配置 =========================
    Q_INVOKABLE bool addAiModelConfig(const LEDDB::AiModelConfig &config, const QString &operatorUser);
    Q_INVOKABLE bool updateAiModelConfig(const LEDDB::AiModelConfig &config, const QString &operatorUser);
    Q_INVOKABLE bool deleteAiModelConfig(int configId, const QString &operatorUser);
    Q_INVOKABLE std::optional<LEDDB::AiModelConfig> getAiModelConfigById(int configId);
    Q_INVOKABLE QList<LEDDB::AiModelConfig> getEnabledAiModels();
    Q_INVOKABLE QList<LEDDB::AiModelConfig> getAllAiModels();

    // ========================= 12. 场景统计 =========================
    Q_INVOKABLE bool recordSceneData(const LEDDB::SceneStatistic &stat);
    Q_INVOKABLE QList<LEDDB::SceneStatistic> getStatisticsByProject(int projectId);
    Q_INVOKABLE QList<LEDDB::SceneStatistic> getStatisticsByTimeRange(const QDateTime &start, const QDateTime &end);
    Q_INVOKABLE QList<LEDDB::SceneStatistic> getLatestStatistics(int limit = 100);
    Q_INVOKABLE bool archiveStatisticsOlderThan(int daysToKeep);

    // ========================= 13. 审计日志 =========================
    Q_INVOKABLE void logOperation(int userId, const QString &operationType, const QString &operateResult,
                                  const QString &operationDesc, const QString &targetTable,
                                  int targetId, const QString &clientIp);
    Q_INVOKABLE QList<LEDDB::AuditLog> getLogsByUser(int userId, int limit = 100);
    Q_INVOKABLE QList<LEDDB::AuditLog> getLogsByType(const QString &operationType, int limit = 100);
    Q_INVOKABLE QList<LEDDB::AuditLog> getLogsByTimeRange(const QDateTime &start, const QDateTime &end);
    Q_INVOKABLE QList<LEDDB::AuditLog> getAllLogs(int offset = 0, int limit = 100);

    // ========================= 辅助方法 =========================
    Q_INVOKABLE QString getCurrentOperator();   // 获取当前登录用户（示例：从登录会话获取）

private:
    // 内部辅助函数：记录审计日志
    void recordAudit(int userId, const QString &opType, const QString &opResult,
                     const QString &opDesc, const QString &targetTable, int targetId);
};

#endif // BUSINESSCONTROLLER_H