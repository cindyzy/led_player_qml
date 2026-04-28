#ifndef DATETIMEHELPER_H
#define DATETIMEHELPER_H
// utils/datetimehelper.h
#pragma once
#include <QDateTime>
#include <QString>

inline QString toIsoString(const QDateTime& dt) {
    return dt.isValid() ? dt.toString(Qt::ISODateWithMs) : QString();
}

inline QDateTime fromIsoString(const QString& str) {
    return QDateTime::fromString(str, Qt::ISODateWithMs);
}
#endif // DATETIMEHELPER_H
