#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QIcon>
#include <QQmlContext>
#include <QDir>

int main(int argc, char *argv[])
{
    // 启用高DPI支持
    QGuiApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

    QGuiApplication app(argc, argv);

    // 设置应用程序元数据
    app.setOrganizationName("MyCompany");
    app.setApplicationName("LED Player");
    app.setApplicationVersion("1.0.0");
    app.setWindowIcon(QIcon(":/images/icon.png"));

    QQmlApplicationEngine engine;

    // 添加导入路径
    engine.addImportPath("qrc:/");

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
