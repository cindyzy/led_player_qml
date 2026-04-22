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

    // 文字颜色属性
    property color textColor: "#FF0000"  // 默认红色
    property var gradientStops: []
    property bool useGradient: false

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
                    text: "动画编辑"
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
                    id: previewArea
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
                        z: 1
                    }

                    // 滚动内容的容器
                    Item {
                        id: rollingContainer
                        anchors.fill: parent
                        clip: true

                        // 使用一个可见的Text组件
                        Item {
                            id: textContainer
                            width: textMetrics.width
                            height: Math.max(textMetrics.height, 50)  // 确保最小高度
                            y: (rollingContainer.height - height) / 2
                            x: previewArea.width

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
                                visible: !useGradient
                            }

                            // 渐变文字 - 使用Canvas绘制渐变文字
                            Item {
                                id: gradientTextContainer
                                anchors.fill: parent
                                visible: useGradient

                                // 使用Canvas绘制渐变文字
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

                                    // 当属性变化时重新绘制
                                    onWidthChanged: requestPaint();
                                    onHeightChanged: requestPaint();
                                }

                                // 当相关属性变化时，重新绘制Canvas
                                Connections {
                                    target: animationEditorDialog
                                    function onUseGradientChanged() { gradientCanvas.requestPaint(); }
                                }

                                Connections {
                                    target: animationEditorDialog
                                    function onGradientStopsChanged() { gradientCanvas.requestPaint(); }
                                }

                                Connections {
                                    target: animationEditorDialog
                                    function onTextColorChanged() { gradientCanvas.requestPaint(); }
                                }

                                Connections {
                                    target: animationText
                                    function onTextChanged() { gradientCanvas.requestPaint(); }
                                }

                                Connections {
                                    target: fontNameProperty
                                    function onValueChanged() { gradientCanvas.requestPaint(); }
                                }

                                Connections {
                                    target: fontSizeProperty
                                    function onValueChanged() { gradientCanvas.requestPaint(); }
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
                    PropertyAnimation {
                        id: scrollAnimation
                        target: textContainer
                        property: "x"
                        from: previewArea.width
                        to: -textContainer.width
                        duration: (previewArea.width + textContainer.width) / scrollSpeed * 1000
                        loops: Animation.Infinite
                        running: previewPlaying
                    }

                    // 更新滚动动画
                    function updateScrollAnimation() {
                        var wasPlaying = scrollAnimation.running
                        scrollAnimation.stop()
                        scrollAnimation.from = previewArea.width
                        scrollAnimation.to = -textContainer.width
                        scrollAnimation.duration = (previewArea.width + textContainer.width) / scrollSpeed * 1000

                        if (wasPlaying) {
                            textContainer.x = previewArea.width
                            scrollAnimation.start()
                        }
                    }

                    // 预览控制栏
                    Rectangle {
                        anchors.bottom: parent.bottom
                        anchors.left: parent.left
                        anchors.right: parent.right
                        height: 40
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
                                        textContainer.x = previewArea.width
                                        scrollAnimation.start()
                                    } else {
                                        scrollAnimation.stop()
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
                                        previewArea.updateScrollAnimation()
                                    }
                                }
                                Label {
                                    text: Math.round(scrollSpeed) + " px/s"
                                    color: "#CCCCCC"
                                    font.pixelSize: 12
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
                                        var distance = previewArea.width + textContainer.width
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
                                text: "总帧数:80  总时长:00:00:04"
                                color: "#999999"
                                font.pixelSize: 12
                            }
                        }
                    }

                    // 监听文字变化
                    Connections {
                        target: animationText
                        function onTextChanged() {
                            previewArea.updateScrollAnimation()
                        }
                    }

                    Connections {
                        target: fontNameProperty
                        function onValueChanged() {
                            previewArea.updateScrollAnimation()
                        }
                    }

                    Connections {
                        target: fontSizeProperty
                        function onValueChanged() {
                            previewArea.updateScrollAnimation()
                        }
                    }

                    onWidthChanged: previewArea.updateScrollAnimation()
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
                                            }
                                        }
                                        ColorSwatch {
                                            swatchColor: "#FF9900"
                                            onSwatchClicked: {
                                                useGradient = false
                                                textColor = swatchColor
                                            }
                                        }
                                        ColorSwatch {
                                            swatchColor: "#FFFF00"
                                            onSwatchClicked: {
                                                useGradient = false
                                                textColor = swatchColor
                                            }
                                        }
                                        ColorSwatch {
                                            swatchColor: "#00FF00"
                                            onSwatchClicked: {
                                                useGradient = false
                                                textColor = swatchColor
                                            }
                                        }
                                        ColorSwatch {
                                            swatchColor: "#0000FF"
                                            onSwatchClicked: {
                                                useGradient = false
                                                textColor = swatchColor
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
                                                textContainer.x = previewArea.width
                                                scrollAnimation.start()
                                            } else {
                                                scrollAnimation.stop()
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
                                    text: "请输入文字"
                                    color: "white"
                                    background: Rectangle {
                                        color: "#333333"
                                        border.color: "#555555"
                                    }
                                    Layout.fillWidth: true
                                    onTextChanged: {
                                        previewArea.updateScrollAnimation()
                                    }
                                }

                                PropertyGroup {
                                    title: "预览属性"
                                    expanded: true
                                    ColumnLayout {
                                        PropertyField {
                                            label: "布线遮罩"
                                            value: "是"
                                            fieldType: "combo"
                                            options: ["是", "否"]
                                        }
                                        PropertyField {
                                            label: "显示比例"
                                            value: "800%"
                                            fieldType: "label"
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
                                                previewArea.updateScrollAnimation()
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
                                                previewArea.updateScrollAnimation()
                                            }
                                        }
                                        PropertyField {
                                            label: "素材名称"
                                            value: "炫彩文字2"
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
                                            text: "生成外置色带模板"
                                            Layout.fillWidth: true
                                            background: Rectangle {
                                                color: parent.pressed ? "#666666" : "#333333"
                                                border.color: "#555555"
                                                border.width: 1
                                                radius: 3
                                            }
                                        }
                                        Button {
                                            text: "修改"
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

            // 底部时间轴
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 100
                color: "#252526"
                border.color: "#3E3E3E"
                border.width: 1
                ColumnLayout {
                    anchors.fill: parent
                    spacing: 5
                    anchors.margins: 10
                    Text {
                        text: "素材编辑·炫彩文字2"
                        color: "#FFFFFF"
                        font.bold: true
                        font.pixelSize: 12
                    }
                    RowLayout {
                        Text {
                            text: "总帧数:80"
                            color: "#CCCCCC"
                            font.pixelSize: 12
                        }
                        Text {
                            text: "总时长:00:00:04"
                            color: "#CCCCCC"
                            font.pixelSize: 12
                        }
                        Item { Layout.fillWidth: true }
                        Text {
                            text: "轴标:"
                            color: "#CCCCCC"
                            font.pixelSize: 12
                        }
                        Text {
                            text: "1"
                            color: "#FFFFFF"
                            font.bold: true
                            font.pixelSize: 12
                        }
                    }
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        color: "#333333"
                        border.color: "#555555"
                        border.width: 1
                        radius: 3
                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 5
                            spacing: 0
                            Repeater {
                                model: 20
                                Item {
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    Rectangle {
                                        width: 1
                                        height: 10
                                        color: "#666666"
                                        anchors.bottom: parent.bottom
                                        anchors.horizontalCenter: parent.horizontalCenter
                                    }
                                    Text {
                                        text: index * 5
                                        color: "#999999"
                                        font.pixelSize: 8
                                        anchors.top: parent.top
                                        anchors.horizontalCenter: parent.horizontalCenter
                                    }
                                }
                            }
                        }
                        Rectangle {
                            width: 2
                            height: parent.height
                            color: "#FF0000"
                            x: parent.width * 0.85
                        }
                    }
                }
            }
        Rectangle{
            Layout.fillWidth: true
            Layout.preferredHeight: 100
            ColumnLayout {
                anchors.fill: parent
                spacing: 5
                anchors.margins: 10
            Button{
                id:acceptBtn
                text: "确定"
                onClicked: {

                }
            }
            Button{
                id:cancerBtn
                text:"取消"
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
            textContainer.x = previewArea.width
            if (previewPlaying) {
                scrollAnimation.start()
            }
        } else {
            scrollAnimation.stop()
        }
    }

    // 确保初始位置正确
    Component.onCompleted: {
        textContainer.x = previewArea.width
    }
}