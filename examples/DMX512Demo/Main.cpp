#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include "UdpManager.h"

int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QGuiApplication app(argc, argv);

    qmlRegisterType<UdpManager>("ArtNet", 1, 0, "UdpManager");

    // QQmlApplicationEngine engine;
    // engine.load(QUrl(QStringLiteral("qrc:/main.qml")));
    // if (engine.rootObjects().isEmpty())
    //     return -1;
    QQmlApplicationEngine engine;
    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);
    engine.loadFromModule("DMX512Demo", "Main");
    return app.exec();
}