// utils/cryptohelper.cpp
#include "cryptohelper.h"
#include <QCryptographicHash>
#include <QDebug>
// 实际应链接 OpenSSL 或使用 Qt 自带的 SimpleCrypt，这里仅为示意
static QByteArray makeKey() {
    return QCryptographicHash::hash("LEDControl2026SecretKey", QCryptographicHash::Sha256);
}
QByteArray CryptoHelper::defaultKey() {
    static QByteArray key = makeKey();
    return key;
}
// 以下为伪实现，实际需替换为真实 AES
QByteArray CryptoHelper::aesEncrypt(const QString& plain, const QByteArray& key) {
    Q_UNUSED(key);
    return plain.toUtf8().toBase64(); // 仅示例，不安全
}
QString CryptoHelper::aesDecrypt(const QByteArray& cipher, const QByteArray& key) {
    Q_UNUSED(key);
    return QString::fromUtf8(QByteArray::fromBase64(cipher));
}