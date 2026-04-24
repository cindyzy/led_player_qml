#ifndef FILEHANDLER_H
#define FILEHANDLER_H
// FileHandler.h
#include <QObject>
#include <QFile>
#include <QTextStream>

class FileHandler : public QObject {
    Q_OBJECT

public slots:
    bool writeTextFile(const QString& filePath, const QString& content) {
        QFile file(filePath);
        if (file.open(QIODevice::WriteOnly | QIODevice::Text)) {
            QTextStream out(&file);
            out << content;
            file.close();
            return true;
        }
        return false;
    }
};
#endif // FILEHANDLER_H
