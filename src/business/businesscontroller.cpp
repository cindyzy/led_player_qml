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

using namespace LEDDB;
BusinessController::BusinessController(QObject* parent)
: QObject(parent) {}
BusinessController::~BusinessController()
{
}
bool BusinessController::init() {
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

void BusinessController::userLoginDemo() {
    UserService userSvc;
    QString username = "admin";
    QString password = "admin123";

    if (userSvc.authenticate(username, password)) {
        qDebug() << "Login success";
        auto user = userSvc.getUserByName(username);
        if (user) {
            qDebug() << "Welcome" << user->userName() << "roleId:" << user->roleId();
            PermissionService permSvc;
            if (permSvc.hasPermission(user->roleId(), "device:control")) {
                qDebug() << "User has device control permission";
            }
        }
    } else {
        qDebug() << "Login failed";
    }
}

void BusinessController::batchAddDevices() {
    LedDeviceService devSvc;
    QList<LedDevice> devices;
    for (int i = 1; i <= 3; ++i) {
        LedDevice dev;
        dev.setDeviceId(QString("DEV_%1").arg(i));
        dev.setDeviceName(QString("显示屏%1").arg(i));
        dev.setDeviceType(i == 1 ? "灯带" : "地砖屏");
        dev.setIpAddr(QString("192.168.1.%1").arg(100 + i));
        dev.setPort(8080);
        dev.setBrightness(50);
        dev.setOnlineStatus(0);
        devices.append(dev);
    }

    auto& dbMgr = DatabaseManager::instance();
    dbMgr.beginTransaction();
    bool ok = true;
    for (const auto& dev : devices) {
        if (!devSvc.addDevice(dev, "system")) {
            ok = false;
            break;
        }
    }
    if (ok && dbMgr.commitTransaction()) {
        qDebug() << "Batch add devices succeeded";
    } else {
        dbMgr.rollbackTransaction();
        qDebug() << "Batch add devices failed";
    }
}

void BusinessController::adjustBrightnessDemo() {
    LedDeviceService devSvc;
    QString deviceId = "DEV_1";
    int newBrightness = 80;
    if (devSvc.setBrightness(deviceId, newBrightness, "admin")) {
        qDebug() << "Brightness adjusted";
    } else {
        qDebug() << "Adjust brightness failed";
    }
}

void BusinessController::createFullPlayChain() {
    ProjectConfigService projSvc;
    ProjectConfig project;
    project.setProjectName("国庆晚会主屏");
    project.setWindowLayout("{\"layout\":\"grid\"}");
    project.setLightMapping("{\"mapping\":\"default\"}");
    project.setCronStrategy("0 19 * * *");
    project.setIsValid(1);
    if (!projSvc.createProject(project, "admin")) {
        qDebug() << "Create project failed";
        return;
    }
    int projectId = 1;

    PlayListService plSvc;
    PlayList playlist;
    playlist.setProjectId(projectId);
    playlist.setListName("主播放列表");
    playlist.setPlaySort(0);
    playlist.setLoopType(1);
    playlist.setStatus(1);
    if (!plSvc.createPlayList(playlist, "admin")) {
        qDebug() << "Create playlist failed";
        return;
    }
    int listId = 1;

    ProgramInfoService progSvc;
    ProgramInfo program;
    program.setListId(listId);
    program.setProgramName("开场节目");
    program.setProgramSort(0);
    program.setPlayDuration(120.0);
    program.setIntervalTime(5.0);
    program.setStatus(1);
    if (!progSvc.createProgram(program, "admin")) {
        qDebug() << "Create program failed";
        return;
    }
    int programId = 1;

    WindowViewService viewSvc;
    WindowView window;
    window.setProgramId(programId);
    window.setWindowName("主视窗");
    window.setXPos(0);
    window.setYPos(0);
    window.setWidth(1920);
    window.setHeight(1080);
    window.setZIndex(0);
    window.setStatus(1);
    if (!viewSvc.createWindow(window, "admin")) {
        qDebug() << "Create window failed";
        return;
    }
    int windowId = 1;

    MediaSourceService mediaSvc;
    MediaSource media;
    media.setWindowId(windowId);
    media.setFilePath("/videos/opening.mp4");
    media.setFileType("mp4");
    media.setDuration(120.0);
    media.setMediaSort(0);
    if (!mediaSvc.addMedia(media, "admin")) {
        qDebug() << "Add media failed";
        return;
    }

    qDebug() << "Full play chain created successfully!";
}

void BusinessController::cascadeDeleteProjectDemo() {
    ProjectConfigService projSvc;
    int projectId = 1;
    if (projSvc.cascadeDeleteProject(projectId, "admin")) {
        qDebug() << "Project cascade deleted";
    } else {
        qDebug() << "Delete failed";
    }
}

void BusinessController::scheduleParamDemo() {
    ScheduleParamService schedSvc;
    ScheduleParam param;
    param.setSceneType("concert");
    param.setSceneThreshold(0.65);
    param.setPredictCycle(10);
    param.setEnvWeight(0.3);
    param.setSceneWeight(0.7);
    param.setBrightnessMin(20);
    param.setBrightnessMax(100);
    param.setStrategyJson("{\"dynamic\":true}");
    if (schedSvc.saveScheduleParam(param, "admin")) {
        qDebug() << "Schedule param saved";
    }

    auto found = schedSvc.getScheduleParamBySceneType("concert");
    if (found) {
        qDebug() << "Found schedule for concert, brightness range:"
                 << found->brightnessMin() << "-" << found->brightnessMax();
    }
}

void BusinessController::aiModelDemo() {
    AiModelConfigService aiSvc;
    AiModelConfig config;
    config.setModelName("GPT-4 Vision");
    config.setApiUrl("https://api.openai.com/v1/chat/completions");
    config.setApiKey("sk-xxxxxxxxxxxxxxxxxxxx");
    config.setTimeout(30000);
    config.setOfflineStrategy("local");
    config.setEnableStatus(1);
    if (aiSvc.addModelConfig(config, "admin")) {
        qDebug() << "AI model added";
    }

    auto enabled = aiSvc.getEnabledModels();
    qDebug() << "Enabled models count:" << enabled.size();
}

void BusinessController::sceneStatisticDemo() {
    SceneStatisticService statSvc;
    SceneStatistic stat;
    stat.setCollectTime(QDateTime::currentDateTime());
    stat.setEnvBrightness(65);
    stat.setSceneStatus("crowd_cheering");
    stat.setScheduleResult("increase_brightness_to_80");
    if (statSvc.recordSceneData(stat)) {
        qDebug() << "Scene data recorded";
    }

    auto latest = statSvc.getLatestStatistics(10);
    qDebug() << "Got" << latest.size() << "latest records";

    if (statSvc.archiveOldData(30)) {
        qDebug() << "Archived data older than 30 days";
    }
}

void BusinessController::auditLogDemo() {
    AuditLogService auditSvc;
    auditSvc.logOperation("admin", "手动测试", "测试审计日志", "成功");

    auto logs = auditSvc.getLogsByUser("admin", 50);
    qDebug() << "Admin logs count:" << logs.size();
    for (const auto& log : logs) {
        qDebug() << log.operateTime().toString() << log.operateType() << log.operateContent();
    }
}

void BusinessController::reorderProgramsDemo() {
    ProgramInfoService progSvc;
    int listId = 1;
    QList<int> newOrder = {103, 101, 102};
    if (progSvc.reorderPrograms(listId, newOrder, "admin")) {
        qDebug() << "Programs reordered";
    } else {
        qDebug() << "Reorder failed";
    }
}

// ========== PlayList 相关方法实现 ==========

// 播放列表操作
bool BusinessController::createPlaylist(int projectId, const QString& listName, int playSort, int loopType, const QString& operatorUser) {
    PlayListService plSvc;
    PlayList playlist;
    playlist.setProjectId(projectId);
    playlist.setListName(listName);
    playlist.setPlaySort(playSort);
    playlist.setLoopType(loopType);
    playlist.setStatus(1);
    return plSvc.createPlayList(playlist, operatorUser);
}

bool BusinessController::updatePlaylist(int listId, const QString& listName, int playSort, int loopType, const QString& operatorUser) {
    PlayListService plSvc;
    auto playlist = plSvc.getPlayListById(listId);
    if (!playlist) {
        qDebug() << "Playlist not found:" << listId;
        return false;
    }
    playlist->setListName(listName);
    playlist->setPlaySort(playSort);
    playlist->setLoopType(loopType);
    return plSvc.updatePlayList(*playlist, operatorUser);
}

bool BusinessController::deletePlaylist(int listId, const QString& operatorUser) {
    PlayListService plSvc;
    return plSvc.deletePlayList(listId, operatorUser);
}

std::optional<LEDDB::PlayList> BusinessController::getPlaylistById(int listId) {
    PlayListService plSvc;
    return plSvc.getPlayListById(listId);
}

QList<LEDDB::PlayList> BusinessController::getAllPlaylists() {
    PlayListService plSvc;
    return plSvc.getAllPlayLists();
}

QList<LEDDB::PlayList> BusinessController::getPlaylistsByProject(int projectId) {
    PlayListService plSvc;
    return plSvc.getPlayListsByProjectId(projectId);
}

// 节目操作
bool BusinessController::createProgram(int listId, const QString& programName, double playDuration, double intervalTime, const QString& operatorUser) {
    ProgramInfoService progSvc;
    ProgramInfo program;
    program.setListId(listId);
    program.setProgramName(programName);
    program.setProgramSort(0);
    program.setPlayDuration(playDuration);
    program.setIntervalTime(intervalTime);
    program.setStatus(1);
    return progSvc.createProgram(program, operatorUser);
}

bool BusinessController::updateProgram(int programId, const QString& programName, double playDuration, double intervalTime, const QString& operatorUser) {
    ProgramInfoService progSvc;
    auto program = progSvc.getProgramById(programId);
    if (!program) {
        qDebug() << "Program not found:" << programId;
        return false;
    }
    program->setProgramName(programName);
    program->setPlayDuration(playDuration);
    program->setIntervalTime(intervalTime);
    return progSvc.updateProgram(*program, operatorUser);
}

bool BusinessController::deleteProgram(int programId, const QString& operatorUser) {
    ProgramInfoService progSvc;
    return progSvc.deleteProgram(programId, operatorUser);
}

bool BusinessController::reorderPrograms(int listId, const QList<int>& programIds, const QString& operatorUser) {
    ProgramInfoService progSvc;
    return progSvc.reorderPrograms(listId, programIds, operatorUser);
}

std::optional<LEDDB::ProgramInfo> BusinessController::getProgramById(int programId) {
    ProgramInfoService progSvc;
    return progSvc.getProgramById(programId);
}

QList<LEDDB::ProgramInfo> BusinessController::getProgramsByPlaylist(int listId) {
    ProgramInfoService progSvc;
    return progSvc.getProgramsByListId(listId);
}

// 视窗操作
bool BusinessController::createWindow(int programId, const QString& windowName, int xPos, int yPos, int width, int height, int zIndex, const QString& operatorUser) {
    WindowViewService viewSvc;
    WindowView window;
    window.setProgramId(programId);
    window.setWindowName(windowName);
    window.setXPos(xPos);
    window.setYPos(yPos);
    window.setWidth(width);
    window.setHeight(height);
    window.setZIndex(zIndex);
    window.setStatus(1);
    return viewSvc.createWindow(window, operatorUser);
}

bool BusinessController::updateWindow(int windowId, const QString& windowName, int xPos, int yPos, int width, int height, int zIndex, const QString& operatorUser) {
    WindowViewService viewSvc;
    auto window = viewSvc.getWindowById(windowId);
    if (!window) {
        qDebug() << "Window not found:" << windowId;
        return false;
    }
    window->setWindowName(windowName);
    window->setXPos(xPos);
    window->setYPos(yPos);
    window->setWidth(width);
    window->setHeight(height);
    window->setZIndex(zIndex);
    return viewSvc.updateWindow(*window, operatorUser);
}

bool BusinessController::deleteWindow(int windowId, const QString& operatorUser) {
    WindowViewService viewSvc;
    return viewSvc.deleteWindow(windowId, operatorUser);
}

std::optional<LEDDB::WindowView> BusinessController::getWindowById(int windowId) {
    WindowViewService viewSvc;
    return viewSvc.getWindowById(windowId);
}

QList<LEDDB::WindowView> BusinessController::getWindowsByProgram(int programId) {
    WindowViewService viewSvc;
    return viewSvc.getWindowsByProgramId(programId);
}

// 素材操作
bool BusinessController::addMedia(int windowId, const QString& filePath, const QString& fileType, double duration, int mediaSort, const QString& operatorUser) {
    MediaSourceService mediaSvc;
    MediaSource media;
    media.setWindowId(windowId);
    media.setFilePath(filePath);
    media.setFileType(fileType);
    media.setDuration(duration);
    media.setMediaSort(mediaSort);
    return mediaSvc.addMedia(media, operatorUser);
}

bool BusinessController::updateMedia(int mediaId, const QString& filePath, const QString& fileType, double duration, int mediaSort, const QString& operatorUser) {
    MediaSourceService mediaSvc;
    auto media = mediaSvc.getMediaById(mediaId);
    if (!media) {
        qDebug() << "Media not found:" << mediaId;
        return false;
    }
    media->setFilePath(filePath);
    media->setFileType(fileType);
    media->setDuration(duration);
    media->setMediaSort(mediaSort);
    return mediaSvc.updateMedia(*media, operatorUser);
}

bool BusinessController::deleteMedia(int mediaId, const QString& operatorUser) {
    MediaSourceService mediaSvc;
    return mediaSvc.removeMedia(mediaId, operatorUser);
}

bool BusinessController::reorderMedia(int windowId, const QList<int>& mediaIds, const QString& operatorUser) {
    MediaSourceService mediaSvc;
    return mediaSvc.reorderMedia(windowId, mediaIds, operatorUser);
}

std::optional<LEDDB::MediaSource> BusinessController::getMediaById(int mediaId) {
    MediaSourceService mediaSvc;
    return mediaSvc.getMediaById(mediaId);
}

QList<LEDDB::MediaSource> BusinessController::getMediaByWindow(int windowId) {
    MediaSourceService mediaSvc;
    return mediaSvc.getMediaByWindow(windowId);
}