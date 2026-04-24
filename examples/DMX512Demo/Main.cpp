// main.cpp
#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include "dmxcontroller.h"

int main(int argc, char *argv[])
{
    // QGuiApplication app(argc, argv);
    // app.setOrganizationName("DMX512Demo");
    // app.setApplicationName("LEDController");

    // qmlRegisterType<DMXController>("DMX512LEDController", 1, 0, "DMXController");

    // QQmlApplicationEngine engine;
    // engine.load(QUrl(QStringLiteral("qrc:/DMX512LEDController/Main.qml")));

    // if (engine.rootObjects().isEmpty())
    //     return -1;

    // return app.exec();
    QGuiApplication app(argc, argv);
    app.setOrganizationName("DMX512Demo");
    app.setApplicationName("LEDController");

    qmlRegisterType<DMXController>("DMX512LEDController", 1, 0, "DMXController");

    QQmlApplicationEngine engine;
    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);
    engine.loadFromModule("DMX512Demo", "Main");

    return QCoreApplication::exec();
}