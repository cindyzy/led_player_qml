#include "CharBitmapGenerator.h"
#include <QStandardPaths>
#include <QDateTime>
#include <QJsonDocument>
#include <QJsonArray>
#include <QJsonObject>
#include <QRegularExpression>
#include <QRectF>
#include <QPainterPath>

CharBitmapGenerator::CharBitmapGenerator(QObject *parent)
    : QObject(parent)
    , m_charWidth(16)
    , m_charHeight(16)
    , m_enableAntialiasing(true)
    , m_threshold(30)
    , m_enableDebug(false)
    , m_debugPath(QStandardPaths::writableLocation(QStandardPaths::AppDataLocation) + "/debug_images")
    , m_canvasScaleFactor(8)  // 增加缩放因子以提高精度
{
    qDebug() << "CharBitmapGenerator created";
    qDebug() << "Debug path:" << m_debugPath;

    // 确保调试目录存在
    ensureDebugDirectory();
}

CharBitmapGenerator::~CharBitmapGenerator()
{
    QMutexLocker locker(&m_cacheMutex);
    m_bitmapCache.clear();
    qDebug() << "CharBitmapGenerator destroyed";
}

QVariantList CharBitmapGenerator::getCharBitmap(const QString& text,
                                                int fontSize,
                                                const QString& fontFamily)
{
    if (text.isEmpty()) {
        emit renderError("Text is empty");
        return QVariantList();
    }


    QChar ch = text.at(0);
    QString cacheKey = generateCacheKey(ch, fontSize, fontFamily);

    {
        QMutexLocker locker(&m_cacheMutex);
        if (m_bitmapCache.contains(cacheKey)) {
            return m_bitmapCache[cacheKey];
        }
    }

    QVariantList bitmap = renderCharBitmap(ch, fontSize, fontFamily);

    {
        QMutexLocker locker(&m_cacheMutex);
        m_bitmapCache[cacheKey] = bitmap;
    }


    qDebug() << "Generated char bitmap for" << ch
              << "ms";

    emit bitmapGenerated(cacheKey, bitmap);

    // 如果启用了调试模式，保存点阵预览
    if (m_enableDebug && !bitmap.isEmpty()) {
        saveBitmapPreviewImage(bitmap, ch, fontSize, fontFamily);
    }

    return bitmap;
}

QVariantList CharBitmapGenerator::getTextBitmap(const QString& text,
                                                int fontSize,
                                                const QString& fontFamily)
{
    QVariantList result;

    for (int i = 0; i < text.length(); ++i) {
        QChar ch = text.at(i);
        QString cacheKey = generateCacheKey(ch, fontSize, fontFamily);

        QVariantList charBitmap;
        {
            QMutexLocker locker(&m_cacheMutex);
            if (m_bitmapCache.contains(cacheKey)) {
                charBitmap = m_bitmapCache[cacheKey];
            }
        }

        if (charBitmap.isEmpty()) {
            charBitmap = renderCharBitmap(ch, fontSize, fontFamily);
            {
                QMutexLocker locker(&m_cacheMutex);
                m_bitmapCache[cacheKey] = charBitmap;
            }
        }

        result.append(charBitmap);
    }

    return result;
}

void CharBitmapGenerator::clearCache()
{
    {
        QMutexLocker locker(&m_cacheMutex);
        m_bitmapCache.clear();
    }
    emit cacheCleared();
    qDebug() << "Bitmap cache cleared";
}

QVariantMap CharBitmapGenerator::getCacheStats() const
{
    QMutexLocker locker(&m_cacheMutex);
    QVariantMap stats;
    stats["cacheSize"] = m_bitmapCache.size();
    stats["charWidth"] = m_charWidth;
    stats["charHeight"] = m_charHeight;
    stats["threshold"] = m_threshold;
    stats["antialiasing"] = m_enableAntialiasing;
    stats["debugEnabled"] = m_enableDebug;
    stats["debugPath"] = m_debugPath;
    stats["canvasScaleFactor"] = m_canvasScaleFactor;
    return stats;
}

void CharBitmapGenerator::setDebugEnabled(bool enabled)
{
    if (m_enableDebug != enabled) {
        m_enableDebug = enabled;
        emit debugChanged();
        qDebug() << "Debug mode" << (enabled ? "enabled" : "disabled");

        if (enabled) {
            ensureDebugDirectory();
        }
    }
}

void CharBitmapGenerator::setDebugPath(const QString& path)
{
    if (m_debugPath != path) {
        m_debugPath = path;
        emit debugPathChanged();
        qDebug() << "Debug path set to:" << path;

        if (m_enableDebug) {
            ensureDebugDirectory();
        }
    }
}

QVariant CharBitmapGenerator::getLastGeneratedImage() const
{
    if (!m_lastGeneratedImage.isNull()) {
        return QVariant::fromValue(m_lastGeneratedImage);
    }
    return QVariant();
}

