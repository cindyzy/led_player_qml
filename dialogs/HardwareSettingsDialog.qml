import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15
import QtQuick.Layouts 1.15
import QtQuick.Dialogs

Popup {
    id: hardwareSettingsDialog
    width: 900
    height: 700
    modal: true
    focus: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent
    anchors.centerIn: Overlay.overlay
    padding: 0

    property int dragMouseX: 0
    property int dragMouseY: 0
    property int projectWidth: 72
    property int projectHeight: 8
    property string controllerType: "SY系列"
    property string controllerModel: "SY-418"
    property string chipType: "TM1804"
    property int channelCount: 3
    property bool outputSDCard: false
    property bool controllerReplication: false
    property bool portReplication: false
    property bool dragging: false

    signal settingsApplied(var settings)
    signal settingsCancelled()

    // 背景
    background: Rectangle {
        color: "#1e1e1e"
        border.color: "#404040"
        border.width: 1
    }

    // 可拖动的标题栏
    Rectangle {
        id: titleBar
        width: parent.width
        height: 50
        color: "#2d2d2d"
        border.color: "#404040"
        border.width: 0
        // border.bottomWidth: 1

        // 标题
        Text {
            text: "硬件设置"
            color: "#FFFFFF"
            font.pixelSize: 18
            font.bold: true
            anchors.left: parent.left
            anchors.leftMargin: 20
            anchors.verticalCenter: parent.verticalCenter
        }

        // 关闭按钮
        Rectangle {
            id: closeButton
            width: 30
            height: 30
            color: "transparent"
            anchors {
                verticalCenter: parent.verticalCenter
                right: parent.right
                rightMargin: 10
            }

            Canvas {
                anchors.fill: parent
                onPaint: {
                    var context = getContext("2d")
                    context.reset()
                    context.strokeStyle = "#FFFFFF"
                    // context.lineWidth: 2
                    context.beginPath()
                    context.moveTo(5, 5)
                    context.lineTo(25, 25)
                    context.moveTo(25, 5)
                    context.lineTo(5, 25)
                    context.stroke()
                }
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    settingsCancelled()
                    hardwareSettingsDialog.close()
                }

                onEntered: {
                    closeButton.opacity = 0.7
                }

                onExited: {
                    closeButton.opacity = 1.0
                }
            }
        }

        // 拖动区域
        MouseArea {
            id: dragArea
            anchors.fill: parent
            cursorShape: Qt.SizeAllCursor

            onPressed: {
                dragging = true
                startDragPos = Qt.point(mouse.x, mouse.y)
            }

            onPositionChanged: {
                if (dragging) {
                    var deltaX = mouse.x - startDragPos.x
                    var deltaY = mouse.y - startDragPos.y
                    hardwareSettingsDialog.x += deltaX
                    hardwareSettingsDialog.y += deltaY
                }
            }

            onReleased: {
                dragging = false
            }
        }

    }

    // 主内容区域
    RowLayout {
        anchors {
            top: titleBar.bottom
            left: parent.left
            right: parent.right
            bottom: buttonsRow.top
            margins: 10
        }
        spacing: 10

        // 左侧控制器列表区域
        Rectangle {
            Layout.preferredWidth: 200
            Layout.fillHeight: true
            color: "#2d2d2d"
            radius: 4

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 8
                spacing: 8

                Label {
                    text: "控制器列表"
                    font.bold: true
                    font.pixelSize: 14
                    color: "white"
                    Layout.alignment: Qt.AlignLeft
                }

                ListView {
                    id: controllerList
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    model: ListModel {
                        ListElement { name: "主控制器" }
                        ListElement { name: "控制器1" }
                        ListElement { name: "控制器2" }
                    }
                    delegate: Rectangle {
                        width: ListView.view.width
                        height: 30
                        color: index === 0 ? "#3d3d3d" : "transparent"
                        radius: 3

                        Label {
                            text: name
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                            anchors.leftMargin: 8
                            color: "white"
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: controllerList.currentIndex = index
                        }
                    }
                    highlight: Rectangle {
                        color: "#4d4d4d"
                        radius: 3
                    }
                }
            }
        }

        // 右侧设置区域
        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true

            ColumnLayout {
                width: parent.width
                spacing: 15

                // 项目设置
                GroupBox {
                    title: "项目设置"
                    Layout.fillWidth: true

                    background: Rectangle {
                        color: "#2d2d2d"
                        radius: 4
                        border.color: "#404040"
                        border.width: 1
                    }

                    GridLayout {
                        columns: 2
                        columnSpacing: 20
                        rowSpacing: 10

                        Label { text: "宽度"; color: "white" }
                        TextField {
                            id: widthField
                            text: "72"
                            Layout.preferredWidth: 150
                            Material.background: "#3d3d3d"
                            Material.foreground: "white"
                        }

                        Label { text: "高度"; color: "white" }
                        TextField {
                            id: heightField
                            text: "8"
                            Layout.preferredWidth: 150
                            Material.background: "#3d3d3d"
                            Material.foreground: "white"
                        }
                    }
                }

                // 控制器设置
                GroupBox {
                    title: "控制器设置"
                    Layout.fillWidth: true

                    background: Rectangle {
                        color: "#2d2d2d"
                        radius: 4
                        border.color: "#404040"
                        border.width: 1
                    }

                    GridLayout {
                        columns: 2
                        columnSpacing: 20
                        rowSpacing: 10

                        Label { text: "主控类型"; color: "white" }
                        ComboBox {
                            model: ["SY系列", "其他系列"]
                            currentIndex: 0
                            Layout.preferredWidth: 200
                            Material.background: "#3d3d3d"
                            Material.foreground: "white"
                        }

                        Label { text: "主控型号"; color: "white" }
                        ComboBox {
                            model: ["SY-418", "SY-416", "SY-420"]
                            currentIndex: 0
                            Layout.preferredWidth: 200
                            Material.background: "#3d3d3d"
                            Material.foreground: "white"
                        }

                        Label { text: "分控型号"; color: "white" }
                        ComboBox {
                            Layout.preferredWidth: 200
                            Material.background: "#3d3d3d"
                            Material.foreground: "white"
                        }

                        Label { text: "驱动点数"; color: "white" }
                        TextField {
                            text: "72"
                            Layout.preferredWidth: 150
                            Material.background: "#3d3d3d"
                            Material.foreground: "white"
                        }

                        Label { text: "端口数："; color: "gray"; font.pixelSize: 12 }
                        Label { text: "8端口"; color: "lightgray"; Layout.alignment: Qt.AlignLeft }

                        Label {
                            text: "注：驱动点数不超过72"
                            color: "#FFA500"
                            font.pixelSize: 12
                            Layout.columnSpan: 2
                        }
                    }
                }

                // 芯片设置
                GroupBox {
                    title: "芯片设置"
                    Layout.fillWidth: true

                    background: Rectangle {
                        color: "#2d2d2d"
                        radius: 4
                        border.color: "#404040"
                        border.width: 1
                    }

                    GridLayout {
                        columns: 4
                        columnSpacing: 20
                        rowSpacing: 10

                        Label { text: "芯片类型"; color: "white" }
                        ComboBox {
                            model: ["TM1804", "WS2812", "SK6812"]
                            currentIndex: 0
                            Layout.preferredWidth: 150
                            Material.background: "#3d3d3d"
                            Material.foreground: "white"
                        }

                        Label { text: "通道数"; color: "white" }
                        ComboBox {
                            model: ["3通道", "4通道"]
                            currentIndex: 0
                            Layout.preferredWidth: 100
                            Material.background: "#3d3d3d"
                            Material.foreground: "white"
                        }

                        Label { text: "有效电平"; color: "white" }
                        ComboBox {
                            model: ["高", "低"]
                            currentIndex: 0
                            Layout.preferredWidth: 100
                            Material.background: "#3d3d3d"
                            Material.foreground: "white"
                        }

                        Label { text: "通道顺序"; color: "white" }
                        ComboBox {
                            model: ["CH1", "CH2", "CH3", "CH4", "CH5"]
                            currentIndex: 0
                            Layout.preferredWidth: 100
                            Material.background: "#3d3d3d"
                            Material.foreground: "white"
                        }

                        RowLayout {
                            Layout.columnSpan: 2
                            spacing: 5
                            Label { text: "R"; color: "red" }
                            Label { text: "G"; color: "green" }
                            Label { text: "B"; color: "blue" }
                        }

                        RowLayout {
                            Layout.columnSpan: 2
                            spacing: 5
                            Label { text: "CH4"; color: "gray" }
                            Label { text: "CH5"; color: "gray" }
                        }

                        Label { text: "波特率"; color: "white" }
                        ComboBox {
                            model: ["700K", "800K", "1000K"]
                            currentIndex: 0
                            Layout.preferredWidth: 100
                            Material.background: "#3d3d3d"
                            Material.foreground: "white"
                        }
                    }
                }

                // 输出设置
                GroupBox {
                    title: "输出设置"
                    Layout.fillWidth: true

                    background: Rectangle {
                        color: "#2d2d2d"
                        radius: 4
                        border.color: "#404040"
                        border.width: 1
                    }

                    ColumnLayout {
                        spacing: 10

                        Label {
                            text: "本方案需要的主控台数为：1，帧速最小值为90.9帧/秒(11毫秒/帧)"
                            color: "#FFA500"
                            font.pixelSize: 12
                        }

                        GridLayout {
                            columns: 2
                            columnSpacing: 20
                            rowSpacing: 10

                            CheckBox {
                                text: "控制器复制"
                                checked: false
                                Material.foreground: "white"
                            }
                            CheckBox {
                                text: "端口复制"
                                checked: false
                                Material.foreground: "white"
                            }
                            CheckBox {
                                text: "控制器通道顺序"
                                checked: false
                                Material.foreground: "white"
                            }
                            CheckBox {
                                text: "SN系列分区"
                                checked: false
                                Material.foreground: "white"
                            }
                        }
                    }
                }

                // 网络设置
                GroupBox {
                    title: "网络设置"
                    Layout.fillWidth: true

                    background: Rectangle {
                        color: "#2d2d2d"
                        radius: 4
                        border.color: "#404040"
                        border.width: 1
                    }

                    GridLayout {
                        columns: 2
                        columnSpacing: 20
                        rowSpacing: 10

                        Label { text: "网卡"; color: "white" }
                        Label { text: "N/A"; color: "gray" }

                        Label { text: "IP地址设置"; color: "white" }
                        ComboBox {
                            model: ["广播", "静态IP", "DHCP"]
                            currentIndex: 0
                            Layout.preferredWidth: 200
                            Material.background: "#3d3d3d"
                            Material.foreground: "white"
                        }
                    }
                }

                // 输出SD卡文件
                GroupBox {
                    title: "输出SD卡文件"
                    Layout.fillWidth: true

                    background: Rectangle {
                        color: "#2d2d2d"
                        radius: 4
                        border.color: "#404040"
                        border.width: 1
                    }

                    ColumnLayout {
                        spacing: 10

                        Button {
                            text: "输出SD文件"
                            Layout.preferredWidth: 150
                            Material.background: Material.Orange
                            Material.foreground: "white"
                            onClicked: {
                                console.log("输出SD文件")
                            }
                        }

                        Label {
                            text: "输出SD卡文件"
                            color: "gray"
                            font.pixelSize: 12
                        }
                    }
                }

                // 高级设置
                GroupBox {
                    title: "控制器高级设置"
                    Layout.fillWidth: true

                    background: Rectangle {
                        color: "#2d2d2d"
                        radius: 4
                        border.color: "#404040"
                        border.width: 1
                    }

                    Button {
                        text: "高级设置"
                        Material.background: Material.Blue
                        Material.foreground: "white"
                        onClicked: {
                            console.log("打开高级设置")
                        }
                    }
                }

                // 占位符，用于撑开布局
                Item { Layout.fillHeight: true }
            }
        }
    }

    // 底部按钮区域
    RowLayout {
        id: buttonsRow
        anchors {
            bottom: parent.bottom
            left: parent.left
            right: parent.right
            margins: 20
        }
        height: 50
        spacing: 10

        Item { Layout.fillWidth: true }  // 占位

        Button {
            id: okButton
            text: "确定"
            Layout.preferredWidth: 100
            Material.background: Material.Blue
            Material.foreground: "white"

            onClicked: {
                // 验证输入
                var width = parseInt(widthField.text)
                var height = parseInt(heightField.text)

                if (isNaN(width) || width <= 0) {
                    showErrorDialog("宽度必须大于0")
                    return
                }

                if (isNaN(height) || height <= 0) {
                    showErrorDialog("高度必须大于0")
                    return
                }

                if (width > 72) {
                    showErrorDialog("驱动点数不能超过72")
                    return
                }

                // 收集所有设置
                var settings = {
                    width: width,
                    height: height,
                    controllerType: controllerType,
                    controllerModel: controllerModel,
                    chipType: chipType,
                    channelCount: channelCount,
                    outputSDCard: outputSDCard,
                    controllerReplication: controllerReplication,
                    portReplication: portReplication
                };

                settingsApplied(settings)
                hardwareSettingsDialog.close()
                newWiringDialog.open()
            }
        }

        Button {
            id: cancelButton
            text: "取消"
            Layout.preferredWidth: 100
            Material.background: Material.Grey
            Material.foreground: "white"

            onClicked: {
                settingsCancelled()
                hardwareSettingsDialog.close()
            }
        }
    }

    // 错误提示对话框
    MessageDialog {
        id: errorDialog
        title: "设置错误"
        // icon: StandardIcon.Warning
    }

    // 显示错误对话框
    function showErrorDialog(errorMessage) {
        errorDialog.text = errorMessage
        errorDialog.open()
    }

    // 显示/隐藏动画
    enter: Transition {
        NumberAnimation {
            property: "opacity";
            from: 0;
            to: 1;
            duration: 200
        }
        NumberAnimation {
            property: "scale";
            from: 0.9;
            to: 1;
            duration: 200;
            easing.type: Easing.OutBack
        }
    }

    exit: Transition {
        NumberAnimation {
            property: "opacity";
            from: 1;
            to: 0;
            duration: 150
        }
        NumberAnimation {
            property: "scale";
            from: 1;
            to: 0.9;
            duration: 150;
            easing.type: Easing.InCubic
        }
    }
}
