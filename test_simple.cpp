#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQuickWindow>
#include <QDebug>

int main(int argc, char *argv[]) {
    qDebug() << "[TEST] Starting Qt application...";
    
    QGuiApplication app(argc, argv);
    qDebug() << "[TEST] QGuiApplication created";
    
    QQmlApplicationEngine engine;
    qDebug() << "[TEST] QQmlApplicationEngine created";
    
    // 创建简单的QML字符串
    const QString qmlSource = R"(
        import QtQuick
        import QtQuick.Controls
        
        ApplicationWindow {
            visible: true
            width: 400
            height: 300
            title: "Test Window"
            
            Text {
                text: "Hello World!"
                anchors.centerIn: parent
                font.pixelSize: 24
            }
        }
    )";
    
    qDebug() << "[TEST] Loading QML from string...";
    engine.loadData(qmlSource.toUtf8());
    
    if (engine.rootObjects().isEmpty()) {
        qCritical() << "[TEST] No root objects loaded!";
        foreach (const QQmlError &error, engine.errors()) {
            qCritical() << "[TEST] QML Error:" << error.toString();
        }
        return -1;
    }
    
    qDebug() << "[TEST] Root objects loaded successfully";
    qDebug() << "[TEST] Starting event loop...";
    
    return app.exec();
}