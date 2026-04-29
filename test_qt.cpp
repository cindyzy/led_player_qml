#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QDebug>

int main(int argc, char *argv[]) {
    qDebug() << "Starting Qt application...";
    
    QGuiApplication app(argc, argv);
    qDebug() << "QGuiApplication created successfully";
    
    QQmlApplicationEngine engine;
    qDebug() << "QQmlApplicationEngine created successfully";
    
    const QUrl url(u"qrc:/Main.qml"_qs);
    qDebug() << "Loading QML from:" << url;
    
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl) {
            qCritical() << "Failed to load QML file:" << url;
            QCoreApplication::exit(-1);
        } else if (obj) {
            qDebug() << "QML loaded successfully, root object created";
        }
    }, Qt::QueuedConnection);
    
    engine.load(url);
    qDebug() << "Engine load called";
    
    if (engine.rootObjects().isEmpty()) {
        qCritical() << "No root objects loaded!";
        return -1;
    }
    
    qDebug() << "Root objects count:" << engine.rootObjects().count();
    qDebug() << "Starting event loop...";
    
    return app.exec();
}