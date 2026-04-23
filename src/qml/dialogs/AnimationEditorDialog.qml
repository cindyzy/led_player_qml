// LED动画编辑器优化版 - 完整集成CharBitmapGenerator
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs
import QtQuick.Window
// import LedPlayer 1.0
import "../components/animationEditor"

Window {
    id: animationEditorDialog
    title: "LED动画编辑器"
    width: 1200
    height: 800
    flags: Qt.Dialog

    // 属性接口
    property var currentAnimation: {
        "properties": {
            "name": "新建动画",
            "duration": 10.0,
            "fps": 30
        },
        "textProperties": {
            "text": "LED文字效果",
            "gridWidth": 16,
            "gridHeight": 8,
            "ledSize": "70%",
            "brightness": "高",
            "fontName": "宋体",
            "fontSize": 54,
            "materialName": "LED文字效果"
        },
        "colorSettings": {
            "useGradient": false,
            "textColor": "#FF0000",
            "gradientStops": [
                {color: "#FF0000", position: 0.0},
                {color: "#FFFF00", position: 0.5},
                {color: "#00FF00", position: 1.0}
            ],
            "selectedTemplate": "模板1"
        },
        "gradients": [],
        "selectedItem": null
    }

    // 滚动属性
    property bool dragging: false
    property point startDragPos: Qt.point(0, 0)
    property bool previewPlaying: false
    property real scrollSpeed: 200
    property real currentScrollX: 0
    property real previewScale: 1.0

    // 文字颜色属性
    property color textColor: "#FF0000"
    property var gradientStops: [
        {color: "#FF0000", position: 0.0},
        {color: "#FFFF00", position: 0.5},
        {color: "#00FF00", position: 1.0}
    ]
    property bool useGradient: false

    // 快速布线配置
    property var quickWiringConfig: ({
        "width": 16,
        "height": 8,
        "hSpacing": 0,
        "vSpacing": 0,
        "direction": "wiring_StartLeftBottom_EndRightTop_M_Horizontal"
    })

    // 网格计算属性
    property real gridOffsetX: 0
    property real gridOffsetY: 0
    property real gridCellWidth: 0
    property real gridCellHeight: 0
    property real gridTotalWidth: 0
    property real gridTotalHeight: 0
    property int gridCols: 0
    property int gridRows: 0

    // 文字容器位置
    property real textContainerStartX: 0
    property real textContainerEndX: 0

    // 字符
    property int charWidthLeds: 16
    property int charHeightLeds: 16
    property int spacingCols: 1
    property var charBitmapCache: ({})

    // CharBitmapGenerator实例
    property var charBitmapGenerator: null
    property bool charGeneratorReady: false
    property bool useCppCharGenerator: true

    // 内部属性
    property string animationText: "LED文字效果"
    property real fontSizeProperty: 54
    property string fontNameProperty: "宋体"

    // 信号
    signal propertyValueChanged(string propertyName, variant value)
    signal textContentChanged(string text)
    signal colorSelected(color color)
    signal templateChanged(string templateName)
    signal previewToggled(bool playing)
    signal gradientApplied(var gradient)
    signal generateLedDataRequested()
    signal exportEffectRequested()
    signal charGeneratorInitialized(bool success, string mode)
    signal charBitmapLoaded(string ledchar, var bitmap)

    // 初始化CharBitmapGenerator
    function initCharBitmapGenerator() {
        console.log("正在初始化CharBitmapGenerator...");

        try {
            // 尝试创建C++版本的CharBitmapGenerator
            if (useCppCharGenerator) {
                // 检查是否有C++版本可用
                charBitmapGenerator = Qt.createQmlObject(
                    'import LedPlayer 1.0; CharBitmapGenerator { }',
                    animationEditorDialog,
                    "CharBitmapGeneratorCpp"
                );

                if (charBitmapGenerator) {
                    console.log("C++ CharBitmapGenerator创建成功");
                    charGeneratorReady = true;
                    charGeneratorInitialized(true, "C++");
                    setupCharGeneratorProperties();
                    return;
                }
            }
        } catch (error) {
            console.warn("C++ CharBitmapGenerator创建失败:", error);
        }

        // 如果C++版本不可用，使用纯QML版本
        console.log("使用纯QML CharBitmapGenerator实现");
        charBitmapGenerator = createQmlCharBitmapGenerator();
        if (charBitmapGenerator) {
            charGeneratorReady = true;
            charGeneratorInitialized(true, "QML");
        } else {
            charGeneratorInitialized(false, "None");
        }
    }

    // 创建纯QML版本的CharBitmapGenerator
    function createQmlCharBitmapGenerator() {
        var component = Qt.createComponent("../utils/CharBitmapGenerator.qml");
        if (component.status === Component.Ready) {
            return component.createObject(animationEditorDialog, {});
        } else {
            console.error("无法创建QML CharBitmapGenerator:", component.errorString());
            return null;
        }
    }

    // 设置CharBitmapGenerator属性
    function setupCharGeneratorProperties() {
        if (charBitmapGenerator) {
            charBitmapGenerator.charWidth = charWidthLeds;
            charBitmapGenerator.charHeight = charHeightLeds;
            charBitmapGenerator.enableAntialiasing = true;
            charBitmapGenerator.threshold = 30;

            // 启用调试模式
            charBitmapGenerator.setDebugEnabled(true);
            charBitmapGenerator.setDebugPath(Qt.application.dataPath + "/char_bitmaps");

            console.log("CharBitmapGenerator设置完成");
            console.log("Char Width:", charBitmapGenerator.charWidth);
            console.log("Char Height:", charBitmapGenerator.charHeight);
        }
    }

    // 获取字符点阵
    function getCharBitmapDynamic(ledchar, fontSize, fontFamily) {
        if (!charGeneratorReady || !charBitmapGenerator) {
            console.warn("CharBitmapGenerator未初始化，使用备用方案");
            return getCharBitmapBackup(ledchar, fontSize, fontFamily);
        }

        try {
            var bitmap = charBitmapGenerator.getCharBitmap(ledchar, fontSize, fontFamily);
            if (bitmap && bitmap.length > 0) {
                // console.log("获取字符点阵成功:", ledchar, "尺寸:", bitmap.length, "x", (bitmap[0] ? bitmap[0].length : 0));
                charBitmapLoaded(ledchar, bitmap);
                return bitmap;
            } else {
                console.warn("CharBitmapGenerator返回空点阵，使用备用方案");
                return getCharBitmapBackup(ledchar, fontSize, fontFamily);
            }
        } catch (error) {
            console.error("获取字符点阵时出错:", error);
            return getCharBitmapBackup(ledchar, fontSize, fontFamily);
        }
    }

    // 备用字符点阵生成函数
    function getCharBitmapBackup(ledchar, fontSize, fontFamily) {
        console.log("使用备用字符点阵生成:", ledchar);

        const width = 16;
        const height = 16;
        let bitmap = [];

        // 统一转为大写处理
        const ch = ledchar.toUpperCase();

        if (ch === 'L') {
            // L：左竖线 + 底横线
            for (let i = 0; i < height; i++) {
                let row = [];
                for (let j = 0; j < width; j++) {
                    if (j === 0 || i === height - 1) {
                        row.push(1);
                    } else {
                        row.push(0);
                    }
                }
                bitmap.push(row);
            }
        }
        else if (ch === 'E') {
            // E：左竖线 + 上、中、下横线
            const midRow = Math.floor(height / 2);
            for (let i = 0; i < height; i++) {
                let row = [];
                for (let j = 0; j < width; j++) {
                    if (j === 0 || i === 0 || i === midRow || i === height - 1) {
                        row.push(1);
                    } else {
                        row.push(0);
                    }
                }
                bitmap.push(row);
            }
        }
        else if (ch === 'D') {
            // D：左竖线 + 顶横线 + 底横线 + 右侧弧线
            for (let i = 0; i < height; i++) {
                let row = [];
                // 左侧竖线
                row.push(1);
                // 中间列
                for (let j = 1; j < width - 1; j++) {
                    let isSet = 0;
                    if (i === 0 && j <= 13) isSet = 1;
                    else if (i === height - 1 && j <= 14) isSet = 1;
                    else if (i > 0 && i < height - 1) {
                        let t = (i / (height - 1)) * Math.PI;
                        let rightBound = Math.floor(11 + 4 * Math.sin(t));
                        if (j === rightBound) isSet = 1;
                    }
                    row.push(isSet);
                }
                row.push(0);
                bitmap.push(row);
            }
        }
        else {
            // 默认生成16x16边框
            for (let i = 0; i < height; i++) {
                let row = [];
                for (let j = 0; j < width; j++) {
                    if (i === 0 || i === height - 1 || j === 0 || j === width - 1) {
                        row.push(1);
                    } else {
                        row.push(0);
                    }
                }
                bitmap.push(row);
            }
        }

        return bitmap;
    }

    // 计算网格参数
    function calculateGridParameters() {
        if (!quickWiringConfig) return;

        var config = quickWiringConfig;
        var baseWidth = Math.max(1, config.width || 16);
        var baseHeight = Math.max(1, config.height || 8);
        var hSpacing = Math.max(0, config.hSpacing || 0);
        var vSpacing = Math.max(0, config.vSpacing || 0);

        var hFactor = hSpacing + 1;
        var vFactor = vSpacing + 1;
        gridCols = baseWidth * hFactor;
        gridRows = baseHeight * vFactor;

        // 计算可用空间
        var availableWidth = animationPreviewArea.width - 20;
        var availableHeight = animationPreviewArea.height - 20;

        // 计算基础单元格大小
        var baseCellWidth = availableWidth / gridCols;
        var baseCellHeight = availableHeight / gridRows;

        // 应用缩放
        gridCellWidth = baseCellWidth * previewScale;
        gridCellHeight = baseCellHeight * previewScale;

        // 计算整个网格的大小
        gridTotalWidth = gridCols * gridCellWidth;
        gridTotalHeight = gridRows * gridCellHeight;

        // 计算居中偏移
        gridOffsetX = (animationPreviewArea.width - gridTotalWidth) / 2;
        gridOffsetY = (animationPreviewArea.height - gridTotalHeight) / 2;

        // 计算文字容器宽度
        var totalCols = animationText.length * charWidthLeds + (animationText.length - 1) * spacingCols;
        if (textContainer) {
            textContainer.width = totalCols * gridCellWidth;
        }

        // 计算起始和结束位置
        textContainerStartX = animationPreviewArea.width;
        if (textContainer) {
            textContainerEndX = -textContainer.width;
        }

        // 重置位置
        if (!previewPlaying && textContainer) {
            textContainer.x = textContainerStartX;
        }
    }

    // 计算渐变颜色
    function getGradientColor(position) {
        if (!useGradient || gradientStops.length === 0) {
            return textColor;
        }

        if (gradientStops.length === 1) {
            return gradientStops[0].color;
        }

        // 确保位置在[0,1]范围内
        position = Math.max(0, Math.min(1, position));

        // 查找位置所在的区间
        for (var i = 0; i < gradientStops.length - 1; i++) {
            var stop1 = gradientStops[i];
            var stop2 = gradientStops[i + 1];

            if (position >= stop1.position && position <= stop2.position) {
                // 计算插值比例
                var t = (position - stop1.position) / (stop2.position - stop1.position);

                // 解析颜色
                var c1 = Qt.color(stop1.color);
                var c2 = Qt.color(stop2.color);

                // 插值计算颜色
                var r = Math.floor(c1.r * 255 + (c2.r * 255 - c1.r * 255) * t);
                var g = Math.floor(c1.g * 255 + (c2.g * 255 - c1.g * 255) * t);
                var b = Math.floor(c1.b * 255 + (c2.b * 255 - c1.b * 255) * t);

                return Qt.rgba(r/255, g/255, b/255, 1);
            }
        }

        // 如果位置超出范围，返回最后一个颜色
        return gradientStops[gradientStops.length - 1].color;
    }

    // 计算LED颜色
    function calculateLedColor(col, row) {
        var text = animationText;
        if (text.length === 0) return "#202020";

        // 计算每个字符块占用的总列数
        var charBlockCols = charWidthLeds + spacingCols;
        var totalTextCols = text.length * charWidthLeds + (text.length - 1) * spacingCols;

        // 基于滚动偏移计算当前LED列在文字块中的绝对列索引
        var offsetCols = 0;
        if (textContainer) {
            offsetCols = Math.floor(textContainer.x / gridCellWidth);
        }
        var absoluteCol = col - offsetCols;

        // 检查是否在文字块范围内
        if (absoluteCol >= 0 && absoluteCol < totalTextCols) {
            // 确定字符索引和字符内的本地列
            var charIndex = 0;
            var localCol = 0;
            if (absoluteCol < (text.length - 1) * charBlockCols) {
                charIndex = Math.floor(absoluteCol / charBlockCols);
                localCol = absoluteCol % charBlockCols;
                if (localCol >= charWidthLeds) {
                    return "#202020";
                }
            } else {
                var lastBlockStart = (text.length - 1) * charBlockCols;
                charIndex = text.length - 1;
                localCol = absoluteCol - lastBlockStart;
                if (localCol >= charWidthLeds) {
                    return "#202020";
                }
            }

            // 垂直方向：如果LED行超出字符高度，则不点亮
            if (row >= 0 && row < charHeightLeds) {
                var ch = text.charAt(charIndex);
                var bitmap = getCharBitmapDynamic(ch, fontSizeProperty, fontNameProperty);

                if (bitmap && bitmap[row] && bitmap[row][localCol] === 1) {
                    var progress = charIndex / (text.length - 1);
                    if (useGradient) {
                        return getGradientColor(progress);
                    } else {
                        return textColor;
                    }
                }
            }
        }
        return "#202020";
    }

    // 动态调整Timer间隔以实现scrollSpeed控制
    function updateTimerInterval() {
        if (gridCellWidth > 0 && updateLEDTimer) {
            var intervalMs = (gridCellWidth / scrollSpeed) * 1000;
            updateLEDTimer.interval = Math.min(200, Math.max(10, intervalMs));
        }
    }

    // 测试CharBitmapGenerator
    function testCharBitmapGenerator() {
        console.log("=== 测试CharBitmapGenerator ===");

        if (!charGeneratorReady) {
            console.error("CharBitmapGenerator未就绪");
            return;
        }

        // 测试简单字符
        var testChars = ["L", "E", "D", "A", "B", "C"];
        for (var i = 0; i < testChars.length; i++) {
            var ch = testChars[i];
            console.log("测试字符:", ch);

            var bitmap = getCharBitmapDynamic(ch, 24, "Arial");
            if (bitmap && bitmap.length > 0) {
                console.log("字符点阵尺寸:", bitmap.length, "x", (bitmap[0] ? bitmap[0].length : 0));

                // 显示前几行
                var previewRows = Math.min(5, bitmap.length);
                for (var r = 0; r < previewRows; r++) {
                    var rowStr = "";
                    var previewCols = Math.min(10, bitmap[r].length);
                    for (var c = 0; c < previewCols; c++) {
                        rowStr += (bitmap[r][c] === 1) ? "██" : "  ";
                    }
                    console.log("  " + rowStr);
                }
            } else {
                console.error("获取字符点阵失败:", ch);
            }
        }

        console.log("=== 测试完成 ===");
    }

    // 主内容容器
    Rectangle {
        id: popupContainer
        width: parent.width
        height: parent.height
        color: "#1E1E1E"
        border.color: "#3E3E3E"
        border.width: 2
        radius: 8

        // 可拖动区域
        MouseArea {
            id: dragArea
            anchors.fill: titleBar
            cursorShape: Qt.SizeAllCursor
            onPressed: function(mouse) {
                dragging = true
                startDragPos = Qt.point(mouse.x, mouse.y)
            }
            onPositionChanged: function(mouse) {
                if (dragging) {
                    var deltaX = mouse.x - startDragPos.x
                    var deltaY = mouse.y - startDragPos.y
                    animationEditorDialog.x += deltaX
                    animationEditorDialog.y += deltaY
                }
            }
            onReleased: function(mouse) {
                dragging = false
            }
        }

        // 标题栏
        Rectangle {
            id: titleBar
            width: parent.width
            height: 40
            color: "#252526"
            radius: 8

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 15
                anchors.rightMargin: 10
                spacing: 10

                Text {
                    text: "动画编辑 - LED文字效果"
                    color: "#FFFFFF"
                    font.bold: true
                    font.pixelSize: 16
                    Layout.fillWidth: true
                }

                // 字符生成器状态指示
                Rectangle {
                    width: 12
                    height: 12
                    radius: 6
                    color: charGeneratorReady ? "#00FF00" : "#FF0000"
                    border.color: "#FFFFFF"
                    border.width: 1
                }

                Text {
                    text: charGeneratorReady ? "就绪" : "未就绪"
                    color: charGeneratorReady ? "#00FF00" : "#FF0000"
                    font.pixelSize: 12
                }

                Button {
                    id: testGeneratorBtn
                    text: "测试生成器"
                    width: 80
                    height: 30
                    visible: charGeneratorReady

                    onClicked: {
                        testCharBitmapGenerator();
                    }

                    background: Rectangle {
                        color: parent.pressed ? "#4a5568" : "#2b6cb0"
                        radius: 4
                    }

                    contentItem: Text {
                        text: parent.text
                        color: "white"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.pixelSize: 12
                    }
                }

                Button {
                    id: closeButton
                    width: 30
                    height: 30
                    flat: true
                    background: Rectangle {
                        color: closeButton.hovered ? "#FF4444" : "transparent"
                        radius: 3
                    }
                    contentItem: Text {
                        text: "×"
                        color: "#FFFFFF"
                        font.pixelSize: 20
                        anchors.centerIn: parent
                    }
                    onClicked: animationEditorDialog.close()
                }
            }
        }

        // 主内容区域
        ColumnLayout {
            anchors.fill: parent
            anchors.topMargin: 40
            spacing: 0

            RowLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 0

                // 左侧预览区域
                Rectangle {
                    id: animationPreviewArea
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: "#000000"
                    clip: true

                    Text {
                        text: "预览区域"
                        color: "#FFFFFF"
                        font.pixelSize: 12
                        anchors.top: parent.top
                        anchors.left: parent.left
                        anchors.margins: 10
                        z: 10
                    }

                    // 滚动内容的容器
                    Item {
                        id: rollingContainer
                        anchors.fill: parent
                        clip: true

                        // LED网格Canvas
                        Canvas {
                            id: wiringCanvas
                            anchors.fill: parent
                            visible: true
                            z: 0

                            onPaint: {
                                var ctx = getContext("2d");
                                ctx.clearRect(0, 0, width, height);

                                if (!quickWiringConfig) {
                                    return;
                                }

                                // 重新计算网格参数
                                calculateGridParameters();

                                var squareSize = Math.max(6, Math.min(gridCellWidth, gridCellHeight) * 0.7);

                                // 黑色背景
                                ctx.fillStyle = "#000000";
                                ctx.fillRect(gridOffsetX, gridOffsetY, gridTotalWidth, gridTotalHeight);

                                // 绘制网格线
                                ctx.strokeStyle = "#333333";
                                ctx.lineWidth = 1;

                                // 垂直线
                                for (var i = 0; i <= gridCols; i++) {
                                    var x = gridOffsetX + i * gridCellWidth;
                                    ctx.beginPath();
                                    ctx.moveTo(x, gridOffsetY);
                                    ctx.lineTo(x, gridOffsetY + gridTotalHeight);
                                    ctx.stroke();
                                }

                                // 水平线
                                for (var j = 0; j <= gridRows; j++) {
                                    var y = gridOffsetY + j * gridCellHeight;
                                    ctx.beginPath();
                                    ctx.moveTo(gridOffsetX, y);
                                    ctx.lineTo(gridOffsetX + gridTotalWidth, y);
                                    ctx.stroke();
                                }

                                // 绘制LED方块
                                for (j = 0; j < gridRows; j++) {
                                    for (i = 0; i < gridCols; i++) {
                                        var squareX = gridOffsetX + i * gridCellWidth + gridCellWidth / 2 - squareSize / 2;
                                        var squareY = gridOffsetY + j * gridCellHeight + gridCellHeight / 2 - squareSize / 2;

                                        // 计算LED颜色
                                        var ledColor = calculateLedColor(i, j);

                                        // 绘制LED方块
                                        ctx.fillStyle = ledColor;

                                        // 添加LED发光效果
                                        ctx.shadowColor = ledColor;
                                        ctx.shadowBlur = 8;
                                        ctx.fillRect(squareX, squareY, squareSize, squareSize);

                                        // 重置阴影
                                        ctx.shadowBlur = 0;

                                        // 添加LED边框
                                        ctx.strokeStyle = "#666666";
                                        ctx.lineWidth = 1;
                                        ctx.strokeRect(squareX, squareY, squareSize, squareSize);
                                    }
                                }

                                // 显示当前缩放比例
                                ctx.fillStyle = "#FFFFFF";
                                ctx.font = "12px Arial";
                                ctx.fillText("缩放: " + (previewScale * 100).toFixed(0) + "%", 10, height - 10);

                                // 显示网格信息
                                ctx.fillText("网格: " + gridCols + "×" + gridRows, 10, height - 30);

                                // 显示文字位置信息
                                if (textContainer) {
                                    ctx.fillText("文字位置: " + textContainer.x.toFixed(0), 10, height - 50);
                                }

                                // 显示字符生成器状态
                                ctx.fillText("字符生成器: " + (charGeneratorReady ? "就绪" : "未就绪"), 10, height - 70);
                            }
                        }

                        // 文字容器
                        Item {
                            id: textContainer
                            width: 0
                            height: 0
                            x: 0
                            y: 0
                            z: 1
                        }
                    }

                    // 定时更新LED网格
                    Timer {
                        id: updateLEDTimer
                        interval: 16
                        repeat: true
                        running: previewPlaying
                        property real stepDistance: gridCellWidth
                        onTriggered: {
                            if (textContainer) {
                                // 移动一格
                                textContainer.x -= stepDistance;

                                // 检查是否移出左边界
                                if (textContainer.x <= textContainerEndX) {
                                    textContainer.x = textContainerStartX;
                                }

                                // 刷新LED显示
                                wiringCanvas.requestPaint();
                            }
                        }
                    }
                }

                // 右侧面板
                Rectangle {
                    Layout.preferredWidth: 400
                    Layout.fillHeight: true
                    color: "#252526"
                    border.color: "#3E3E3E"
                    border.width: 1

                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 0

                        // 属性设置面板
                        PropertySettingsPanel {
                            id: propertyPanel
                            Layout.fillWidth: true
                            Layout.preferredHeight: 350

                            currentItemProperties: {
                                "text": animationText,
                                "gridWidth": quickWiringConfig.width,
                                "gridHeight": quickWiringConfig.height,
                                "fontName": fontNameProperty,
                                "fontSize": fontSizeProperty
                            }

                            quickWiringConfig: animationEditorDialog.quickWiringConfig

                            onPropertyChanged: function(name, value) {
                                console.log("属性变更: " + name + " = " + value);

                                switch (name) {
                                    case "text":
                                        animationText = value;
                                        textContentChanged(value);
                                        break;
                                    case "gridWidth":
                                        if (quickWiringConfig) {
                                            quickWiringConfig.width = value;
                                        }
                                        break;
                                    case "gridHeight":
                                        if (quickWiringConfig) {
                                            quickWiringConfig.height = value;
                                        }
                                        break;
                                    case "fontName":
                                        fontNameProperty = value;
                                        break;
                                    case "fontSize":
                                        fontSizeProperty = value;
                                        break;
                                }

                                propertyValueChanged(name, value);
                                calculateGridParameters();
                                wiringCanvas.requestPaint();
                            }

                            onTextChanged: function(newText) {
                                animationText = newText;
                                textContentChanged(newText);
                                calculateGridParameters();
                                wiringCanvas.requestPaint();
                            }

                            onGenerateLedData: function() {
                                console.log("生成LED数据请求");
                                generateLedDataRequested();
                            }

                            onExportEffect: function() {
                                console.log("导出效果请求");
                                exportEffectRequested();
                            }

                            onCanvasRepaintRequested: function() {
                                wiringCanvas.requestPaint();
                            }
                        }

                        // 色带编辑面板
                        ColorBandEditorPanel {
                            id: colorBandPanel
                            Layout.fillWidth: true
                            Layout.preferredHeight: 250

                            useGradient: animationEditorDialog.useGradient
                            textColor: animationEditorDialog.textColor
                            previewPlaying: animationEditorDialog.previewPlaying
                            gradientStops: animationEditorDialog.gradientStops

                            onColorSelected: function(color) {
                                console.log("颜色选择: " + color);
                                animationEditorDialog.useGradient = false;
                                animationEditorDialog.textColor = color;
                                colorSelected(color);
                                wiringCanvas.requestPaint();
                            }

                            onTemplateChanged: function(templateName) {
                                console.log("模板变更: " + templateName);
                                templateChanged(templateName);
                            }


                            onCanvasRepaintRequested: function() {
                                wiringCanvas.requestPaint();
                            }

                            onGradientApplied: function(gradient) {
                                console.log("渐变应用: " + JSON.stringify(gradient));
                                animationEditorDialog.useGradient = true;
                                animationEditorDialog.gradientStops = gradient;
                                gradientApplied(gradient);
                                wiringCanvas.requestPaint();
                            }
                        }
                    }
                }
            }

            // 预览控制栏
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 50
                color: "#252526"

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 20

                    Button {
                        text: previewPlaying ? "暂停" : "预览"
                        Layout.preferredWidth: 60
                        Layout.preferredHeight: 25
                        background: Rectangle {
                            color: parent.pressed ? "#0066CC" : "#007ACC"
                            border.color: "#0066CC"
                            border.width: 1
                            radius: 3
                        }
                        contentItem: Text {
                            text: parent.text
                            color: "#FFFFFF"
                            font.pixelSize: 12
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                        onClicked: {
                            previewPlaying = !previewPlaying
                            if (previewPlaying) {
                                calculateGridParameters();
                                if (textContainer) {
                                    textContainer.x = textContainerStartX;
                                }
                                updateLEDTimer.start();
                            } else {
                                updateLEDTimer.stop();
                            }
                        }
                    }

                    // 滚动速度控制
                    RowLayout {
                        spacing: 5
                        Label {
                            text: "速度:"
                            color: "#CCCCCC"
                            font.pixelSize: 12
                        }
                        Slider {
                            id: speedSlider
                            from: 50
                            to: 500
                            value: scrollSpeed
                            stepSize: 10
                            Layout.preferredWidth: 100
                            onValueChanged: {
                                scrollSpeed = value
                                updateTimerInterval();
                            }
                        }
                        Label {
                            text: Math.round(scrollSpeed) + " px/s"
                            color: "#CCCCCC"
                            font.pixelSize: 12
                        }
                    }

                    // 缩放控制
                    RowLayout {
                        spacing: 5
                        Label {
                            text: "缩放:"
                            color: "#CCCCCC"
                            font.pixelSize: 12
                        }
                        Slider {
                            id: scaleSlider
                            from: 0.1
                            to: 3.0
                            value: previewScale
                            stepSize: 0.1
                            Layout.preferredWidth: 100
                            onValueChanged: {
                                previewScale = value
                                calculateGridParameters()
                                wiringCanvas.requestPaint()
                            }
                        }
                        Label {
                            text: (previewScale * 100).toFixed(0) + "%"
                            color: "#CCCCCC"
                            font.pixelSize: 12
                            Layout.preferredWidth: 50
                        }

                        // 缩放按钮
                        Button {
                            text: "100%"
                            Layout.preferredWidth: 50
                            Layout.preferredHeight: 25
                            background: Rectangle {
                                color: parent.pressed ? "#666666" : "#333333"
                                border.color: "#555555"
                                border.width: 1
                                radius: 3
                            }
                            contentItem: Text {
                                text: parent.text
                                color: "#CCCCCC"
                                font.pixelSize: 12
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                            onClicked: {
                                previewScale = 1.0
                                scaleSlider.value = 1.0
                                calculateGridParameters()
                                wiringCanvas.requestPaint()
                            }
                        }
                    }

                    Text {
                        text: animationText.length + " 字符"
                        color: "#CCCCCC"
                        font.pixelSize: 12
                    }

                    Item { Layout.fillWidth: true }

                    Text {
                        text: "LED网格: " + (quickWiringConfig.width * quickWiringConfig.height) + " 像素"
                        color: "#999999"
                        font.pixelSize: 12
                    }
                }
            }

            // 信息提示
            Text {
                Layout.leftMargin: 10
                Layout.bottomMargin: 5
                text: "效果: 文字颜色映射到LED网格，从右向左播放"
                color: "#AAAAAA"
                font.pixelSize: 11
            }
            MaterialTimelinePanel{
                id: timeline
                Layout.fillWidth: true
                Layout.preferredHeight: 100
                title: "动画时间轴"
                totalFrames: 120
                totalDurationMs: 6000
                currentFrame: 1
                tickInterval: 10
                tickCount: 12
                playheadColor: "#FF5722"

                onFrameChanged: function(frame) {
                    console.log("当前帧:", frame)
                    // 在这里更新预览或其他逻辑
                }

                onPlayheadMoved: function(position) {
                    console.log("播放头位置:", position)
                }
            }
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 60
                color: "#252526"

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 10

                    Item { Layout.fillWidth: true }

                    Button {
                        id: cancelBtn
                        text: "取消"
                        Layout.preferredWidth: 80
                        Layout.preferredHeight: 30
                        background: Rectangle {
                            color: parent.pressed ? "#666666" : "#333333"
                            border.color: "#555555"
                            border.width: 1
                            radius: 3
                        }
                        contentItem: Text {
                            text: parent.text
                            color: "#CCCCCC"
                            font.pixelSize: 12
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                        onClicked: {
                            animationEditorDialog.close()
                        }
                    }

                    Button {
                        id: acceptBtn
                        text: "确定"
                        Layout.preferredWidth: 80
                        Layout.preferredHeight: 30
                        background: Rectangle {
                            color: parent.pressed ? "#0066CC" : "#007ACC"
                            border.color: "#0066CC"
                            border.width: 1
                            radius: 3
                        }
                        contentItem: Text {
                            text: parent.text
                            color: "#FFFFFF"
                            font.pixelSize: 12
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                        onClicked: {
                            // 保存设置并关闭
                            animationEditorDialog.close()
                        }
                    }
                }
            }
        }
    }

    Component.onCompleted: {
        console.log("LED动画编辑器初始化...");

        // 初始化CharBitmapGenerator
        initCharBitmapGenerator();

        calculateGridParameters();
        if (textContainer) {
            textContainer.x = textContainerStartX;
        }
        wiringCanvas.requestPaint();
    }

    onVisibleChanged: {
        if (visible) {
            var parentWindow = animationEditorDialog.parent
            if (parentWindow) {
                animationEditorDialog.x = (parentWindow.width - width) / 2
                animationEditorDialog.y = (parentWindow.height - height) / 2
            }
            calculateGridParameters();
            if (textContainer) {
                textContainer.x = textContainerStartX;
            }
            if (previewPlaying) {
                updateLEDTimer.start();
            }
            wiringCanvas.requestPaint();
        } else {
            updateLEDTimer.stop();
        }
    }

    onQuickWiringConfigChanged: {
        calculateGridParameters();
        wiringCanvas.requestPaint();
    }

    onTextColorChanged: wiringCanvas.requestPaint();
    onUseGradientChanged: wiringCanvas.requestPaint();
    onGradientStopsChanged: wiringCanvas.requestPaint();
    onPreviewScaleChanged: {
        calculateGridParameters();
        wiringCanvas.requestPaint();
    }

    onWidthChanged: {
        calculateGridParameters();
        wiringCanvas.requestPaint();
    }

    onHeightChanged: {
        calculateGridParameters();
        wiringCanvas.requestPaint();
    }
}
