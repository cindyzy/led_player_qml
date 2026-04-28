#ifndef BUSINESSCONTROLLER_H
#define BUSINESSCONTROLLER_H

#include <QString>
#include <QList>

// 前向声明所有用到的实体类（避免在头文件中包含所有 service 头文件？但方法参数中使用了这些实体类，所以必须包含实体类定义）
// 为了减少编译依赖，可以包含实体类头文件或前向声明 + 引用。但这里由于方法参数使用值类型，必须包含完整定义。
// 简单起见，直接包含所需头文件。
#include "../database/entities/user.h"
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
    bool init();

    void userLoginDemo();
    void batchAddDevices();
    void adjustBrightnessDemo();
    void createFullPlayChain();
    void cascadeDeleteProjectDemo();
    void scheduleParamDemo();
    void aiModelDemo();
    void sceneStatisticDemo();
    void auditLogDemo();
    void reorderProgramsDemo();

    // ========== PlayList 相关方法 ==========
    
    // 播放列表操作
    bool createPlaylist(int projectId, const QString& listName, int playSort, int loopType, const QString& operatorUser);
    bool updatePlaylist(int listId, const QString& listName, int playSort, int loopType, const QString& operatorUser);
    bool deletePlaylist(int listId, const QString& operatorUser);
    std::optional<LEDDB::PlayList> getPlaylistById(int listId);
    QList<LEDDB::PlayList> getAllPlaylists();
    QList<LEDDB::PlayList> getPlaylistsByProject(int projectId);

    // 节目操作
    bool createProgram(int listId, const QString& programName, double playDuration, double intervalTime, const QString& operatorUser);
    bool updateProgram(int programId, const QString& programName, double playDuration, double intervalTime, const QString& operatorUser);
    bool deleteProgram(int programId, const QString& operatorUser);
    bool reorderPrograms(int listId, const QList<int>& programIds, const QString& operatorUser);
    std::optional<LEDDB::ProgramInfo> getProgramById(int programId);
    QList<LEDDB::ProgramInfo> getProgramsByPlaylist(int listId);

    // 视窗操作
    bool createWindow(int programId, const QString& windowName, int xPos, int yPos, int width, int height, int zIndex, const QString& operatorUser);
    bool updateWindow(int windowId, const QString& windowName, int xPos, int yPos, int width, int height, int zIndex, const QString& operatorUser);
    bool deleteWindow(int windowId, const QString& operatorUser);
    std::optional<LEDDB::WindowView> getWindowById(int windowId);
    QList<LEDDB::WindowView> getWindowsByProgram(int programId);

    // 素材操作
    bool addMedia(int windowId, const QString& filePath, const QString& fileType, double duration, int mediaSort, const QString& operatorUser);
    bool updateMedia(int mediaId, const QString& filePath, const QString& fileType, double duration, int mediaSort, const QString& operatorUser);
    bool deleteMedia(int mediaId, const QString& operatorUser);
    bool reorderMedia(int windowId, const QList<int>& mediaIds, const QString& operatorUser);
    std::optional<LEDDB::MediaSource> getMediaById(int mediaId);
    QList<LEDDB::MediaSource> getMediaByWindow(int windowId);


};

#endif // BUSINESSCONTROLLER_H