QVariantList CharBitmapGenerator::renderCharBitmap(QChar ch, int fontSize, const QString& fontFamily)
{

    // 计算画布大小，增加缩放因子提高精度
    int canvasWidth = m_charWidth * m_canvasScaleFactor;
    int canvasHeight = m_charHeight * m_canvasScaleFactor;

    // 创建画布
    QImage image(canvasWidth, canvasHeight, QImage::Format_ARGB32);
    image.fill(Qt::black);

    // 设置字体
    QFont font(fontFamily.isEmpty() ? "Arial" : fontFamily, fontSize);
    font.setStyleStrategy(m_enableAntialiasing ?
                              QFont::PreferAntialias :
                              QFont::NoAntialias);

    // 在画布上绘制字符
    QPainter painter(&image);
    painter.setRenderHint(QPainter::Antialiasing, m_enableAntialiasing);
    painter.setRenderHint(QPainter::TextAntialiasing, m_enableAntialiasing);
    painter.setRenderHint(QPainter::SmoothPixmapTransform, m_enableAntialiasing);

    painter.setFont(font);
    painter.setPen(Qt::white);

    // 测量文本大小 - 使用更准确的boundingRect
    QFontMetricsF metrics(font);
    QRectF boundingRect = metrics.boundingRect(ch);

    // 计算绘制位置 - 确保字符居中
    // 使用tightBoundingRect获取更精确的边界
    QRectF tightRect = metrics.tightBoundingRect(ch);

    // 如果tightRect无效，回退到boundingRect
    if (tightRect.isEmpty()) {
        tightRect = boundingRect;
    }

    // 计算居中位置
    qreal x = (canvasWidth - tightRect.width()) / 2.0 - tightRect.left();
    qreal y = (canvasHeight - tightRect.height()) / 2.0 - tightRect.top();

    // 绘制字符
    painter.drawText(QPointF(x, y), QString(ch));
    painter.end();

    // 保存最后一次生成的图片
    m_lastGeneratedImage = image.copy();

    // 调试：保存生成的图片
    if (m_enableDebug) {
        saveDebugImage(image, ch, fontSize, fontFamily);
    }

    // 计算每个单元格的大小
    qreal cellWidth = static_cast<qreal>(canvasWidth) / m_charWidth;
    qreal cellHeight = static_cast<qreal>(canvasHeight) / m_charHeight;

    QVariantList bitmap;

    // 对每个LED单元格进行采样
    for (int row = 0; row < m_charHeight; ++row) {
        QVariantList rowArray;
        for (int col = 0; col < m_charWidth; ++col) {
            float brightness = calculateCellBrightness(image,
                                                       col, row,
                                                       cellWidth, cellHeight);

            // 应用阈值判断是否点亮
            bool isLit = brightness > m_threshold;
            rowArray.append(isLit ? 1 : 0);
        }
        bitmap.append(QVariant(rowArray));
    }

    qDebug() << "Rendered char" << ch
             << "font:" << fontFamily << "size:" << fontSize
             << "tightRect:" << tightRect
             << "ms";

    return bitmap;
}

float CharBitmapGenerator::calculateCellBrightness(const QImage& image,
                                                   int cellX, int cellY,
                                                   qreal cellWidth, qreal cellHeight) const
{
    int startX = static_cast<int>(cellX * cellWidth);
    int endX = static_cast<int>((cellX + 1) * cellWidth);
    int startY = static_cast<int>(cellY * cellHeight);
    int endY = static_cast<int>((cellY + 1) * cellHeight);

    // 确保边界不超出图像
    startX = qMax(0, startX);
    endX = qMin(image.width(), endX);
    startY = qMax(0, startY);
    endY = qMin(image.height(), endY);

    float totalBrightness = 0;
    int pixelCount = 0;

    // 对单元格内的所有像素进行采样
    for (int y = startY; y < endY; ++y) {
        for (int x = startX; x < endX; ++x) {
            QRgb pixel = image.pixel(x, y);
            int brightness = qGray(pixel);
            totalBrightness += brightness;
            pixelCount++;
        }
    }

    if (pixelCount == 0) {
        return 0.0f;
    }

    return totalBrightness / pixelCount;
}

QString CharBitmapGenerator::generateCacheKey(QChar ch, int fontSize, const QString& fontFamily) const
{
    return QString("%1_%2_%3_%4x%5_%6")
    .arg(ch)
        .arg(fontFamily)
        .arg(fontSize)
        .arg(m_charWidth)
        .arg(m_charHeight)
        .arg(m_threshold);
}

