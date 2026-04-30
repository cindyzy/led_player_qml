#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QIcon>
#include <QQmlContext>
#include <QDir>
#include <QQuickStyle>
#include "../utils/charbitmapgenerator.h"
#include "../utils/filehelper.h"
#include "../core/models/PlaylistTreeModel.h"
#include "../core/models/entity/UserModel.h"
#include "../core/models/entity/RoleModel.h"
#include "../core/models/entity/PermissionModel.h"
#include "../core/models/entity/LedDeviceModel.h"
#include "../core/models/entity/ProjectConfigModel.h"
#include "../core/models/entity/PlayListModel.h"
#include "../core/models/entity/ProgramInfoModel.h"
#include "../core/models/entity/WindowViewModel.h"
#include "../core/models/entity/MediaSourceModel.h"
#include "../core/models/entity/ScheduleParamModel.h"
#include "../core/models/entity/AiModelConfigModel.h"
#include "../core/models/entity/SceneStatisticModel.h"
#include "../core/models/entity/AuditLogModel.h"
#include <QQmlContext>
#include <QDebug>
#include <QStandardPaths>
#include <QElapsedTimer>
#include <QThread>
#include <QRegularExpression>  // 添加QRegularExpression头文件
#include "../business/businesscontroller.h"
int main(int argc, char *argv[])
{
    // 启用高DPI支持
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QCoreApplication::setAttribute(Qt::AA_UseHighDpiPixmaps);
    QGuiApplication app(argc, argv);

    // 设置Qt Quick Controls 2样式
    // QQuickStyle::setStyle("Basic");

    // 设置应用程序元数据
    app.setOrganizationName("MyCompany");
    app.setApplicationName("LED Player");
    app.setApplicationVersion("1.0.0");
    // app.setWindowIcon(QIcon(":/images/icon.png")); // 图标文件暂不存在
    // 注册C++组件
    qmlRegisterType<CharBitmapGenerator>("LedPlayer", 1, 0, "CharBitmapGenerator");
    qmlRegisterType<FileHelper>("LedPlayer", 1, 0, "FileHelper");
    qmlRegisterType<PlaylistTreeModel>("LedPlayer", 1, 0, "PlaylistTreeModel");
    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty("fileHelper", new FileHelper(&engine));

    // 创建 BusinessController 实例
    BusinessController* businessController = new BusinessController(&engine);
    if (!businessController->init()) {
        qCritical() << "Failed to initialize BusinessController";
        return -1;
    }
    engine.rootContext()->setContextProperty("businessController", businessController);

    // ==================== 用户管理功能演示 ====================
    // 1. 检查是否存在管理员角色，不存在则创建
    const QString adminUsername = "admin";
    const QString adminPassword = "admin123";
    const QString adminRoleName = "管理员";

    int adminRoleId = 0;
    auto adminRole = businessController->getRoleByName(adminRoleName);
    if (!adminRole.has_value()) {
        qInfo() << "管理员角色不存在，正在创建...";
        bool roleCreated = businessController->createRole(adminRoleName, "管理员用户拥有所有权限", "system");
        if (roleCreated) {
            qInfo() << "管理员角色创建成功";
            auto newRole = businessController->getRoleByName(adminRoleName);
            if (newRole.has_value()) {
                adminRoleId = newRole->roleId();
            }
        }
    } else {
        adminRoleId = adminRole->roleId();
        qInfo() << "管理员角色已存在，roleId:" << adminRoleId;
    }

    // 2. 检查是否存在管理员用户，不存在则创建
    auto existingUser = businessController->getUserByName(adminUsername);
    if (!existingUser.has_value()) {
        qInfo() << "管理员用户不存在，正在创建默认管理员...";
        bool createSuccess = businessController->createUser(adminUsername, adminPassword, adminRoleId, "system");
        if (createSuccess) {
            qInfo() << "默认管理员创建成功: " << adminUsername << " with roleId:" << adminRoleId;
        } else {
            qWarning() << "创建默认管理员失败";
        }
    } else {
        qInfo() << "管理员用户已存在: " << adminUsername;
    }

    // 2. 演示用户登录验证功能
    qInfo() << "\n=== 登录验证演示 ===";
    bool loginSuccess = businessController->login(adminUsername, adminPassword);
    if (loginSuccess) {
        qInfo() << "登录成功！欢迎, " << adminUsername;
    } else {
        qInfo() << "登录失败！用户名或密码错误";
    }

    // 3. 演示错误密码登录
    bool failedLogin = businessController->login(adminUsername, "wrongpassword");
    if (!failedLogin) {
        qInfo() << "错误密码验证: 登录失败（预期行为）";
    }

    // 创建 PlaylistTreeModel 实例并设置 BusinessController
    PlaylistTreeModel* playlistTreeModel = new PlaylistTreeModel(&engine);
    playlistTreeModel->setBusinessController(businessController);
    engine.rootContext()->setContextProperty("playlistTreeModel", playlistTreeModel);

    // 创建所有 entity Model 实例并设置 BusinessController
    UserModel* userModel = new UserModel(&engine);
    userModel->setBusinessController(businessController);
    engine.rootContext()->setContextProperty("userModel", userModel);

    RoleModel* roleModel = new RoleModel(&engine);
    roleModel->setBusinessController(businessController);
    engine.rootContext()->setContextProperty("roleModel", roleModel);

    PermissionModel* permissionModel = new PermissionModel(&engine);
    permissionModel->setBusinessController(businessController);
    engine.rootContext()->setContextProperty("permissionModel", permissionModel);

    LedDeviceModel* ledDeviceModel = new LedDeviceModel(&engine);
    ledDeviceModel->setBusinessController(businessController);
    engine.rootContext()->setContextProperty("ledDeviceModel", ledDeviceModel);

    ProjectConfigModel* projectConfigModel = new ProjectConfigModel(&engine);
    projectConfigModel->setBusinessController(businessController);
    engine.rootContext()->setContextProperty("projectConfigModel", projectConfigModel);

    PlayListModel* playListModel = new PlayListModel(&engine);
    playListModel->setBusinessController(businessController);
    engine.rootContext()->setContextProperty("playListModel", playListModel);

    ProgramInfoModel* programInfoModel = new ProgramInfoModel(&engine);
    programInfoModel->setBusinessController(businessController);
    engine.rootContext()->setContextProperty("programInfoModel", programInfoModel);

    WindowViewModel* windowViewModel = new WindowViewModel(&engine);
    windowViewModel->setBusinessController(businessController);
    engine.rootContext()->setContextProperty("windowViewModel", windowViewModel);

    MediaSourceModel* mediaSourceModel = new MediaSourceModel(&engine);
    mediaSourceModel->setBusinessController(businessController);
    engine.rootContext()->setContextProperty("mediaSourceModel", mediaSourceModel);

    ScheduleParamModel* scheduleParamModel = new ScheduleParamModel(&engine);
    scheduleParamModel->setBusinessController(businessController);
    engine.rootContext()->setContextProperty("scheduleParamModel", scheduleParamModel);

    AiModelConfigModel* aiModelConfigModel = new AiModelConfigModel(&engine);
    aiModelConfigModel->setBusinessController(businessController);
    engine.rootContext()->setContextProperty("aiModelConfigModel", aiModelConfigModel);

    SceneStatisticModel* sceneStatisticModel = new SceneStatisticModel(&engine);
    sceneStatisticModel->setBusinessController(businessController);
    engine.rootContext()->setContextProperty("sceneStatisticModel", sceneStatisticModel);

    AuditLogModel* auditLogModel = new AuditLogModel(&engine);
    auditLogModel->setBusinessController(businessController);
    engine.rootContext()->setContextProperty("auditLogModel", auditLogModel);

    // 添加qrc资源路径
    engine.addImportPath("qrc:/");
    engine.addImportPath("qrc:/qml");
    engine.addImportPath("qrc:/qml/utils");


    // 设置QML文件路径
    const QUrl mainQmlUrl(QStringLiteral("qrc:/Main.qml"));

    // 检查QML文件是否存在
    qDebug() << "Loading QML from:" << mainQmlUrl;

    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [mainQmlUrl](QObject *obj, const QUrl &objUrl) {
                         if (!obj && mainQmlUrl == objUrl) {
                             qCritical() << "Failed to load QML file:" << mainQmlUrl;
                             QCoreApplication::exit(-1);
                         } else if (obj) {
                             qDebug() << "QML loaded successfully";
                         }
                     }, Qt::QueuedConnection);

    // 加载QML文件
    engine.load(mainQmlUrl);

    if (engine.rootObjects().isEmpty()) {
        qCritical() << "No QML root objects loaded";
        return -1;
    }

    return app.exec();
}
