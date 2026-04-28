#ifndef CRYPTOHELPER_H
#define CRYPTOHELPER_H
// utils/cryptohelper.h
#pragma once
#include <QByteArray>
#include <QString>

class CryptoHelper {
public:
    static QByteArray aesEncrypt(const QString& plain, const QByteArray& key = defaultKey());
    static QString aesDecrypt(const QByteArray& cipher, const QByteArray& key = defaultKey());
    static void setKey(const QByteArray& key); // 可选，从配置加载
private:
    static QByteArray defaultKey();
    static QByteArray m_key;
};

#endif // CRYPTOHELPER_H