bool CharBitmapGenerator::saveDebugImage(const QImage& image,
                                         QChar ch,
                                         int fontSize,
                                         const QString& fontFamily)
{
    if (!ensureDebugDirectory()) {
        qWarning() << "Cannot create debug directory:" << m_debugPath;
        return false;
    }

    // 生成文件名
    QString timestamp = QDateTime::currentDateTime().toString("yyyyMMdd_hhmmss_zzz");
    QString fileName = QString("char_%1_font%2_size%3_%4.png")
                           .arg(ch)
                           .arg(fontFamily)
                           .arg(fontSize)
                           .arg(timestamp);

    // 使用QRegularExpression替换文件名中的非法字符
    QRegularExpression illegalChars("[\\\\/:*?\"<>|]");
    fileName = fileName.replace(illegalChars, "_");

    QString filePath = m_debugPath + "/" + fileName;

    // 保存图片为PNG以保持透明度
    if (image.save(filePath, "PNG", 100)) {
        qDebug() << "Debug image saved to:" << filePath;
        emit debugImageSaved(filePath);

        // 同时保存一个JSON文件，记录图片信息
        QJsonObject info;
        info["character"] = QString(ch);
        info["unicode"] = QString("U+%1").arg(ch);
        info["fontFamily"] = fontFamily;
        info["fontSize"] = fontSize;
        info["charWidth"] = m_charWidth;
        info["charHeight"] = m_charHeight;
        info["threshold"] = m_threshold;
        info["antialiasing"] = m_enableAntialiasing;
        info["timestamp"] = timestamp;
        info["imagePath"] = filePath;
        info["imageSize"] = QString("%1x%2").arg(image.width()).arg(image.height());

        QJsonDocument doc(info);
        QString infoFilePath = filePath + ".json";
        QFile infoFile(infoFilePath);
        if (infoFile.open(QIODevice::WriteOnly)) {
            infoFile.write(doc.toJson());
            infoFile.close();
            qDebug() << "Image info saved to:" << infoFilePath;
        }

        return true;
    } else {
        qWarning() << "Failed to save debug image to:" << filePath;
        return false;
    }
}

bool CharBitmapGenerator::saveBitmapPreviewImage(const QVariantList& bitmap,
                                                 QChar ch,
                                                 int fontSize,
                                                 const QString& fontFamily)
{
    if (!ensureDebugDirectory()) {
        return false;
    }

    if (bitmap.isEmpty()) {
        return false;
    }

    // 计算预览图片大小
    int rows = bitmap.size();
    if (rows == 0) return false;

    int cols = 0;
    if (bitmap[0].canConvert<QVariantList>()) {
        cols = bitmap[0].toList().size();
    }

    if (cols == 0) return false;

    // 创建预览图片
    int cellSize = 20;  // 每个点阵单元格的像素大小
    int imageWidth = cols * cellSize;
    int imageHeight = rows * cellSize;

    QImage preview(imageWidth, imageHeight, QImage::Format_ARGB32);
    preview.fill(Qt::black);

    QPainter painter(&preview);
    painter.setPen(Qt::NoPen);

    // 绘制点阵
    for (int row = 0; row < rows; ++row) {
        QVariantList rowData = bitmap[row].toList();
        for (int col = 0; col < cols; ++col) {
            int x = col * cellSize;
            int y = row * cellSize;

            bool isLit = (col < rowData.size() && rowData[col].toInt() == 1);

            if (isLit) {
                // 点亮状态 - 红色
                painter.setBrush(QBrush(QColor(255, 50, 50, 255)));
                painter.drawRect(x, y, cellSize, cellSize);

                // 添加发光效果
                painter.setBrush(QBrush(QColor(255, 100, 100, 100)));
                painter.drawEllipse(x + cellSize/4, y + cellSize/4,
                                    cellSize/2, cellSize/2);
            } else {
                // 熄灭状态 - 深灰色
                painter.setBrush(QBrush(QColor(50, 50, 50, 255)));
                painter.drawRect(x, y, cellSize, cellSize);
            }

            // 绘制网格线
            painter.setPen(QPen(QColor(100, 100, 100, 100), 1));
            painter.drawRect(x, y, cellSize, cellSize);
            painter.setPen(Qt::NoPen);
        }
    }

    // 添加标题
    painter.setPen(Qt::white);
    painter.setFont(QFont("Arial", 10));
    painter.drawText(5, 15, QString("Char: %1 (U+%2) Font: %3 Size: %4")
                                .arg(ch)
                                .arg(ch)
                                .arg(fontFamily)
                                .arg(fontSize));

    painter.end();

    // 保存预览图片
    QString timestamp = QDateTime::currentDateTime().toString("yyyyMMdd_hhmmss_zzz");
    QString fileName = QString("preview_%1_font%2_size%3_%4.png")
                           .arg(ch)
                           .arg(fontFamily)
                           .arg(fontSize)
                           .arg(timestamp);

    // 使用QRegularExpression替换文件名中的非法字符
    QRegularExpression illegalChars("[\\\\/:*?\"<>|]");
    fileName = fileName.replace(illegalChars, "_");

    QString filePath = m_debugPath + "/" + fileName;

    if (preview.save(filePath, "PNG", 100)) {
        qDebug() << "Bitmap preview saved to:" << filePath;
        return true;
    }

    return false;
}

bool CharBitmapGenerator::ensureDebugDirectory() const
{
    QDir dir(m_debugPath);
    if (!dir.exists()) {
        return dir.mkpath(".");
    }
    return true;
}
