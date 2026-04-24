import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15
import QtQuick.Layouts 1.15
import Qt.labs.platform 1.1 as Platform
import QtQuick.Window 2.15

Window {
    id: newProjectDialog
    width: 600
    height: 450
    title: "新建项目"
    modality: Qt.ApplicationModal      // 模态窗口
    flags: Qt.Dialog | Qt.FramelessWindowHint  // 无边框，自定义标题栏
    color: "#00000000"                 // 透明背景，内容由主矩形绘制

    // 对外属性（与原 Popup 保持一致）
    property string projectName: "新建项目2"
    property int projectWidth: 192
    property int projectHeight: 144
    property string projectPath: "D:\\LED_Player_3.2.12_绿色免安装_20230419"
    property int selectedTabIndex: 0
    property int selectedRecentProjectIndex: 0

    // 信号
    signal accepted()
    signal rejected()

    // 拖动相关属性
    property bool dragging: false
    property point startDragPos: Qt.point(0, 0)

    // 组件初始化：窗口居中显示
    Component.onCompleted: {
        // 居中于屏幕
        x = (Screen.width - width) / 2
        y = (Screen.height - height) / 2
    }
    // 新信号：携带项目信息对象
    signal accepted(var projectInfo)

    // 原有的 rejected 信号保持不变
    signal rejected()

    // 内部错误对话框（仍然使用 Dialog 或改为自定义窗口，此处保留 Dialog 以简化）
    Dialog {
        id: errorDialog
        title: "输入错误"
        modal: true
        width: 300
        height: 150
        standardButtons: Dialog.Ok
        property string errorMessage: ""

        Text {
            anchors.centerIn: parent
            text: errorDialog.errorMessage
            color: "white"
        }
    }

    // 文件夹选择对话框
    Platform.FolderDialog {
        id: folderDialog
        currentFolder: Platform.StandardPaths.writableLocation(Platform.StandardPaths.DocumentsLocation)
        folder: Platform.StandardPaths.writableLocation(Platform.StandardPaths.DocumentsLocation)

        onAccepted: {
            projectPath = folder.toString().replace("file:///", "")
            projectPathField.text = projectPath
        }
    }

    // 主内容区域（黑色背景圆角面板）
    Rectangle {
        id: mainContent
        anchors.fill: parent
        color: "#1e1e1e"
        radius: 4
        border.color: "#404040"
        border.width: 1

        // 自定义标题栏（可拖动）
        Rectangle {
            id: titleBar
            width: parent.width
            height: 40
            color: "#2d2d2d"
            radius: 4
            // 只保留顶部圆角
            clip: true

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
                        newProjectDialog.x += deltaX
                        newProjectDialog.y += deltaY
                    }
                }

                onReleased: {
                    dragging = false
                }
            }

            // 标题文字
            Text {
                text: "新建项目"
                color: "white"
                font.pixelSize: 16
                font.bold: true
                anchors.left: parent.left
                anchors.leftMargin: 20
                anchors.verticalCenter: parent.verticalCenter
            }

            // 关闭按钮
            Button {
                id: closeButton
                anchors.right: parent.right
                anchors.rightMargin: 10
                anchors.verticalCenter: parent.verticalCenter
                width: 30
                height: 30
                Material.background: "transparent"
                Material.foreground: "white"

                onClicked: {
                    newProjectDialog.rejected()
                    newProjectDialog.close()
                }

                contentItem: Text {
                    text: "×"
                    font.pixelSize: 20
                    color: "white"
                    anchors.centerIn: parent
                }

                background: Rectangle {
                    color: closeButton.hovered ? "#ff4444" : "transparent"
                    radius: 15
                }
            }
        }

        // 内容区域布局
        ColumnLayout {
            anchors.top: titleBar.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.margins: 20
            spacing: 15

            // 第一行：项目名称 + 宽高
            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                Label {
                    text: "项目名称"
                    color: "white"
                    font.pixelSize: 13
                    Layout.preferredWidth: 60
                }

                TextField {
                    id: projectNameField
                    text: projectName
                    Layout.fillWidth: true
                    Material.background: "#2d2d2d"
                    Material.foreground: "white"
                    Material.accent: Material.Blue

                    onTextChanged: {
                        if (text.trim() !== "") {
                            projectName = text
                        }
                    }

                    background: Rectangle {
                        color: "transparent"
                        border.color: projectNameField.activeFocus ? Material.accent : "#404040"
                        border.width: 1
                        radius: 3
                    }
                }

                RowLayout {
                    spacing: 5

                    Label {
                        text: "宽度"
                        color: "white"
                        font.pixelSize: 13
                    }

                    TextField {
                        id: widthField
                        text: projectWidth.toString()
                        Layout.preferredWidth: 60
                        Material.background: "#2d2d2d"
                        Material.foreground: "white"
                        Material.accent: Material.Blue
                        validator: IntValidator { bottom: 1; top: 9999 }

                        onTextChanged: {
                            if (text.trim() !== "") {
                                projectWidth = parseInt(text)
                            }
                        }

                        background: Rectangle {
                            color: "transparent"
                            border.color: widthField.activeFocus ? Material.accent : "#404040"
                            border.width: 1
                            radius: 3
                        }
                    }
                }

                RowLayout {
                    spacing: 5

                    Label {
                        text: "高度"
                        color: "white"
                        font.pixelSize: 13
                    }

                    TextField {
                        id: heightField
                        text: projectHeight.toString()
                        Layout.preferredWidth: 60
                        Material.background: "#2d2d2d"
                        Material.foreground: "white"
                        Material.accent: Material.Blue
                        validator: IntValidator { bottom: 1; top: 9999 }

                        onTextChanged: {
                            if (text.trim() !== "") {
                                projectHeight = parseInt(text)
                            }
                        }

                        background: Rectangle {
                            color: "transparent"
                            border.color: heightField.activeFocus ? Material.accent : "#404040"
                            border.width: 1
                            radius: 3
                        }
                    }
                }
            }

            // 第二行：项目路径
            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                Label {
                    text: "项目路径"
                    color: "white"
                    font.pixelSize: 13
                    Layout.preferredWidth: 60
                }

                TextField {
                    id: projectPathField
                    text: projectPath
                    Layout.fillWidth: true
                    Material.background: "#2d2d2d"
                    Material.foreground: "white"
                    Material.accent: Material.Blue

                    onTextChanged: {
                        projectPath = text
                    }

                    background: Rectangle {
                        color: "transparent"
                        border.color: projectPathField.activeFocus ? Material.accent : "#404040"
                        border.width: 1
                        radius: 3
                    }
                }

                Button {
                    text: "..."
                    Layout.preferredWidth: 40
                    Material.background: "#2d2d2d"
                    Material.foreground: "white"

                    onClicked: {
                        folderDialog.open()
                    }

                    background: Rectangle {
                        color: parent.hovered ? "#3d3d3d" : "#2d2d2d"
                        border.color: "#404040"
                        border.width: 1
                        radius: 3
                    }
                }
            }

            // 标签页区域
            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 5

                TabBar {
                    id: tabBar
                    Layout.fillWidth: true
                    currentIndex: selectedTabIndex
background: "black"
                    onCurrentIndexChanged: {
                        selectedTabIndex = currentIndex
                    }

                    TabButton {
                        text: "最近项目"
                        width: implicitWidth
                        background: Rectangle {
                            color: parent.checked ? "#2d2d2d" : "transparent"
                            border.color: "#404040"
                            border.width: parent.checked ? 1 : 0
                        }
                        contentItem: Text {
                            text: parent.text
                            color: parent.checked ? Material.accent : "white"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }

                    TabButton {
                        text: "示例"
                        width: implicitWidth
                        background: Rectangle {
                            color: parent.checked ? "#2d2d2d" : "transparent"
                            border.color: "#404040"
                            border.width: parent.checked ? 1 : 0
                        }
                        contentItem: Text {
                            text: parent.text
                            color: parent.checked ? Material.accent : "white"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: "#2d2d2d"
                    border.color: "#404040"
                    border.width: 1

                    // 最近项目页面
                    Rectangle {
                        id: recentProjectsPage
                        anchors.fill: parent
                        visible: selectedTabIndex === 0
                        color: "transparent"

                        ListView {
                            id: recentProjectsList
                            anchors.fill: parent
                            anchors.margins: 10
                            clip: true
                            spacing: 8

                            model: ListModel {
                                ListElement {
                                    name: "新建项目1"
                                    path: "D:\\LED_Player_3.2.12_绿色免安装_20230419\\新建项目1"
                                    date: "2023-04-19 10:30:00"
                                }
                                ListElement {
                                    name: "示例项目1"
                                    path: "D:\\LED_Player_3.2.12_绿色免安装_20230419\\示例项目1"
                                    date: "2023-04-18 15:45:00"
                                }
                                ListElement {
                                    name: "演示项目"
                                    path: "D:\\LED_Player_3.2.12_绿色免安装_20230419\\演示项目"
                                    date: "2023-04-17 09:20:00"
                                }
                            }

                            delegate: Rectangle {
                                width: ListView.view.width
                                height: 60
                                color: index === selectedRecentProjectIndex ? "#3d3d3d" : "transparent"
                                radius: 3
                                border.color: index === selectedRecentProjectIndex ? Material.accent : "transparent"
                                border.width: 1

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.margins: 10
                                    spacing: 15

                                    Rectangle {
                                        width: 40
                                        height: 40
                                        radius: 5
                                        color: Material.Blue
                                        opacity: 0.7
                                        Text {
                                            text: "P"
                                            anchors.centerIn: parent
                                            color: "white"
                                            font.bold: true
                                            font.pixelSize: 18
                                        }
                                    }

                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true
                                        spacing: 2

                                        Text {
                                            text: name
                                            color: "white"
                                            font.bold: true
                                            font.pixelSize: 13
                                        }
                                        Text {
                                            text: path
                                            color: "gray"
                                            font.pixelSize: 11
                                            elide: Text.ElideLeft
                                            Layout.fillWidth: true
                                        }
                                        Text {
                                            text: "修改时间: " + date
                                            color: "#888888"
                                            font.pixelSize: 10
                                        }
                                    }
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: {
                                        selectedRecentProjectIndex = index
                                        var project = recentProjectsList.model.get(index)
                                        projectName = project.name
                                        projectPath = project.path.substring(0, project.path.lastIndexOf("\\"))
                                        projectNameField.text = projectName
                                        projectPathField.text = projectPath
                                    }
                                }
                            }
                        }
                    }

                    // 示例项目页面
                    Rectangle {
                        id: exampleProjectsPage
                        anchors.fill: parent
                        visible: selectedTabIndex === 1
                        color: "transparent"

                        ListView {
                            id: exampleProjectsList
                            anchors.fill: parent
                            anchors.margins: 10
                            clip: true
                            spacing: 8

                            model: ListModel {
                                ListElement {
                                    name: "LED显示屏示例"
                                    description: "标准LED显示屏配置示例"
                                    type: "SY系列控制器"
                                }
                                ListElement {
                                    name: "舞台灯光示例"
                                    description: "舞台灯光控制系统示例"
                                    type: "TM1804芯片"
                                }
                                ListElement {
                                    name: "建筑亮化示例"
                                    description: "建筑外立面灯光效果示例"
                                    type: "WS2812芯片"
                                }
                            }

                            delegate: Rectangle {
                                width: ListView.view.width
                                height: 60
                                color: "transparent"
                                radius: 3
                                border.color: Material.accent
                                border.width: 1

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.margins: 10
                                    spacing: 15

                                    Rectangle {
                                        width: 40
                                        height: 40
                                        radius: 5
                                        color: Material.Green
                                        opacity: 0.7
                                        Text {
                                            text: "E"
                                            anchors.centerIn: parent
                                            color: "white"
                                            font.bold: true
                                            font.pixelSize: 18
                                        }
                                    }

                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true
                                        spacing: 2

                                        Text {
                                            text: name
                                            color: "white"
                                            font.bold: true
                                            font.pixelSize: 13
                                        }
                                        Text {
                                            text: description
                                            color: "gray"
                                            font.pixelSize: 11
                                            elide: Text.ElideLeft
                                            Layout.fillWidth: true
                                        }
                                        Text {
                                            text: "控制器类型: " + type
                                            color: "#888888"
                                            font.pixelSize: 10
                                        }
                                    }

                                    Button {
                                        text: "使用"
                                        Material.background: Material.Green
                                        Material.foreground: "white"
                                        Layout.preferredWidth: 60

                                        onClicked: {
                                            var example = exampleProjectsList.model.get(index)
                                            projectName = example.name
                                            projectNameField.text = projectName
                                            console.log("使用示例项目:", example.name)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // 底部按钮区域
            Rectangle {
                Layout.fillWidth: true
                height: 50
                color: "transparent"

                RowLayout {
                    anchors.fill: parent
                    spacing: 10

                    RowLayout {
                        spacing: 10

                        Button {
                            text: "新建MapTools4项目"
                            Material.background: "#2d2d2d"
                            Material.foreground: "white"

                            onClicked: {
                                console.log("创建MapTools4项目")
                            }

                            background: Rectangle {
                                color: parent.hovered ? "#3d3d3d" : "#2d2d2d"
                                border.color: "#404040"
                                border.width: 1
                                radius: 3
                            }
                        }
                    }

                    RowLayout {
                        Layout.alignment: Qt.AlignRight
                        spacing: 10

                        Button {
                            text: "新建项目"
                            Material.background: Material.Blue
                            Material.foreground: "white"

                            onClicked: {
                                // 验证输入
                                if (projectName.trim() === "") {
                                    errorDialog.errorMessage = "项目名称不能为空"
                                    errorDialog.open()
                                    return
                                }
                                if (projectPath.trim() === "") {
                                    errorDialog.errorMessage = "请选择项目路径"
                                    errorDialog.open()
                                    return
                                }

                                // 构造项目信息对象
                                var projectInfo = {
                                    "name": projectName,
                                    "width": projectWidth,
                                    "height": projectHeight,
                                    "path": projectPath,
                                    "selectedTabIndex": selectedTabIndex,
                                    "selectedRecentProjectIndex": selectedRecentProjectIndex
                                    // 您还可以添加其他需要的字段
                                }

                                // 发射信号，将参数传递给外部
                                newProjectDialog.accepted(projectInfo)

                                // 关闭窗口
                                newProjectDialog.close()
                                // 原代码中引用的 hardwareSettingsDialog 需要进行相应实例化或注释
                                hardwareSettingsDialog.open()
                            }

                            background: Rectangle {
                                color: parent.hovered ? Qt.lighter(Material.Blue) : Material.Blue
                                border.color: "#404040"
                                border.width: 1
                                radius: 3
                            }
                        }

                        Button {
                            text: "导入项目"
                            Material.background: "#2d2d2d"
                            Material.foreground: "white"

                            onClicked: {
                                console.log("导入项目")
                            }

                            background: Rectangle {
                                color: parent.hovered ? "#3d3d3d" : "#2d2d2d"
                                border.color: "#404040"
                                border.width: 1
                                radius: 3
                            }
                        }

                        Button {
                            text: "取消"
                            Material.background: "#2d2d2d"
                            Material.foreground: "white"

                            onClicked: {
                                newProjectDialog.rejected()
                                newProjectDialog.close()
                            }

                            background: Rectangle {
                                color: parent.hovered ? "#3d3d3d" : "#2d2d2d"
                                border.color: "#404040"
                                border.width: 1
                                radius: 3
                            }
                        }
                    }
                }
            }
        }
    }
}