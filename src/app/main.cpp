#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QIcon>
#include <QQmlContext>
#include <QDir>
#include <QQuickStyle>
#include "../utils/charbitmapgenerator.h"
#include "../utils/filehelper.h"
#include "../core/models/PlaylistTreeModel.h"
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

    // 创建 PlaylistTreeModel 实例并设置 BusinessController
    PlaylistTreeModel* playlistTreeModel = new PlaylistTreeModel(&engine);
    playlistTreeModel->setBusinessController(businessController);
    engine.rootContext()->setContextProperty("playlistTreeModel", playlistTreeModel);

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
