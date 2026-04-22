// AnimationEditorDialog.qml
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
    // modal: true
    // focus: true
    // closePolicy: Popup.CloseOnEscape
    width: 1200
    height: 800
    property bool dragging: false
    property point startDragPos: Qt.point(0, 0)

    // 预览动画播放状态
    property bool previewPlaying: false

    // 背景遮罩
    // background: Rectangle {
    //     color: "#80000000"
    // }

    // 主内容容器
    Rectangle {
        id: popupContainer
        width: parent.width
        height: parent.height
        color: "#1E1E1E"
        border.color: "#3E3E3E"
        border.width: 2
        radius: 8

        // 可拖动区域（修复参数声明）
        MouseArea {
            id: dragArea
            anchors.fill: parent
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

            // 中间主体区域
            RowLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 0

                // 左侧预览区域（文字滚动）
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

                    Item {
                        id: rollingContainer
                        anchors.fill: parent
                        clip: true

                        // 渐变文字实现
                        Item {
                            id: rollingText
                            property string text: animationText.text
                            property var gradientStops: []
                            property var font: ({ family: fontNameProperty ? fontNameProperty.value : "宋体", pixelSize: fontSizeProperty ? parseInt(fontSizeProperty.value) : 54 })
                            property real x: previewArea.width
                            property real y: (parent.height - textItem.height) / 2
                            width: textItem.width
                            height: textItem.height
                            ShaderEffect {
                                id: gradTextEffect
                                anchors.fill: parent
                                property variant source: textItem
                                property variant grad: gradRect
                                fragmentShader: "uniform sampler2D source;\nuniform sampler2D grad;\nvarying vec2 qt_TexCoord0;\nvoid main() {\n    vec4 mask = texture2D(source, qt_TexCoord0);\n    vec4 color = texture2D(grad, qt_TexCoord0);\n    gl_FragColor = vec4(color.rgb, mask.a);\n}"
                            }
                            Text {
                                id: textItem
                                text: rollingText.text
                                font.family: rollingText.font.family
                                font.pixelSize: rollingText.font.pixelSize
                                color: "white"
                                verticalAlignment: Text.AlignVCenter
                                horizontalAlignment: Text.AlignLeft
                                visible: false
                            }
                            Rectangle {
                                id: gradRect
                                width: textItem.width
                                height: textItem.height
                                visible: false
                                gradient: LinearGradient {
                                    x1: 0; y1: 0; x2: gradRect.width; y2: 0
                                    Component.onCompleted: {
                                        for (var i = 0; i < rollingText.gradientStops.length; ++i) {
                                            gradient.append(Qt.createQmlObject('import QtQuick 2.0; GradientStop { position: ' + rollingText.gradientStops[i].position + '; color: "' + rollingText.gradientStops[i].color + '" }', gradient, ""));
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // 滚动动画（循环）
                    SequentialAnimation {
                        id: scrollAnim
                        loops: Animation.Infinite
                        running: false

                        NumberAnimation {
                            id: moveAnim
                            target: rollingText
                            property: "x"
                            from: previewArea.width
                            to: -rollingText.width
                            duration: (previewArea.width + rollingText.width) / 200 * 1000
                            easing.type: Easing.Linear
                        }

                        ScriptAction {
                            script: {
                                rollingText.x = previewArea.width
                            }
                        }
                    }

                    // 更新动画参数
                    function updateScrollAnimation() {
                        var wasPlaying = scrollAnim.running
                        scrollAnim.stop()
                        rollingText.x = previewArea.width
                        moveAnim.from = previewArea.width
                        moveAnim.to = -rollingText.width
                        moveAnim.duration = (previewArea.width + rollingText.width) / 200 * 1000
                        if (wasPlaying) scrollAnim.start()
                    }

                    // 监听文本内容变化
                    Connections {
                        target: animationText
                        function onTextChanged() {
                            previewArea.updateScrollAnimation()
                        }
                    }

                    // 监听字体变化
                    Connections {
                        target: fontNameProperty
                        function onValueChanged() {
                            rollingText.font.family = fontNameProperty.value
                            previewArea.updateScrollAnimation()
                        }
                    }
                    Connections {
                        target: fontSizeProperty
                        function onValueChanged() {
                            rollingText.font.pixelSize = parseInt(fontSizeProperty.value)
                            previewArea.updateScrollAnimation()
                        }
                    }

                    onWidthChanged: previewArea.updateScrollAnimation()
                    onHeightChanged: {
                        rollingText.y = (rollingContainer.height - rollingText.height) / 2
                    }

                    Connections {
                        target: rollingText
                        function onHeightChanged() {
                            rollingText.y = (rollingContainer.height - rollingText.height) / 2
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
                                id: previewButton
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
                                    if (previewPlaying) {
                                        scrollAnim.stop()
                                        previewPlaying = false
                                    } else {
                                        rollingText.x = previewArea.width
                                        scrollAnim.start()
                                        previewPlaying = true
                                    }
                                }
                            }

                            Text {
                                text: rollingText.text.length + " 字符"
                                color: "#CCCCCC"
                                font.pixelSize: 12
                            }

                            Text {
                                text: {
                                    var distance = previewArea.width + rollingText.width
                                    var seconds = distance / 200
                                    return "滚动时长: " + Math.floor(seconds) + "秒"
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
                }

                // 右侧面板（保持不变）
                Rectangle {
                    Layout.preferredWidth: 400
                    Layout.fillHeight: true
                    color: "#252526"
                    border.color: "#3E3E3E"
                    border.width: 1

                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 0

                        // 色带编辑
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
                                        // 渐变色带仿照截图
                                        GradientSwatch {
                                            gradientStops: [
                                                {color: "#FF0000", position: 0.0},
                                                {color: "#FFFF00", position: 0.5},
                                                {color: "#00FF00", position: 1.0}
                                            ]
                                            onSwatchClicked: rollingText.gradientStops = gradientStops
                                        }
                                        GradientSwatch {
                                            gradientStops: [
                                                {color: "#0000FF", position: 0.0},
                                                {color: "#00FFFF", position: 0.5},
                                                {color: "#FFFFFF", position: 1.0}
                                            ]
                                            onSwatchClicked: rollingText.gradientStops = gradientStops
                                        }
                                        GradientSwatch {
                                            gradientStops: [
                                                {color: "#FF00FF", position: 0.0},
                                                {color: "#FFFF00", position: 0.5},
                                                {color: "#00FFFF", position: 1.0}
                                            ]
                                            onSwatchClicked: rollingText.gradientStops = gradientStops
                                        }
                                        GradientSwatch {
                                            gradientStops: [
                                                {color: "#FF0000", position: 0.0},
                                                {color: "#FFFFFF", position: 1.0}
                                            ]
                                            onSwatchClicked: rollingText.gradientStops = gradientStops
                                        }
                                        GradientSwatch {
                                            gradientStops: [
                                                {color: "#000000", position: 0.0},
                                                {color: "#00FF00", position: 0.5},
                                                {color: "#0000FF", position: 1.0}
                                            ]
                                            onSwatchClicked: rollingText.gradientStops = gradientStops
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
                                            onSwatchClicked: rollingText.color = swatchColor
                                        }
                                        ColorSwatch {
                                            swatchColor: "#FF9900"
                                            onSwatchClicked: rollingText.color = swatchColor
                                        }
                                        ColorSwatch {
                                            swatchColor: "#FFFF00"
                                            onSwatchClicked: rollingText.color = swatchColor
                                        }
                                        ColorSwatch {
                                            swatchColor: "#00FF00"
                                            onSwatchClicked: rollingText.color = swatchColor
                                        }
                                        ColorSwatch {
                                            swatchColor: "#0000FF"
                                            onSwatchClicked: rollingText.color = swatchColor
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
                                                width: 30; height: 20
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
                                            border.color: "#555555"; border.width: 1; radius: 3
                                        }
                                        contentItem: Text {
                                            text: parent.text; color: "#CCCCCC"; font.pixelSize: 12
                                            horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter
                                        }
                                        onClicked: {
                                            if (previewPlaying) {
                                                scrollAnim.stop()
                                                previewPlaying = false
                                            } else {
                                                rollingText.x = previewArea.width
                                                scrollAnim.start()
                                                previewPlaying = true
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
                                TextEdit {
                                    id: animationText
                                    text: "请输入文字"
                                    color: "yellow"
                                }

                                PropertyGroup {
                                    title: "预览属性"
                                    expanded: true
                                    Layout.fillWidth: true
                                    ColumnLayout {
                                        spacing: 8
                                        PropertyField { label: "布线遮罩"; value: "是"; fieldType: "combo"; options: ["是", "否"] }
                                        PropertyField { label: "显示比例"; value: "800%"; fieldType: "label" }
                                    }
                                }

                                PropertyGroup {
                                    title: "基本属性"
                                    expanded: true
                                    Layout.fillWidth: true
                                    ColumnLayout {
                                        spacing: 8
                                        Text { text: "字体设置"; color: "#D4D4D4"; font.bold: true; font.pixelSize: 12 }
                                        RowLayout {
                                            Layout.fillWidth: true; spacing: 8
                                            Text { text: "宋体"; color: "#CCCCCC"; font.pixelSize: 12; Layout.preferredWidth: 100 }
                                            Text { text: "更多"; color: "#007ACC"; font.pixelSize: 12; Layout.fillWidth: true }
                                        }
                                        PropertyField {
                                            id: fontNameProperty
                                            label: "字体名称"; value: "宋体"; fieldType: "combo"
                                            options: ["宋体", "微软雅黑", "黑体", "楷体"]
                                        }
                                        PropertyField {
                                            id: fontSizeProperty
                                            label: "字体大小"; value: 54; fieldType: "spin"; from: 1; to: 200
                                        }
                                        PropertyField { label: "素材名称"; value: "炫彩文字2"; fieldType: "text" }
                                        PropertyField { label: "起点X坐标"; value: 0; fieldType: "spin"; from: 0; to: 9999 }
                                        PropertyField { label: "起点Y坐标"; value: 0; fieldType: "spin"; from: 0; to: 9999 }
                                        PropertyField { label: "素材宽度"; value: 60; fieldType: "spin"; from: 1; to: 9999 }
                                        PropertyField { label: "素材高度"; value: 270; fieldType: "spin"; from: 1; to: 9999 }
                                        PropertyField { label: "帧数"; value: 80; fieldType: "spin"; from: 1; to: 9999 }
                                        PropertyField { label: "素材起始帧"; value: 1; fieldType: "spin"; from: 1; to: 9999 }
                                        PropertyField { label: "素材结束帧"; value: 80; fieldType: "spin"; from: 1; to: 9999 }
                                        PropertyField { label: "入场帧"; value: 1; fieldType: "spin"; from: 1; to: 9999 }
                                        PropertyField { label: "出场帧"; value: 80; fieldType: "spin"; from: 1; to: 9999 }
                                        PropertyField { label: "重复次数"; value: 1; fieldType: "spin"; from: 1; to: 9999 }
                                        RowLayout {
                                            Layout.fillWidth: true; spacing: 8
                                            Text { text: "410 帧"; color: "#CCCCCC"; font.pixelSize: 12; Layout.preferredWidth: 100 }
                                            Button {
                                                text: "追加"; Layout.fillWidth: true
                                                background: Rectangle { color: parent.pressed ? "#666666" : "#333333"; border.color: "#555555"; border.width: 1; radius: 3 }
                                                contentItem: Text { text: parent.text; color: "#CCCCCC"; font.pixelSize: 12; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                                            }
                                        }
                                        Button {
                                            text: "生成外置色带模板"; Layout.fillWidth: true
                                            background: Rectangle { color: parent.pressed ? "#666666" : "#333333"; border.color: "#555555"; border.width: 1; radius: 3 }
                                            contentItem: Text { text: parent.text; color: "#CCCCCC"; font.pixelSize: 12; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                                        }
                                        Button {
                                            text: "修改"; Layout.fillWidth: true
                                            background: Rectangle { color: parent.pressed ? "#666666" : "#333333"; border.color: "#555555"; border.width: 1; radius: 3 }
                                            contentItem: Text { text: parent.text; color: "#CCCCCC"; font.pixelSize: 12; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                                        }
                                        PropertyField { label: "混合类型"; value: "黑色透明"; fieldType: "combo"; options: ["黑色透明", "正常", "叠加", "滤色"] }
                                        PropertyField { label: "镜像方式"; value: "复制"; fieldType: "combo"; options: ["复制", "镜像", "不镜像"] }
                                        PropertyField { label: "横向分区数"; value: 1; fieldType: "spin"; from: 1; to: 10 }
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // 底部时间轴区域（保持不变）
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

                    Text { text: "素材编辑·炫彩文字2"; color: "#FFFFFF"; font.bold: true; font.pixelSize: 12 }
                    RowLayout {
                        Layout.fillWidth: true
                        Text { text: "总帧数:80"; color: "#CCCCCC"; font.pixelSize: 12 }
                        Text { text: "总时长:00:00:04"; color: "#CCCCCC"; font.pixelSize: 12 }
                        Item { Layout.fillWidth: true }
                        Text { text: "轴标:"; color: "#CCCCCC"; font.pixelSize: 12 }
                        Text { text: "1"; color: "#FFFFFF"; font.bold: true; font.pixelSize: 12 }
                    }
                    Rectangle {
                        Layout.fillWidth: true; Layout.fillHeight: true
                        color: "#333333"; border.color: "#555555"; border.width: 1; radius: 3
                        RowLayout {
                            anchors.fill: parent; anchors.margins: 5; spacing: 0
                            Repeater {
                                model: 20
                                Item {
                                    Layout.fillWidth: true; Layout.fillHeight: true
                                    Rectangle { width: 1; height: 10; color: "#666666"; anchors.bottom: parent.bottom; anchors.horizontalCenter: parent.horizontalCenter }
                                    Text { text: index * 5; color: "#999999"; font.pixelSize: 8; anchors.top: parent.top; anchors.horizontalCenter: parent.horizontalCenter }
                                }
                            }
                        }
                        Rectangle { width: 2; height: parent.height; color: "#FF0000"; x: parent.width * 0.85 }
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
            scrollAnim.start()
        }
    }
}