#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QIcon>
#include <QQmlContext>
#include <QDir>
#include "../utils/charbitmapgenerator.h"

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
    QQmlApplicationEngine engine;
    // 创建并暴露全局实例
    CharBitmapGenerator* charGenerator = new CharBitmapGenerator(&app);

    // 启用调试模式
    charGenerator->setDebugEnabled(true);

    // 设置自定义调试路径
    QString debugPath = QStandardPaths::writableLocation(QStandardPaths::DesktopLocation) + "/CharBitmapDebug";
    charGenerator->setDebugPath(debugPath);

    // // 打印初始状态
    // qDebug() << "=== CharBitmapGenerator Test (Qt6 Compatible) ===";
    // qDebug() << "Debug path:" << debugPath;
    // qDebug() << "Qt version:" << qVersion();

    // // 测试不同的字符
    // QStringList testCharacters = {"A", "B", "C", "L", "E", "D", "中", "文"};
    // QStringList testFonts = {"Arial", "Times New Roman", "Microsoft YaHei"};
    // QList<int> testSizes = {12, 24, 36, 48};

    // int testCount = 0;
    // int successCount = 0;

    // for (const QString& ch : testCharacters) {
    //     for (const QString& font : testFonts) {
    //         for (int size : testSizes) {
    //             testCount++;

    //             qDebug() << "\nTest" << testCount << ":";
    //             qDebug() << "  Character:" << ch;
    //             qDebug() << "  Font:" << font;
    //             qDebug() << "  Size:" << size;

    //             QElapsedTimer timer;
    //             timer.start();

    //             // 生成字符点阵
    //             QVariantList bitmap = charGenerator->getCharBitmap(ch, size, font);

    //             qint64 elapsed = timer.nsecsElapsed();

    //             if (!bitmap.isEmpty()) {
    //                 successCount++;

    //                 // 获取点阵尺寸
    //                 int rows = bitmap.size();
    //                 int cols = 0;
    //                 if (rows > 0 && bitmap[0].canConvert<QVariantList>()) {
    //                     cols = bitmap[0].toList().size();
    //                 }

    //                 qDebug() << "  Result: SUCCESS";
    //                 qDebug() << "  Bitmap size:" << rows << "x" << cols;
    //                 qDebug() << "  Time:" << (elapsed / 1000000.0) << "ms";

    //                 // 打印前几行点阵（用于调试）
    //                 int printRows = qMin(5, rows);
    //                 int printCols = qMin(10, cols);

    //                 qDebug() << "  Preview (first" << printRows << "rows," << printCols << "cols):";
    //                 for (int r = 0; r < printRows; r++) {
    //                     QString rowStr;
    //                     QVariantList rowData = bitmap[r].toList();
    //                     for (int c = 0; c < printCols; c++) {
    //                         if (c < rowData.size()) {
    //                             rowStr += (rowData[c].toInt() == 1) ? "█" : "░";
    //                         } else {
    //                             rowStr += "?";
    //                         }
    //                     }
    //                     qDebug() << "    " << rowStr;
    //                 }
    //             } else {
    //                 qDebug() << "  Result: FAILED - Empty bitmap";
    //             }

    //             // 防止过快连续测试
    //             QThread::msleep(100);
    //         }
    //     }
    // }

    // // 获取缓存统计
    // QVariantMap stats = charGenerator->getCacheStats();
    // qDebug() << "\n=== Test Summary ===";
    // qDebug() << "Total tests:" << testCount;
    // qDebug() << "Successful:" << successCount;
    // qDebug() << "Failed:" << (testCount - successCount);
    // qDebug() << "Cache size:" << stats["cacheSize"].toInt();
    // qDebug() << "Debug path:" << stats["debugPath"].toString();

    // // 清理缓存
    // charGenerator->clearCache();

    // // 重新获取统计
    // stats = charGenerator->getCacheStats();
    // qDebug() << "Cache size after clear:" << stats["cacheSize"].toInt();

    // qDebug() << "\n=== Additional Tests ===";

    // // 测试批量生成
    // qDebug() << "\nTesting batch generation:";
    // QVariantList batchResult = charGenerator->getTextBitmap("LED", 24, "Arial");
    // qDebug() << "Batch result count:" << batchResult.size();

    // // 测试不存在的字体
    // qDebug() << "\nTesting non-existent font:";
    // QVariantList nonExistent = charGenerator->getCharBitmap("X", 24, "NonExistentFont123");
    // if (nonExistent.isEmpty()) {
    //     qDebug() << "Correctly returned empty for non-existent font";
    // } else {
    //     qDebug() << "Unexpectedly got result for non-existent font";
    // }

    // // 测试空文本
    // qDebug() << "\nTesting empty text:";
    // QVariantList empty = charGenerator->getCharBitmap("", 24, "Arial");
    // qDebug() << "Empty text result is empty:" << empty.isEmpty();

    // // 测试特殊字符
    // qDebug() << "\nTesting special characters:";
    // QVariantList special1 = charGenerator->getCharBitmap("@", 24, "Arial");
    // qDebug() << "Special char '@' result:" << (!special1.isEmpty() ? "SUCCESS" : "FAILED");

    // QVariantList special2 = charGenerator->getCharBitmap("#", 24, "Arial");
    // qDebug() << "Special char '#' result:" << (!special2.isEmpty() ? "SUCCESS" : "FAILED");

    // qDebug() << "\n=== Test Complete ===";
    // qDebug() << "All debug images saved to:" << debugPath;




    engine.rootContext()->setContextProperty("charBitmapGenerator", charGenerator);

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
