#include "filehelper.h"
#include <QFile>
#include <QDir>
#include <QTextStream>

FileHelper::FileHelper(QObject *parent) : QObject(parent) {}

QString FileHelper::saveTextFile(const QString &filePath, const QString &content)
{
    QFile file(filePath);
    if (!file.open(QIODevice::WriteOnly | QIODevice::Text)) {
        return file.errorString();
    }
    QTextStream out(&file);
    out << content;
    file.close();
    return QString(); // 成功，返回空字符串
}

QString FileHelper::readTextFile(const QString &filePath)
{
    QFile file(filePath);
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        return QString(); // 也可返回空，但更好的做法是返回错误信息，让调用者区分空文件和错误
        // 建议改为返回 QVariantMap 但为了简单，这里返回空表示失败
    }
    QTextStream in(&file);
    return in.readAll();
}

QString FileHelper::ensureDirectoryExists(const QString &dirPath)
{
    QDir dir(dirPath);
    if (dir.exists())
        return QString();
    if (dir.mkpath("."))
        return QString();
    return QString("无法创建目录: %1").arg(dirPath);
}