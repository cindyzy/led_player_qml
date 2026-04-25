#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QIcon>
#include <QQmlContext>
#include <QDir>
#include "../utils/charbitmapgenerator.h"
#include "../utils/filehelper.h"
#include "../core/models/PlaylistTreeModel.h"
#include <QQmlContext>
#include <QDebug>
#include <QStandardPaths>
#include <QElapsedTimer>
#include <QThread>
#include <QRegularExpression>  // 添加QRegularExpression头文件
int main(int argc, char *argv[])
{
    // 启用高DPI支持
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QCoreApplication::setAttribute(Qt::AA_UseHighDpiPixmaps);
    QGuiApplication app(argc, argv);

    // 设置应用程序元数据
    app.setOrganizationName("MyCompany");
    app.setApplicationName("LED Player");
    app.setApplicationVersion("1.0.0");
    app.setWindowIcon(QIcon(":/images/icon.png"));
    // 注册C++组件
    qmlRegisterType<CharBitmapGenerator>("LedPlayer", 1, 0, "CharBitmapGenerator");
    qmlRegisterType<FileHelper>("LedPlayer", 1, 0, "FileHelper");
    qmlRegisterType<PlaylistTreeModel>("LedPlayer", 1, 0, "PlaylistTreeModel");

    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty("fileHelper", new FileHelper(&engine));
    // 创建并暴露全局实例
    // CharBitmapGenerator* charGenerator = new CharBitmapGenerator(&app);

    // // 启用调试模式
    // charGenerator->setDebugEnabled(true);

    // // 设置自定义调试路径
    // QString debugPath = QStandardPaths::writableLocation(QStandardPaths::DesktopLocation) + "/CharBitmapDebug";
    // charGenerator->setDebugPath(debugPath);

    // engine.rootContext()->setContextProperty("charBitmapGenerator", charGenerator);

    // // 添加导入路径
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
