// CharBitmapGenerator QML 包装器
// 这是一个QML单例，用于包装C++ CharBitmapGenerator类
pragma Singleton
import QtQuick
import QtQml
import LedPlayer 1.0

QtObject {
    id: root

    // 属性接口 - 与C++类属性保持一致
    property int charWidth: 16
    property int charHeight: 16
    property bool enableAntialiasing: true
    property int threshold: 30

    // 渲染参数
    property int canvasScaleFactor: 4

    // 内部引用C++对象
    property var cppGenerator: null

    // 缓存统计
    property var cacheStats: ({})

    // 状态
    property bool isInitialized: false
    property bool cppAvailable: false
    property string status: "未初始化"

    // 信号
    // signal charWidthChanged()
    // signal charHeightChanged()
    signal antialiasingChanged()
    // signal thresholdChanged()
    signal cacheCleared()
    signal bitmapGenerated(string cacheKey, var bitmap)
    signal initialized()
    signal errorOccurred(string errorMessage)

    // 初始化C++组件
    function initialize() {
        if (isInitialized) {
            return;
        }

        console.log("正在初始化CharBitmapGenerator...");
        status = "初始化中";

        try {
            // 尝试创建C++对象
            cppGenerator = Qt.createQmlObject(
                'import LedPlayer 1.0; CharBitmapGenerator { }',
                root,
                "charBitmapGeneratorCpp"
            );

            if (cppGenerator) {
                cppAvailable = true;
                console.log("C++ CharBitmapGenerator 创建成功");

                // 连接信号
                cppGenerator.charWidthChanged.connect(function() {
                    charWidth = cppGenerator.charWidth;
                    charWidthChanged();
                });

                cppGenerator.charHeightChanged.connect(function() {
                    charHeight = cppGenerator.charHeight;
                    charHeightChanged();
                });

                cppGenerator.antialiasingChanged.connect(function() {
                    enableAntialiasing = cppGenerator.enableAntialiasing;
                    antialiasingChanged();
                });

                cppGenerator.thresholdChanged.connect(function() {
                    threshold = cppGenerator.threshold;
                    thresholdChanged();
                });

                cppGenerator.cacheCleared.connect(function() {
                    cacheCleared();
                });

                cppGenerator.bitmapGenerated.connect(function(cacheKey, bitmap) {
                    bitmapGenerated(cacheKey, bitmap);
                });

                // 同步初始属性
                charWidth = cppGenerator.charWidth;
                charHeight = cppGenerator.charHeight;
                enableAntialiasing = cppGenerator.enableAntialiasing;
                threshold = cppGenerator.threshold;

                isInitialized = true;
                status = "已初始化 (C++模式)";
                console.log("CharBitmapGenerator 初始化完成 (C++模式)");
            } else {
                throw new Error("无法创建C++对象");
            }
        } catch (error) {
            console.warn("C++ CharBitmapGenerator 初始化失败:", error.message);
            console.warn("将使用纯QML实现");

            // 使用纯QML实现
            cppAvailable = false;
            isInitialized = true;
            status = "已初始化 (QML模式)";
        }

        initialized();
    }

    // 生成字符点阵 - 主函数
    function getCharBitmap(text, fontSize, fontFamily) {
        if (!isInitialized) {
            initialize();
        }

        if (!text || text.length === 0) {
            console.warn("getCharBitmap: 文本为空");
            return [];
        }

        var ch = text.charAt(0);
        console.log("生成字符点阵:", ch, "字体:", fontFamily, "大小:", fontSize);

        if (cppAvailable && cppGenerator) {
            try {
                // 使用C++实现
                var result = cppGenerator.getCharBitmap(text, fontSize, fontFamily);
                if (result && result.length > 0) {
                    console.log("C++生成字符点阵成功，尺寸:", result.length, "x", result[0]?.length || 0);
                    return result;
                } else {
                    console.warn("C++生成字符点阵返回空结果，将使用QML备用实现");
                }
            } catch (error) {
                console.error("C++生成字符点阵失败:", error);
                errorOccurred("C++生成字符点阵失败: " + error.message);
            }
        }

        // 使用QML备用实现
        return getCharBitmapQML(ch, fontSize, fontFamily);
    }

    // 批量生成字符点阵
    function getTextBitmap(text, fontSize, fontFamily) {
        if (!isInitialized) {
            initialize();
        }

        if (!text || text.length === 0) {
            console.warn("getTextBitmap: 文本为空");
            return [];
        }

        console.log("批量生成字符点阵，文本:", text, "长度:", text.length);

        if (cppAvailable && cppGenerator) {
            try {
                // 使用C++实现
                var result = cppGenerator.getTextBitmap(text, fontSize, fontFamily);
                if (result && result.length > 0) {
                    console.log("C++批量生成字符点阵成功，字符数:", result.length);
                    return result;
                } else {
                    console.warn("C++批量生成字符点阵返回空结果，将使用QML备用实现");
                }
            } catch (error) {
                console.error("C++批量生成字符点阵失败:", error);
                errorOccurred("C++批量生成字符点阵失败: " + error.message);
            }
        }

        // 使用QML备用实现
        var bitmaps = [];
        for (var i = 0; i < text.length; i++) {
            var bitmap = getCharBitmapQML(text.charAt(i), fontSize, fontFamily);
            bitmaps.push(bitmap);
        }
        return bitmaps;
    }

    // 纯QML实现的字符渲染
    function getCharBitmapQML(ledchar, fontSize, fontFamily) {
        console.log("使用QML渲染字符:", ledchar, "字体:", fontFamily, "大小:", fontSize);

        // 创建离屏Canvas
        var canvas = Qt.createQmlObject(
            'import QtQuick 2.15; Canvas { visible: false; }',
            root,
            "charCanvas_" + Date.now()
        );

        // 计算画布大小
        var canvasSize = Math.max(fontSize * canvasScaleFactor, 240);
        canvas.width = canvasSize;
        canvas.height = canvasSize;

        // 等待Canvas准备好
        try {
            var context = canvas.getContext("2d");
            if (!context) {
                console.warn("无法获取Canvas 2D上下文");
                canvas.destroy();
                return [];
            }

            // 黑色背景
            context.fillStyle = "#000000";
            context.fillRect(0, 0, canvasSize, canvasSize);

            // 白色文字
            context.fillStyle = "#FFFFFF";
            context.font = (enableAntialiasing ? "" : "bold ") + fontSize + "px '" + (fontFamily || "Arial") + "'";
            context.textAlign = "center";
            context.textBaseline = "middle";

            // 绘制字符
            context.fillText(ledchar, canvasSize / 2, canvasSize / 2);

            // 获取图像数据
            var imageData = context.getImageData(0, 0, canvasSize, canvasSize);
            var data = imageData.data;

            var cellW = canvasSize / charWidth;
            var cellH = canvasSize / charHeight;

            var bitmap = [];
            for (var row = 0; row < charHeight; row++) {
                var rowArray = [];
                for (var col = 0; col < charWidth; col++) {
                    var startX = col * cellW;
                    var endX = (col + 1) * cellW;
                    var startY = row * cellH;
                    var endY = (row + 1) * cellH;

                    var totalBrightness = 0;
                    var pixelCount = 0;
                    for (var py = Math.floor(startY); py < Math.ceil(endY); py++) {
                        for (var px = Math.floor(startX); px < Math.ceil(endX); px++) {
                            if (px >= 0 && px < canvasSize && py >= 0 && py < canvasSize) {
                                var idx = (py * canvasSize + px) * 4;
                                // 使用灰度值：(R*0.299 + G*0.587 + B*0.114)
                                var gray = data[idx] * 0.299 + data[idx + 1] * 0.587 + data[idx + 2] * 0.114;
                                totalBrightness += gray;
                                pixelCount++;
                            }
                        }
                    }
                    var avgBrightness = pixelCount > 0 ? totalBrightness / pixelCount : 0;
                    var isLit = avgBrightness > threshold;
                    rowArray.push(isLit ? 1 : 0);
                }
                bitmap.push(rowArray);
            }

            canvas.destroy();
            return bitmap;

        } catch (error) {
            console.error("QML渲染字符失败:", error);
            if (canvas) {
                canvas.destroy();
            }
            return [];
        }
    }

    // 清理缓存
    function clearCache() {
        if (cppAvailable && cppGenerator) {
            try {
                cppGenerator.clearCache();
            } catch (error) {
                console.error("C++清理缓存失败:", error);
            }
        }

        cacheStats = {};
        cacheCleared();
        console.log("字符点阵缓存已清理");
    }

    // 获取缓存统计
    function getCacheStats() {
        if (cppAvailable && cppGenerator) {
            try {
                var stats = cppGenerator.getCacheStats();
                cacheStats = stats;
                return stats;
            } catch (error) {
                console.error("获取C++缓存统计失败:", error);
            }
        }

        // 返回QML模式的默认统计
        var stats = {
            cacheSize: 0,
            charWidth: charWidth,
            charHeight: charHeight,
            threshold: threshold,
            antialiasing: enableAntialiasing,
            mode: cppAvailable ? "C++" : "QML"
        };

        cacheStats = stats;
        return stats;
    }

    // 设置属性
    function setCharWidth(width) {
        if (width <= 0) return;

        charWidth = width;
        if (cppAvailable && cppGenerator) {
            cppGenerator.charWidth = width;
        }
        charWidthChanged();
    }

    function setCharHeight(height) {
        if (height <= 0) return;

        charHeight = height;
        if (cppAvailable && cppGenerator) {
            cppGenerator.charHeight = height;
        }
        charHeightChanged();
    }

    function setEnableAntialiasing(antialiasing) {
        enableAntialiasing = antialiasing;
        if (cppAvailable && cppGenerator) {
            cppGenerator.enableAntialiasing = antialiasing;
        }
        antialiasingChanged();
    }

    function setThreshold(newThreshold) {
        if (newThreshold < 0 || newThreshold > 255) return;

        threshold = newThreshold;
        if (cppAvailable && cppGenerator) {
            cppGenerator.threshold = newThreshold;
        }
        thresholdChanged();
    }

    // 测试函数
    function testGeneration() {
        console.log("=== 测试字符点阵生成 ===");

        // 测试单个字符
        var charBitmap = getCharBitmap("A", 24, "Arial");
        if (charBitmap && charBitmap.length > 0) {
            console.log("字符'A'点阵生成成功，尺寸:", charBitmap.length, "x", charBitmap[0].length);

            // 打印前几行用于调试
            for (var i = 0; i < Math.min(3, charBitmap.length); i++) {
                console.log("行", i, ":", charBitmap[i].join(""));
            }
        } else {
            console.error("字符'A'点阵生成失败");
        }

        // 测试批量生成
        var textBitmaps = getTextBitmap("LED", 24, "Arial");
        if (textBitmaps && textBitmaps.length === 3) {
            console.log("批量生成成功，生成了", textBitmaps.length, "个字符点阵");
        }

        // 获取缓存统计
        var stats = getCacheStats();
        console.log("缓存统计:", JSON.stringify(stats));

        console.log("=== 测试完成 ===");
    }

    // 组件初始化
    Component.onCompleted: {
        console.log("CharBitmapGenerator QML包装器已创建");
        console.log("正在初始化...");

        // 延迟初始化，确保依赖已加载
        Qt.callLater(function() {
            initialize();

            // 初始化后自动测试
            Qt.callLater(function() {
                testGeneration();
            });
        });
    }

    // 组件销毁
    Component.onDestruction: {
        console.log("CharBitmapGenerator QML包装器销毁");
        if (cppGenerator) {
            cppGenerator.destroy();
        }
    }
}
