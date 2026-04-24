#ifndef FILEHELPER_H
#define FILEHELPER_H

#include <QObject>
#include <QString>

class FileHelper : public QObject
{
    Q_OBJECT
public:
    explicit FileHelper(QObject *parent = nullptr);

    // 返回空字符串表示成功，否则返回错误信息
    Q_INVOKABLE QString saveTextFile(const QString &filePath, const QString &content);
    Q_INVOKABLE QString readTextFile(const QString &filePath);
    Q_INVOKABLE QString ensureDirectoryExists(const QString &dirPath);
};

#endif // FILEHELPER_H