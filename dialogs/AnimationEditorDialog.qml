import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts
import QtQuick.Dialogs
import QtQuick.Shapes
import QtQuick.Window
import "../components"

Window {
    id: animationEditorDialog
    width: 1200
    height: 800
    property bool dragging: false
    property point startDragPos: Qt.point(0, 0)
    property bool previewPlaying: false

    // 添加滚动属性
    property real scrollSpeed: 200  // 像素/秒
    property real currentScrollX: 0
    property real previewScale: 1.0  // 预览缩放比例

    // 文字颜色属性
    property color textColor: "#FF0000"  // 默认红色
    property var gradientStops: [
        {color: "#FF0000", position: 0.0},
        {color: "#FFFF00", position: 0.5},
        {color: "#00FF00", position: 1.0}
    ]
    property bool useGradient: false
    property var quickWiringConfig: {
        return {
            width: 16,
            height: 8,
            hSpacing: 0,
            vSpacing: 0,
            direction: "wiring_StartLeftBottom_EndRightTop_M_Horizontal"
        }
    }

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
    //字符
    property int charWidthLeds: 5      // 每个字符占用的 LED 列数
    property int charHeightLeds: 5     // 每个字符占用的 LED 行数
    property int spacingCols: 1        // 字符之间的间隔列数
    property var charBitmapCache: ({})  // 缓存字符的点阵数据
    //实现字符点阵生成函数（简易点阵）

    function getCharBitmap(ledchar) {
        var bitmaps = {
            'L': [
                [1,0,0,0,0],
                [1,0,0,0,0],
                [1,0,0,0,0],
                [1,0,0,0,0],
                [1,1,1,1,1]
            ],
            'E': [
                [1,1,1,1,1],
                [1,0,0,0,0],
                [1,1,1,1,1],
                [1,0,0,0,0],
                [1,1,1,1,1]
            ],
            'D': [
                [1,1,1,0,0],
                [1,0,0,1,0],
                [1,0,0,0,1],
                [1,0,0,1,0],
                [1,1,1,0,0]
            ]
        };
        if (!bitmaps[ledchar]) {
            // 默认生成一个边框点阵
            var defaultBitmap = [];
            for (var i = 0; i < charHeightLeds; i++) {
                var row = [];
                for (var j = 0; j < charWidthLeds; j++) {
                    row.push((i === 0 || i === charHeightLeds-1 || j === 0 || j === charWidthLeds-1) ? 1 : 0);
                }
                defaultBitmap.push(row);
            }
            return defaultBitmap;
        }
        return bitmaps[ledchar];
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

        // 计算文字容器的起始和结束位置
        textContainerStartX = animationPreviewArea.width;
        textContainerEndX = -textContainer.width;
        // 计算文字容器宽度（总列数 * 单元格宽度）
        var totalCols = animationText.text.length * charWidthLeds + (animationText.text.length - 1) * spacingCols;
        textContainer.width = totalCols * gridCellWidth;
        updateTimerInterval();
            // 重置位置
            if (!previewPlaying) {
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

    // 计算LED颜色 - 修复版本
    // function calculateLedColor(col, row) {
    //     // 计算LED方块中心在预览区域的坐标
    //     var ledCenterX = gridOffsetX + col * gridCellWidth + gridCellWidth / 2;

    //     // 计算LED中心在文字中的相对位置
    //     // 文字从右向左移动，所以我们需要计算LED中心对应文字中的哪个位置
    //     var textProgress = 1.0;

    //     if (textContainer.width > 0) {
    //         // 计算LED中心相对于文字容器起始位置的距离
    //         var distanceFromTextStart = ledCenterX - textContainer.x;

    //         // 如果LED在文字范围内
    //         if (distanceFromTextStart >= 0 && distanceFromTextStart <= textContainer.width) {
    //             // 计算在文字中的相对位置
    //             textProgress = distanceFromTextStart / textContainer.width;

    //             if (useGradient) {
    //                 return getGradientColor(textProgress);
    //             } else {
    //                 return textColor;
    //             }
    //         }
    //     }

    //     return "#202020";  // 不在文字范围内，返回暗灰色
    // }
    function calculateLedColor(col, row) {
        var text = animationText.text;
        if (text.length === 0) return "#202020";

        // 计算每个字符块占用的总列数（字符点阵列 + 间隔列）
        var charBlockCols = charWidthLeds + spacingCols;
        // 计算整个文字块在 LED 网格上占用的总列数
        // 最后一个字符后面不加间隔列
        var totalTextCols = text.length * charWidthLeds + (text.length - 1) * spacingCols;

        // 基于滚动偏移计算当前 LED 列在文字块中的绝对列索引
        var offsetCols = Math.floor(textContainer.x / gridCellWidth);
        var absoluteCol = col - offsetCols;

        // 检查是否在文字块范围内
        if (absoluteCol >= 0 && absoluteCol < totalTextCols) {
            // 确定字符索引和字符内的本地列
            var charIndex = 0;
            var localCol = 0;
            if (absoluteCol < (text.length - 1) * charBlockCols) {
                // 非最后一个字符区域
                charIndex = Math.floor(absoluteCol / charBlockCols);
                localCol = absoluteCol % charBlockCols;
                if (localCol >= charWidthLeds) {
                    // 位于间隔列，不点亮
                    return "#202020";
                }
            } else {
                // 最后一个字符区域（无尾部间隔）
                var lastBlockStart = (text.length - 1) * charBlockCols;
                charIndex = text.length - 1;
                localCol = absoluteCol - lastBlockStart;
                if (localCol >= charWidthLeds) {
                    return "#202020";
                }
            }

            // 垂直方向：如果 LED 行超出字符高度，则不点亮
            if (row >= 0 && row < charHeightLeds) {
                var ch = text.charAt(charIndex);
                var bitmap = getCharBitmap(ch);
                if (bitmap && bitmap[row] && bitmap[row][localCol] === 1) {
                    // 根据字符位置计算颜色渐变（可选）
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
    // 动态调整 Timer 间隔以实现 scrollSpeed 控制
    function updateTimerInterval() {
        if (gridCellWidth > 0) {
            // 移动一格所需时间（毫秒）= 一格距离 / 速度（像素/秒）* 1000
            var intervalMs = (gridCellWidth / scrollSpeed) * 1000;
            // 限制最小间隔 10ms，最大 200ms
            updateLEDTimer.interval = Math.min(200, Math.max(10, intervalMs));
        }
    }

    // 监听 scrollSpeed 或 gridCellWidth 变化
    onScrollSpeedChanged: updateTimerInterval()
    onGridCellWidthChanged: updateTimerInterval()
    // 主内容容器
    Rectangle {
        id: popupContainer
        width: parent.width
        height: parent.height
        color: "#1E1E1E"
        border.color: "#3E3E3E"
        border.width: 2
        radius: 8

        // 可拖动区域（仅标题栏）
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

                // ========== 左侧预览区域 ==========
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
                                ctx.fillText("文字位置: " + textContainer.x.toFixed(0), 10, height - 50);
                                console.log("文字位置: " + textContainer.x)

                                // 绘制文字容器轮廓（用于调试）
                                ctx.strokeStyle = "#FF0000";
                                ctx.lineWidth = 2;
                                ctx.strokeRect(textContainer.x, gridOffsetY, textContainer.width, gridTotalHeight);
                            }
                        }

                        // 文字容器 - 用于位置计算
                        Item {
                            id: textContainer
                            width: textMetrics.width
                            height: textMetrics.height
                            x: textContainerStartX
                            y: gridOffsetY
                            z: 1
                            visible: true  // 隐藏实际文字，只用于位置计算

                            // 单色文字
                            Text {
                                id: solidText
                                anchors.fill: parent
                                text: animationText.text
                                color: textColor
                                font.family: fontNameProperty.value
                                font.pixelSize: fontSizeProperty.value
                                renderType: Text.QtRendering
                                horizontalAlignment: Text.AlignLeft
                                verticalAlignment: Text.AlignVCenter
                            }

                            // 渐变文字
                            Item {
                                id: gradientTextContainer
                                anchors.fill: parent
                                visible: useGradient

                                Canvas {
                                    id: gradientCanvas
                                    anchors.fill: parent
                                    renderStrategy: Canvas.Cooperative
                                    renderTarget: Canvas.Image

                                    onPaint: {
                                        var ctx = getContext("2d");
                                        ctx.reset();

                                        // 设置字体
                                        ctx.font = fontSizeProperty.value + "px " + fontNameProperty.value;

                                        // 测量文字尺寸
                                        var metrics = ctx.measureText(animationText.text);
                                        var textWidth = metrics.width;
                                        var textHeight = fontSizeProperty.value;

                                        // 清除画布
                                        ctx.clearRect(0, 0, width, height);

                                        if (useGradient && gradientStops.length > 0) {
                                            // 创建渐变
                                            var gradient = ctx.createLinearGradient(0, 0, textWidth, 0);

                                            // 添加渐变停止点
                                            for (var i = 0; i < gradientStops.length; i++) {
                                                var stop = gradientStops[i];
                                                gradient.addColorStop(stop.position, stop.color);
                                            }

                                            // 设置填充样式
                                            ctx.fillStyle = gradient;
                                        } else {
                                            // 如果没有渐变，使用单色
                                            ctx.fillStyle = textColor;
                                        }

                                        // 设置文字对齐
                                        ctx.textBaseline = "middle";

                                        // 绘制文字
                                        ctx.fillText(animationText.text, 0, textHeight / 2);
                                    }
                                }
                            }
                        }

                        // 文字尺寸测量
                        TextMetrics {
                            id: textMetrics
                            font.family: fontNameProperty.value
                            font.pixelSize: fontSizeProperty.value
                            text: animationText.text
                        }
                    }

                    // 滚动动画
                    // 替换原有的 PropertyAnimation
                    // 滚动动画 - 使用更可靠的方式
                        // SequentialAnimation {
                        //     id: scrollAnimation
                        //     loops: Animation.Infinite
                        //     running: previewPlaying

                        //     PropertyAnimation {
                        //         target: textContainer
                        //         property: "x"
                        //         from: textContainerStartX
                        //         to: textContainerEndX
                        //         duration: (animationPreviewArea.width + textContainer.width) / scrollSpeed * 1000
                        //         easing.type: Easing.Linear
                        //     }

                        //     onRunningChanged: {
                        //         if (running) {
                        //             console.log("动画运行中");
                        //             // 确保起始位置正确
                        //             textContainer.x = textContainerStartX;
                        //             updateLEDTimer.start();
                        //         } else {
                        //             updateLEDTimer.stop();
                        //         }
                        //     }
                        // }

                    // 定时更新LED网格
                    Timer {
                        id: updateLEDTimer
                        interval:16  // 约60fps
                        repeat: true
                        running: previewPlaying
                        property real stepDistance: gridCellWidth
                        onTriggered: {
                            // 移动一格
                            textContainer.x -= stepDistance;

                            // 检查是否移出左边界
                            if (textContainer.x <= textContainerEndX) {
                                textContainer.x = textContainerStartX;
                            }

                            // 刷新 LED 显示
                            wiringCanvas.requestPaint();
                        }
                    }

                    // 更新滚动动画
                    function updateScrollAnimation() {
                        var wasPlaying = scrollAnimation.running;
                        scrollAnimation.stop();

                        // 重新计算起始和结束位置
                        calculateGridParameters();
                        scrollAnimation.from = textContainerStartX;
                        scrollAnimation.to = textContainerEndX;
                        scrollAnimation.duration = (animationPreviewArea.width + textContainer.width) / scrollSpeed * 1000;

                        if (wasPlaying) {
                            textContainer.x = textContainerStartX;
                            scrollAnimation.start();
                        }

                        wiringCanvas.requestPaint();
                    }

                                 }

                // ========== 右侧面板 ==========
                Rectangle {
                    Layout.preferredWidth: 400
                    Layout.fillHeight: true
                    color: "#252526"
                    border.color: "#3E3E3E"
                    border.width: 1

                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 0

                        PropertyGroup {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 300
                            title: "色带编辑"
                            expanded: true

                            ColumnLayout {
                                spacing: 10

                                ColumnLayout {
                                    spacing: 5
                                    Text { text: "内置色带"; color: "#CCCCCC"; font.pixelSize: 12 }
                                    RowLayout {
                                        spacing: 5
                                        GradientSwatch {
                                            gradientSwatchStops: [
                                                {color: "#FF0000", position: 0.0},
                                                {color: "#FFFF00", position: 0.5},
                                                {color: "#00FF00", position: 1.0}
                                            ]
                                            onSwatchClicked: {
                                                useGradient = true
                                                gradientStops = gradientSwatchStops
                                                console.log("应用渐变:", gradientSwatchStops)
                                                wiringCanvas.requestPaint()
                                            }
                                        }
                                        GradientSwatch {
                                            gradientSwatchStops: [
                                                {color: "#0000FF", position: 0.0},
                                                {color: "#00FFFF", position: 0.5},
                                                {color: "#FFFFFF", position: 1.0}
                                            ]
                                            onSwatchClicked: {
                                                useGradient = true
                                                gradientStops = gradientSwatchStops
                                                console.log("应用渐变:", gradientSwatchStops)
                                                wiringCanvas.requestPaint()
                                            }
                                        }
                                        GradientSwatch {
                                            gradientSwatchStops: [
                                                {color: "#FF00FF", position: 0.0},
                                                {color: "#FFFF00", position: 0.5},
                                                {color: "#00FFFF", position: 1.0}
                                            ]
                                            onSwatchClicked: {
                                                useGradient = true
                                                gradientStops = gradientSwatchStops
                                                console.log("应用渐变:", gradientSwatchStops)
                                                wiringCanvas.requestPaint()
                                            }
                                        }
                                        GradientSwatch {
                                            gradientSwatchStops: [
                                                {color: "#FF0000", position: 0.0},
                                                {color: "#FFFFFF", position: 1.0}
                                            ]
                                            onSwatchClicked: {
                                                useGradient = true
                                                gradientStops = gradientSwatchStops
                                                console.log("应用渐变:", gradientSwatchStops)
                                                wiringCanvas.requestPaint()
                                            }
                                        }
                                        GradientSwatch {
                                            gradientSwatchStops: [
                                                {color: "#000000", position: 0.0},
                                                {color: "#00FF00", position: 0.5},
                                                {color: "#0000FF", position: 1.0}
                                            ]
                                            onSwatchClicked: {
                                                useGradient = true
                                                gradientStops = gradientSwatchStops
                                                console.log("应用渐变:", gradientSwatchStops)
                                                wiringCanvas.requestPaint()
                                            }
                                        }
                                    }
                                }

                                ColumnLayout {
                                    spacing: 5
                                    Text { text: "单色色带"; color: "#CCCCCC"; font.pixelSize: 12 }
                                    RowLayout {
                                        spacing: 5
                                        ColorSwatch {
                                            swatchColor: "#FF0000"
                                            onSwatchClicked: {
                                                useGradient = false
                                                textColor = swatchColor
                                                console.log("应用单色:", textColor)
                                                wiringCanvas.requestPaint()
                                            }
                                        }
                                        ColorSwatch {
                                            swatchColor: "#FF9900"
                                            onSwatchClicked: {
                                                useGradient = false
                                                textColor = swatchColor
                                                wiringCanvas.requestPaint()
                                            }
                                        }
                                        ColorSwatch {
                                            swatchColor: "#FFFF00"
                                            onSwatchClicked: {
                                                useGradient = false
                                                textColor = swatchColor
                                                wiringCanvas.requestPaint()
                                            }
                                        }
                                        ColorSwatch {
                                            swatchColor: "#00FF00"
                                            onSwatchClicked: {
                                                useGradient = false
                                                textColor = swatchColor
                                                wiringCanvas.requestPaint()
                                            }
                                        }
                                        ColorSwatch {
                                            swatchColor: "#0000FF"
                                            onSwatchClicked: {
                                                useGradient = false
                                                textColor = swatchColor
                                                wiringCanvas.requestPaint()
                                            }
                                        }
                                    }
                                }

                                PropertyField {
                                    label: "外置模板"
                                    value: "模板1"
                                    fieldType: "combo"
                                    options: ["模板1", "模板2", "模板3"]
                                }

                                ColumnLayout {
                                    spacing: 5
                                    Text { text: "已选色带"; color: "#CCCCCC"; font.pixelSize: 12 }
                                    RowLayout {
                                        spacing: 5
                                        Repeater {
                                            model: 5
                                            Rectangle {
                                                width: 30
                                                height: 20
                                                color: ["#FF0000","#00FF00","#0000FF","#FFFF00","#FF00FF"][index]
                                                border.color: "#444444"
                                            }
                                        }
                                    }
                                }

                                RowLayout {
                                    Layout.fillWidth: true
                                    Item { Layout.fillWidth: true }
                                    Button {
                                        text: previewPlaying ? "暂停" : "预览"
                                        Layout.preferredWidth: 60
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
                                            previewPlaying = !previewPlaying
                                            if (previewPlaying) {
                                                calculateGridParameters();
                                                textContainer.x = textContainerStartX;
                                                updateLEDTimer.start();
                                            } else {
                                                updateLEDTimer.stop();
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        // 属性设置
                        ScrollView {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            ScrollBar.vertical.policy: ScrollBar.AsNeeded

                            ColumnLayout {
                                width: parent.width
                                spacing: 5

                                TextField {
                                    id: animationText
                                    text: "LED文字效果"
                                    color: "white"
                                    background: Rectangle {
                                        color: "#333333"
                                        border.color: "#555555"
                                    }
                                    Layout.fillWidth: true
                                    onTextChanged: {
                                        // 重新计算文字容器宽度
                                        var totalCols = animationText.text.length * charWidthLeds + (animationText.text.length - 1) * spacingCols;
                                        textContainer.width = totalCols * gridCellWidth;
                                        updateScrollAnimation();
                                        wiringCanvas.requestPaint();
                                    }
                                }

                                PropertyGroup {
                                    title: "LED网格设置"
                                    expanded: true
                                    ColumnLayout {
                                        PropertyField {
                                            label: "网格宽度"
                                            value: quickWiringConfig.width
                                            fieldType: "spin"
                                            from: 1
                                            to: 64
                                            onValueChanged: {
                                                quickWiringConfig.width = value
                                                wiringCanvas.requestPaint()
                                            }
                                        }
                                        PropertyField {
                                            label: "网格高度"
                                            value: quickWiringConfig.height
                                            fieldType: "spin"
                                            from: 1
                                            to: 32
                                            onValueChanged: {
                                                quickWiringConfig.height = value
                                                wiringCanvas.requestPaint()
                                            }
                                        }
                                        PropertyField {
                                            label: "LED大小"
                                            value: "70%"
                                            fieldType: "combo"
                                            options: ["50%", "60%", "70%", "80%", "90%"]
                                        }
                                        PropertyField {
                                            label: "亮度"
                                            value: "高"
                                            fieldType: "combo"
                                            options: ["低", "中", "高", "极高"]
                                        }
                                    }
                                }

                                PropertyGroup {
                                    title: "基本属性"
                                    expanded: true
                                    ColumnLayout {
                                        Text {
                                            text: "字体设置"
                                            color: "#D4D4D4"
                                            font.bold: true
                                            font.pixelSize: 12
                                        }
                                        RowLayout {
                                            Text {
                                                text: "宋体"
                                                color: "#CCCCCC"
                                                font.pixelSize: 12
                                                Layout.preferredWidth: 100
                                            }
                                            Text {
                                                text: "更多"
                                                color: "#007ACC"
                                                font.pixelSize: 12
                                                Layout.fillWidth: true
                                            }
                                        }
                                        PropertyField {
                                            id: fontNameProperty
                                            label: "字体名称"
                                            value: "宋体"
                                            fieldType: "combo"
                                            options: ["宋体", "微软雅黑", "黑体", "楷体"]
                                            onValueChanged: {
                                                updateScrollAnimation()
                                                wiringCanvas.requestPaint()
                                            }
                                        }
                                        PropertyField {
                                            id: fontSizeProperty
                                            label: "字体大小"
                                            value: 54
                                            fieldType: "spin"
                                            from: 1
                                            to: 200
                                            onValueChanged: {
                                                updateScrollAnimation()
                                                wiringCanvas.requestPaint()
                                            }
                                        }
                                        PropertyField {
                                            label: "素材名称"
                                            value: "LED文字效果"
                                            fieldType: "text"
                                        }
                                        PropertyField {
                                            label: "起点X坐标"
                                            value: 0
                                            fieldType: "spin"
                                            from: 0
                                            to: 9999
                                        }
                                        PropertyField {
                                            label: "起点Y坐标"
                                            value: 0
                                            fieldType: "spin"
                                            from: 0
                                            to: 9999
                                        }
                                        PropertyField {
                                            label: "素材宽度"
                                            value: 60
                                            fieldType: "spin"
                                            from: 1
                                            to: 9999
                                        }
                                        PropertyField {
                                            label: "素材高度"
                                            value: 270
                                            fieldType: "spin"
                                            from: 1
                                            to: 9999
                                        }
                                        PropertyField {
                                            label: "帧数"
                                            value: 80
                                            fieldType: "spin"
                                            from: 1
                                            to: 9999
                                        }
                                        PropertyField {
                                            label: "素材起始帧"
                                            value: 1
                                            fieldType: "spin"
                                            from: 1
                                            to: 9999
                                        }
                                        PropertyField {
                                            label: "素材结束帧"
                                            value: 80
                                            fieldType: "spin"
                                            from: 1
                                            to: 9999
                                        }
                                        PropertyField {
                                            label: "入场帧"
                                            value: 1
                                            fieldType: "spin"
                                            from: 1
                                            to: 9999
                                        }
                                        PropertyField {
                                            label: "出场帧"
                                            value: 80
                                            fieldType: "spin"
                                            from: 1
                                            to: 9999
                                        }
                                        PropertyField {
                                            label: "重复次数"
                                            value: 1
                                            fieldType: "spin"
                                            from: 1
                                            to: 9999
                                        }
                                        RowLayout {
                                            Text {
                                                text: "410 帧"
                                                color: "#CCCCCC"
                                                font.pixelSize: 12
                                                Layout.preferredWidth: 100
                                            }
                                            Button {
                                                text: "追加"
                                                Layout.fillWidth: true
                                                background: Rectangle {
                                                    color: parent.pressed ? "#666666" : "#333333"
                                                    border.color: "#555555"
                                                    border.width: 1
                                                    radius: 3
                                                }
                                            }
                                        }
                                        Button {
                                            text: "生成LED数据"
                                            Layout.fillWidth: true
                                            background: Rectangle {
                                                color: parent.pressed ? "#666666" : "#333333"
                                                border.color: "#555555"
                                                border.width: 1
                                                radius: 3
                                            }
                                            onClicked: {
                                                console.log("开始生成LED数据...")
                                                wiringCanvas.requestPaint()
                                            }
                                        }
                                        Button {
                                            text: "导出效果"
                                            Layout.fillWidth: true
                                            background: Rectangle {
                                                color: parent.pressed ? "#666666" : "#333333"
                                                border.color: "#555555"
                                                border.width: 1
                                                radius: 3
                                            }
                                        }
                                        PropertyField {
                                            label: "混合类型"
                                            value: "黑色透明"
                                            fieldType: "combo"
                                            options: ["黑色透明", "正常", "叠加", "滤色"]
                                        }
                                        PropertyField {
                                            label: "镜像方式"
                                            value: "复制"
                                            fieldType: "combo"
                                            options: ["复制", "镜像", "不镜像"]
                                        }
                                        PropertyField {
                                            label: "横向分区数"
                                            value: 1
                                            fieldType: "spin"
                                            from: 1
                                            to: 10
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            // 预览控制栏
            Rectangle {
                // anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                height: 50
                color: "#252526"
                z: 5

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
                                textContainer.x = textContainerStartX;
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
                                animationPreviewArea.updateScrollAnimation()
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
                        text: animationText.text.length + " 字符"
                        color: "#CCCCCC"
                        font.pixelSize: 12
                    }
                    Text {
                        text: {
                            if (textContainer.width > 0) {
                                var distance = animationPreviewArea.width + textContainer.width
                                var seconds = distance / scrollSpeed
                                return "滚动时长: " + seconds.toFixed(1) + "秒"
                            }
                            return "滚动时长: 0秒"
                        }
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
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.margins: 10
                text: "效果: 文字颜色映射到LED网格，从右向左播放"
                color: "#AAAAAA"
                font.pixelSize: 11
            }

            // 使用自定义控件
            TimeLineControl {
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

    onVisibleChanged: {
        if (visible) {
            var parentWindow = animationEditorDialog.parent
            if (parentWindow) {
                animationEditorDialog.x = (parentWindow.width - width) / 2
                animationEditorDialog.y = (parentWindow.height - height) / 2
            }
            calculateGridParameters();
            textContainer.x = textContainerStartX;
            if (previewPlaying) {
                scrollAnimation.start();
            }

            // 重新绘制LED网格
            wiringCanvas.requestPaint();
        } else {
            scrollAnimation.stop();
        }
    }

    // 确保初始位置正确
    Component.onCompleted: {
        calculateGridParameters();
        textContainer.x = textContainerStartX;
        // 初始绘制LED网格
        wiringCanvas.requestPaint();
    }

    // 监听相关变化
    onQuickWiringConfigChanged: {
        calculateGridParameters();
        if (wiringCanvas) {
            wiringCanvas.requestPaint();
        }
    }

    onTextColorChanged: wiringCanvas.requestPaint();
    onUseGradientChanged: wiringCanvas.requestPaint();
    onGradientStopsChanged: wiringCanvas.requestPaint();
    onPreviewScaleChanged: {
        calculateGridParameters();
        wiringCanvas.requestPaint();
    }

    // 监听预览区域大小变化
    onWidthChanged: {
        calculateGridParameters();
        wiringCanvas.requestPaint();
    }
    onHeightChanged: {
        calculateGridParameters();
        wiringCanvas.requestPaint();
    }
}