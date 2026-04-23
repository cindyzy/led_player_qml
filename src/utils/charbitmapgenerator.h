#ifndef CHARBITMAPGENERATOR_H
#define CHARBITMAPGENERATOR_H

#include <QObject>
#include <QImage>
#include <QFont>
#include <QPainter>
#include <QMap>
#include <QColor>
#include <QMutex>
#include <QMutexLocker>
#include <QDir>
#include <QFileInfo>
#include <QDebug>
#include <QRegularExpression>  // 添加QRegularExpression头文件

class CharBitmapGenerator : public QObject
{
    Q_OBJECT

    Q_PROPERTY(int charWidth MEMBER m_charWidth NOTIFY charWidthChanged)
    Q_PROPERTY(int charHeight MEMBER m_charHeight NOTIFY charHeightChanged)
    Q_PROPERTY(bool enableAntialiasing MEMBER m_enableAntialiasing NOTIFY antialiasingChanged)
    Q_PROPERTY(int threshold MEMBER m_threshold NOTIFY thresholdChanged)
    Q_PROPERTY(bool enableDebug MEMBER m_enableDebug NOTIFY debugChanged)
    Q_PROPERTY(QString debugPath MEMBER m_debugPath NOTIFY debugPathChanged)

public:
    explicit CharBitmapGenerator(QObject *parent = nullptr);
    ~CharBitmapGenerator();

    // 生成字符点阵
    Q_INVOKABLE QVariantList getCharBitmap(const QString& text,
                                           int fontSize,
                                           const QString& fontFamily);

    // 批量生成字符点阵
    Q_INVOKABLE QVariantList getTextBitmap(const QString& text,
                                           int fontSize,
                                           const QString& fontFamily);

    // 清理缓存
    Q_INVOKABLE void clearCache();

    // 获取缓存统计
    Q_INVOKABLE QVariantMap getCacheStats() const;

    // 启用/禁用调试模式
    Q_INVOKABLE void setDebugEnabled(bool enabled);

    // 设置调试图片保存路径
    Q_INVOKABLE void setDebugPath(const QString& path);

    // 获取最后一次生成的图片
    Q_INVOKABLE QVariant getLastGeneratedImage() const;

signals:
    void charWidthChanged();
    void charHeightChanged();
    void antialiasingChanged();
    void thresholdChanged();
    void debugChanged();
    void debugPathChanged();
    void cacheCleared();
    void bitmapGenerated(const QString& cacheKey, const QVariantList& bitmap);
    void debugImageSaved(const QString& filePath);
    void renderError(const QString& errorMessage);

private:
    // 内部渲染函数
    QVariantList renderCharBitmap(QChar ch, int fontSize, const QString& fontFamily);

    // 计算单元格的平均亮度
    float calculateCellBrightness(const QImage& image,
                                  int cellX, int cellY,
                                  int cellWidth, int cellHeight) const;

    // 生成缓存键
    QString generateCacheKey(QChar ch, int fontSize, const QString& fontFamily) const;

    // 保存调试图片
    bool saveDebugImage(const QImage& image,
                        QChar ch,
                        int fontSize,
                        const QString& fontFamily);

    // 保存点阵预览图片
    bool saveBitmapPreviewImage(const QVariantList& bitmap,
                                QChar ch,
                                int fontSize,
                                const QString& fontFamily);

    // 检查并创建调试目录
    bool ensureDebugDirectory() const;

private:
    int m_charWidth = 16;
    int m_charHeight = 16;
    bool m_enableAntialiasing = true;
    int m_threshold = 30;  // 亮度阈值
    bool m_enableDebug = false;  // 是否启用调试模式
    QString m_debugPath = "./debug_images";  // 调试图片保存路径

    QMap<QString, QVariantList> m_bitmapCache;
    mutable QMutex m_cacheMutex;

    // 渲染参数
    int m_canvasScaleFactor = 4;  // 画布缩放因子，提高渲染精度

    // 最后一次生成的图片
    QImage m_lastGeneratedImage;
};
#endif // CHARBITMAPGENERATOR_H
