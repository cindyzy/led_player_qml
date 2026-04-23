import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts
import QtQuick.Dialogs
import QtQuick.Shapes
import QtQuick.Window
import "../components"
import "../components/animationEditor"
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
    property int charWidthLeds: 16      // 每个字符占用的 LED 列数
    property int charHeightLeds: 16     // 每个字符占用的 LED 行数
    property int spacingCols: 1        // 字符之间的间隔列数
    property var charBitmapCache: ({})  // 缓存字符的点阵数据

    function getCharBitmapDynamic(ledchar, fontSize, fontFamily) {
        const width = 16;   // 点阵宽度
        const height = 16;  // 点阵高度
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
            const midRow = Math.floor(height / 2); // 第8行（0-index）
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
            // D：左竖线 + 顶横线 + 底横线 + 右侧弧线（通过正弦曲线模拟圆弧）
            for (let i = 0; i < height; i++) {
                let row = [];
                // 左侧竖线
                row.push(1);
                // 中间列（1 到 width-2）
                for (let j = 1; j < width - 1; j++) {
                    let isSet = 0;
                    // 顶横线（第0行，从列1到列13）
                    if (i === 0 && j <= 13) isSet = 1;
                    // 底横线（第15行，整行除最右侧留空一点，也可全画）
                    else if (i === height - 1 && j <= 14) isSet = 1;
                    // 右侧弧线：根据行号计算弧线上的列位置
                    else if (i > 0 && i < height - 1) {
                        // 弧度从顶部到底部，中间凸出到最大列（列14或15）
                        let t = (i / (height - 1)) * Math.PI; // t 范围 0 到 PI
                        let rightBound = Math.floor(11 + 4 * Math.sin(t)); // 弧线从列11逐渐到列15再回落到列11
                        if (j === rightBound) isSet = 1;
                    }
                    row.push(isSet);
                }
                // 最后一列（列15）通常为0，保持轮廓清晰
                row.push(0);
                bitmap.push(row);
            }
        }
        else {
            // 默认生成16x16边框（四周为1，内部为0）
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

        console.log("bitmaps:" + ledchar, bitmap);
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
                var bitmap = getCharBitmapDynamic(ch,fontSizeProperty.value,fontNameProperty.value);
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
                        Canvas {
                            id: offscreenCharCanvas
                            visible: false
                            // 尺寸会在函数中动态调整
                            Component.onCompleted: {
                                offscreenCharCanvas.getContext('2d');  // 提前初始化
                                calculateGridParameters();
                                textContainer.x = textContainerStartX;
                                wiringCanvas.requestPaint();
                            }
                        }
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
                                // ctx.strokeStyle = "#FF0000";
                                // ctx.lineWidth = 2;
                                // ctx.strokeRect(textContainer.x, gridOffsetY, textContainer.width, gridTotalHeight);
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
                        // 色带编辑面板 (右中) - 使用修复后的版本
                        ColorBandEditorPanel {
                            id: colorBandPanel
                            Layout.row: 1
                            Layout.column: 1
                            Layout.fillWidth: true
                            Layout.preferredHeight: 250

                            // 绑定到当前动画的色带相关属性
                            gradients: currentAnimation.gradients || []
                            currentGradientIndex: 0
                            useGradient: currentAnimation.colorSettings ? currentAnimation.colorSettings.useGradient : true
                            textColor: currentAnimation.colorSettings ? currentAnimation.colorSettings.textColor : "#FF0000"
                            previewPlaying: animationEditorDialog.previewPlaying
                            selectedTemplate: currentAnimation.colorSettings ? currentAnimation.colorSettings.selectedTemplate : "模板1"
                            gradientStops: currentAnimation.colorSettings ? currentAnimation.colorSettings.gradientStops : []

                            // 信号处理
                            onGradientSelected: function(index, gradient) {
                                console.log("色带选择: 索引=" + index + ", 渐变=" + JSON.stringify(gradient));

                                // 更新当前选中的渐变索引
                                currentGradientIndex = index;

                                // 如果选择了渐变，则更新颜色设置
                                if (gradient && currentAnimation.colorSettings) {
                                    currentAnimation.colorSettings.useGradient = true;
                                    currentAnimation.colorSettings.gradientStops = gradient;
                                    colorBandPanel.useGradient = true;
                                    colorBandPanel.gradientStops = gradient;

                                    // 发出信号通知渐变被应用
                                    gradientApplied(gradient);

                                }
                            }

                            onColorSelected: function(color) {
                                console.log("颜色选择: " + color);

                                // 更新当前动画的颜色设置
                                if (currentAnimation.colorSettings) {
                                    currentAnimation.colorSettings.useGradient = false;
                                    currentAnimation.colorSettings.textColor = color;
                                    colorBandPanel.useGradient = false;
                                    colorBandPanel.textColor = color;

                                    // 发出颜色选择信号
                                    colorSelected(color);
                                }

                                // 更新画布显示
                                // updateWiringCanvas();
                                wiringCanvas.requestPaint()
                            }

                            onTemplateChanged: function(templateName) {
                                console.log("模板变更: " + templateName);

                                // 更新当前动画的模板设置
                                if (currentAnimation.colorSettings) {
                                    currentAnimation.colorSettings.selectedTemplate = templateName;
                                }

                                // 发出模板变更信号
                                templateChanged(templateName);

                                // 根据模板加载预设
                                // loadTemplate(templateName);
                            }



                            onCanvasRepaintRequested: function() {
                                console.log("色带面板请求重绘画布");
                                updateWiringCanvas();
                            }


                            onGradientApplied: function(gradient) {
                                            console.log("渐变应用: " + JSON.stringify(gradient));

                                            // 将渐变添加到当前动画的渐变列表中
                                            // if (!currentAnimation.gradients) {
                                            //     currentAnimation.gradients = [];
                                            // }

                                            // // 检查是否已存在相同的渐变
                                            // var exists = false;
                                            // for (var i = 0; i < currentAnimation.gradients.length; i++) {
                                            //     if (JSON.stringify(currentAnimation.gradients[i].stops) === JSON.stringify(gradient)) {
                                            //         exists = true;
                                            //         break;
                                            //     }
                                            // }

                                            // if (!exists) {
                                            //     // 添加新渐变
                                            //     var newGradient = {
                                            //         "id": Date.now(),
                                            //         "name": "自定义渐变" + (currentAnimation.gradients.length + 1),
                                            //         "stops": gradient
                                            //     };
                                            //     currentAnimation.gradients.push(newGradient);

                                            //     // 更新当前选中的渐变索引
                                            //     currentGradientIndex = currentAnimation.gradients.length - 1;
                                            // }

                                            // // 更新颜色设置
                                            // if (currentAnimation.colorSettings) {
                                            //     currentAnimation.colorSettings.useGradient = true;
                                            //     currentAnimation.colorSettings.gradientStops = gradient;
                                            // }

                                            // 发出渐变应用信号
                                            gradientApplied(gradient);

                                            // 更新画布显示
                                            wiringCanvas.requestPaint()
                                        }
                        }



                        // 属性设置面板 (右上) - 这是重点区域
                                    PropertySettingsPanel {
                                        id: propertyPanel
                                        Layout.row: 0
                                        Layout.column: 1
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: 350

                                        // 绑定到当前动画的文本属性
                                        currentItemProperties: currentAnimation.textProperties || {}
                                        animationParameters: currentAnimation.properties || {}

                                        // 绑定到快速布线配置
                                        quickWiringConfig: {
                                            "width": currentAnimation.textProperties ? currentAnimation.textProperties.gridWidth || 16 : 16,
                                            "height": currentAnimation.textProperties ? currentAnimation.textProperties.gridHeight || 8 : 8
                                        }

                                        // 属性变更处理
                                        onPropertyChanged: function(name, value) {
                                            console.log("属性变更: " + name + " = " + value);

                                            // 更新当前动画的文本属性
                                            if (currentAnimation.textProperties) {
                                                currentAnimation.textProperties[name] = value;
                                            }

                                            // 如果当前在时间轴上选中了项目，也更新该项目的属性
                                            if (timelinePanel.selectedItem) {
                                                timelinePanel.selectedItem.properties[name] = value;
                                            }

                                            // 发出全局属性变更信号
                                            propertyValueChanged(name, value);

                                            // 如果是网格相关属性，更新画布
                                            if (name === "gridWidth" || name === "gridHeight" ||
                                                name === "fontName" || name === "fontSize") {
                                                updateWiringCanvas();
                                            }

                                            // 如果是帧数相关属性，重新计算总帧数
                                            if (name === "startFrame" || name === "endFrame") {
                                                var totalFrames = calculateTotalFrames();
                                                console.log("更新总帧数: " + totalFrames + " 帧");
                                            }
                                        }

                                        // 文本内容变更处理
                                        onTextChanged: function(newText) {
                                            console.log("文本内容变更: " + newText);

                                            // 更新动画属性
                                            if (currentAnimation.textProperties) {
                                                currentAnimation.textProperties.text = newText;
                                            }

                                            // 发出文本变更信号
                                            textContentChanged(newText);

                                            // 重新计算容器宽度
                                            var newWidth = updateTextContainerWidth(newText);
                                            console.log("新宽度: " + newWidth);

                                            // 更新画布
                                            updateWiringCanvas();

                                            // 如果时间轴上有选中的项目，也更新其文本
                                            if (timelinePanel.selectedItem) {
                                                timelinePanel.selectedItem.properties.text = newText;
                                                timelinePanel.selectedItem.name = newText.substring(0, 20) + "...";
                                            }
                                        }

                                        // 生成LED数据处理
                                        onGenerateLedData: function() {
                                            console.log("生成LED数据请求");

                                            // 收集所有必要的参数
                                            var params = {
                                                "text": currentAnimation.textProperties.text || "",
                                                "gridWidth": currentAnimation.textProperties.gridWidth || 16,
                                                "gridHeight": currentAnimation.textProperties.gridHeight || 8,
                                                "fontName": currentAnimation.textProperties.fontName || "宋体",
                                                "fontSize": currentAnimation.textProperties.fontSize || 54,
                                                "animationName": currentAnimation.properties.name || "未命名"
                                            };

                                            // 发出生成LED数据信号
                                            generateLedDataRequested();

                                            // 显示生成进度
                                            generateProgressDialog.open();

                                            // 模拟生成过程
                                            generateTimer.start();
                                        }

                                        // 导出效果处理
                                        onExportEffect: function() {
                                            console.log("导出效果请求");

                                            // 准备导出数据
                                            var exportData = {
                                                "animation": currentAnimation,
                                                "timestamp": new Date().toISOString(),
                                                "version": "1.0"
                                            };

                                            // 发出导出信号
                                            exportEffectRequested();

                                            // 显示导出对话框
                                            exportDialog.open();
                                        }

                                        // 画布重绘请求处理
                                        onCanvasRepaintRequested: function() {
                                            console.log("画布重绘请求");
                                            updateWiringCanvas();
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
            MaterialTimelinePanel {
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
                updateLEDTimer.start();
            }

            // 重新绘制LED网格
            wiringCanvas.requestPaint();
        } else {
            updateLEDTimer.stop();
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