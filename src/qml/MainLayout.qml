// MainLayout.qml - 主布局结构
import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import "views"
import "components"
import "dialogs"
Rectangle {
    id: mainWindow
    visible: true
    color: "#1E1E1E"

    // 当前活动页面索引
    property int currentPageIndex: 0

    // 布局结构
    function applyQuickWiringPreview(config) {
        if (currentPageItem && currentPageItem.applyQuickWiringPreview) {
            currentPageItem.applyQuickWiringPreview(config)
        }
    }

    function handleMaterialReady(materialData) {
        if (currentPageItem && currentPageItem.handleMaterialReady) {
            currentPageItem.handleMaterialReady(materialData)
        }
    }

    function saveProject() {
        if (currentPageItem && currentPageItem.saveProject) {
            currentPageItem.saveProject()
        }
    }

    function loadProject(filePath) {
        if (currentPageItem && currentPageItem.loadProject) {
            currentPageItem.loadProject(filePath)
        }
    }

    function openProject() {
        if (currentPageItem && currentPageItem.openProject) {
            currentPageItem.openProject()
        }
    }

    function togglePlayPause() {
        if (currentPageItem && currentPageItem.togglePlayPause) {
            currentPageItem.togglePlayPause()
        }
    }

    // 获取当前活动页面的引用
    property Item currentPageItem: null

    ColumnLayout{
        anchors.fill: parent

        // 菜单栏
        MenuBarArea {
            Layout.fillWidth: true
            Layout.preferredHeight: 30
        }

        SplitView {
            Layout.fillWidth: true
            Layout.preferredHeight: parent.height-30-24
            Layout.maximumHeight: parent.height-30-24
            orientation: Qt.Horizontal

            // 左侧导航栏
            SideNavigationPanel {
                id: sideNav
                SplitView.minimumWidth: 60
                SplitView.preferredWidth: 200
                SplitView.maximumWidth: 60

                onMenuItemClicked: function(index, title) {
                    currentPageIndex = index
                    pageStack.replace(pageStack.pageComponents[index])
                    console.log("切换到页面:", title, "索引:", index)
                }
            }

            // 页面栈
            StackView {
                id: pageStack
                initialItem: pageComponents[0]
                SplitView.fillWidth: true
                SplitView.fillHeight: true

                // 禁用页面切换动画效果
                popEnter: null
                popExit: null
                pushEnter: null
                pushExit: null
                replaceEnter: null
                replaceExit: null

                onCurrentItemChanged: {
                    currentPageItem = pageStack.currentItem
                }

                // 页面组件列表
                property var pageComponents: [
                    projectPageComponent,
                    hardwarePageComponent,
                    wiringPageComponent,
                    playlistPageComponent,
                    mediaSourcePageComponent,
                    monitorPageComponent,
                    permissionPageComponent,
                    logPageComponent,
                    aiMaterialPageComponent,
                    algorithmSchedulerPageComponent
                ]

                // 项目管理页面
                Component {
                    id: projectPageComponent
                    Rectangle {
                        color: "#252526"
                        anchors.fill: parent

                        ProjectManager {
                            anchors.fill: parent
                        }

                        function saveProject() { console.log("保存项目") }
                        function loadProject(filePath) { console.log("加载项目:", filePath) }
                        function openProject() { console.log("打开项目") }
                    }
                }

                // 硬件配置页面
                Component {
                    id: hardwarePageComponent
                    Rectangle {
                        color: "#252526"
                        anchors.fill: parent
                        ColumnLayout {
                            anchors.centerIn: parent
                            Text {
                                text: "硬件配置"
                                color: "#FFFFFF"
                                font.pixelSize: 24
                                font.bold: true
                            }
                            Text {
                                text: "LED设备配置、参数设置等"
                                color: "#888888"
                                font.pixelSize: 14
                                Layout.topMargin: 10
                            }
                        }
                    }
                }

                // 布线页面
                Component {
                    id: wiringPageComponent
                    Rectangle {
                        color: "#252526"
                        anchors.fill: parent
                        ColumnLayout {
                            anchors.centerIn: parent
                            Text {
                                text: "布线适配"
                                color: "#FFFFFF"
                                font.pixelSize: 24
                                font.bold: true
                            }
                            Text {
                                text: "LED面板布线配置、快速布线等"
                                color: "#888888"
                                font.pixelSize: 14
                                Layout.topMargin: 10
                            }
                        }
                        function applyQuickWiringPreview(config) {
                            console.log("应用快速布线预览:", config)
                        }
                    }
                }

                // 播放列表页面（节目管理）
                Component {
                    id: playlistPageComponent
                    Rectangle {
                        color: "#252526"
                        anchors.fill: parent

                        SplitView {
                            anchors.fill: parent
                            orientation: Qt.Horizontal

                            PlaylistPanel {
                                id: playlistPanel
                                SplitView.minimumWidth: 280
                                SplitView.preferredWidth: 320
                            }

                            VideoPreviewArea {
                                id: previewArea
                                SplitView.fillWidth: true
                                SplitView.minimumWidth: 500
                            }

                            PropertyPanel {
                                id: propertyPanel
                                SplitView.minimumWidth: 300
                                SplitView.preferredWidth: 320
                            }
                        }

                        function handleMaterialReady(materialData) {
                            playlistPanel.handleMaterialReady(materialData)
                        }

                        function saveProject() {
                            playlistPanel.saveProject()
                        }

                        function loadProject(filePath) {
                            playlistPanel.loadProject(filePath)
                        }

                        function togglePlayPause() {
                            previewArea.togglePlayPause()
                        }
                    }
                }
                // AI素材编辑页面
                Component {
                    id: aiMaterialPageComponent
                    Rectangle {
                        color: "#252526"
                        anchors.fill: parent

                        AIMaterialEditor {
                            anchors.fill: parent
                        }
                    }
                }

                // 算法调度页面
                Component {
                    id: algorithmSchedulerPageComponent
                    Rectangle {
                        color: "#252526"
                        anchors.fill: parent

                        AlgorithmScheduler {
                            anchors.fill: parent
                        }
                    }
                }

                // 素材编辑页面
                Component {
                    id: mediaSourcePageComponent
                    Rectangle {
                        color: "#252526"
                        anchors.fill: parent

                        // MediaSourceEditor {
                        //     anchors.fill: parent
                        // }
                    }
                }

                // 监控页面（设备状态监控）
                Component {
                    id: monitorPageComponent
                    Rectangle {
                        color: "#252526"
                        anchors.fill: parent
                        ColumnLayout {
                            anchors.centerIn: parent
                            Text {
                                text: "设备监控"
                                color: "#FFFFFF"
                                font.pixelSize: 24
                                font.bold: true
                            }
                            Text {
                                text: "LED设备状态监控、实时数据展示等"
                                color: "#888888"
                                font.pixelSize: 14
                                Layout.topMargin: 10
                            }
                        }
                    }
                }

                // 权限管理页面（账号角色权限管理）
                Component {
                    id: permissionPageComponent
                    Rectangle {
                        color: "#252526"
                        anchors.fill: parent

                        PermissionManager {
                            anchors.fill: parent
                        }
                    }
                }

                // 系统日志页面
                Component {
                    id: logPageComponent
                    Rectangle {
                        color: "#252526"
                        anchors.fill: parent

                        ColumnLayout {
                            anchors.fill: parent
                            spacing: 0

                            // 搜索和过滤栏
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 60
                                color: "#1E1E1E"
                                RowLayout {
                                    anchors.fill: parent
                                    anchors.margins: 10
                                    spacing: 10

                                    // 用户ID过滤
                                    ColumnLayout {
                                        spacing: 5
                                        Text {
                                            text: "用户ID:"
                                            color: "#888888"
                                            font.pixelSize: 12
                                        }
                                        TextField {
                                            id: userIdField
                                            Layout.preferredWidth: 80
                                            placeholderText: "全部"
                                            inputMethodHints: Qt.ImhDigitsOnly
                                        }
                                    }

                                    // 操作类型过滤
                                    ColumnLayout {
                                        spacing: 5
                                        Text {
                                            text: "操作类型:"
                                            color: "#888888"
                                            font.pixelSize: 12
                                        }
                                        ComboBox {
                                            id: operationTypeCombo
                                            Layout.preferredWidth: 120
                                            model: ["全部", "登录", "创建用户", "更新用户", "删除用户",
                                                    "创建角色", "更新角色", "删除角色", "创建项目",
                                                    "更新项目", "删除项目", "创建设备", "更新设备", "删除设备"]
                                            currentIndex: 0
                                        }
                                    }

                                    // 时间范围过滤
                                    ColumnLayout {
                                        spacing: 5
                                        Text {
                                            text: "开始时间:"
                                            color: "#888888"
                                            font.pixelSize: 12
                                        }
                                        TextField {
                                            id: startTimeField
                                            Layout.preferredWidth: 150
                                            placeholderText: "yyyy-MM-dd HH:mm"
                                        }
                                    }

                                    ColumnLayout {
                                        spacing: 5
                                        Text {
                                            text: "结束时间:"
                                            color: "#888888"
                                            font.pixelSize: 12
                                        }
                                        TextField {
                                            id: endTimeField
                                            Layout.preferredWidth: 150
                                            placeholderText: "yyyy-MM-dd HH:mm"
                                        }
                                    }

                                    // 搜索按钮
                                    Button {
                                        text: "搜索"
                                        Layout.alignment: Qt.AlignBottom
                                        onClicked: {
                                            var userId = userIdField.text ? parseInt(userIdField.text) : 0
                                            var opType = operationTypeCombo.currentIndex === 0 ? "" : operationTypeCombo.currentText
                                            var startTime = new Date(startTimeField.text)
                                            var endTime = new Date(endTimeField.text)
                                            auditLogModel.loadLogs(userId, startTime, endTime, opType)
                                        }
                                    }

                                    // 重置按钮
                                    Button {
                                        text: "重置"
                                        Layout.alignment: Qt.AlignBottom
                                        onClicked: {
                                            userIdField.text = ""
                                            operationTypeCombo.currentIndex = 0
                                            startTimeField.text = ""
                                            endTimeField.text = ""
                                            auditLogModel.loadLogs(0, new Date(0), new Date(), "")
                                        }
                                    }
                                }
                            }

                            // 日志列表
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                color: "#252526"

                                ListView {
                                    id: logListView
                                    anchors.fill: parent
                                    anchors.margins: 10
                                    clip: true
                                    spacing: 5
                                    model: auditLogModel

                                    delegate: Rectangle {
                                        width: parent.width
                                        height: 80
                                        color: "#2D2D2D"
                                        radius: 4
                                        border.color: "#3D3D3D"
                                        border.width: 1

                                        ColumnLayout {
                                            anchors.fill: parent
                                            anchors.margins: 10
                                            spacing: 5

                                            // 第一行：操作类型和结果
                                            RowLayout {
                                                Layout.fillWidth: true
                                                spacing: 20

                                                Text {
                                                    text: model.operationType
                                                    color: "#00D4AA"
                                                    font.pixelSize: 14
                                                    font.bold: true
                                                }

                                                Text {
                                                    text: model.operateResult
                                                    color: model.operateResult === "成功" ? "#00FF00" : "#FF6B6B"
                                                    font.pixelSize: 12
                                                    font.bold: true
                                                }

                                                Text {
                                                    text: model.operateTime
                                                    color: "#888888"
                                                    font.pixelSize: 12
                                                    Layout.alignment: Qt.AlignRight
                                                }
                                            }

                                            // 第二行：操作描述
                                            Text {
                                                text: model.operationDesc
                                                color: "#CCCCCC"
                                                font.pixelSize: 13
                                                Layout.fillWidth: true
                                                wrapMode: Text.Wrap
                                            }

                                            // 第三行：用户ID、目标表、目标ID、IP
                                            RowLayout {
                                                Layout.fillWidth: true
                                                spacing: 20

                                                Text {
                                                    text: "用户ID: " + model.userId
                                                    color: "#888888"
                                                    font.pixelSize: 11
                                                }

                                                Text {
                                                    text: "目标表: " + (model.targetTable || "-")
                                                    color: "#888888"
                                                    font.pixelSize: 11
                                                }

                                                Text {
                                                    text: "目标ID: " + model.targetId
                                                    color: "#888888"
                                                    font.pixelSize: 11
                                                }

                                                Text {
                                                    text: "IP: " + (model.clientIp || "-")
                                                    color: "#888888"
                                                    font.pixelSize: 11
                                                    Layout.alignment: Qt.AlignRight
                                                }
                                            }
                                        }
                                    }

                                    header: Rectangle {
                                        width: parent.width
                                        height: 35
                                        color: "#1E1E1E"
                                        RowLayout {
                                            anchors.fill: parent
                                            anchors.margins: 10
                                            spacing: 20

                                            Text {
                                                text: "操作类型"
                                                color: "#888888"
                                                font.pixelSize: 12
                                                font.bold: true
                                                width: 100
                                            }

                                            Text {
                                                text: "结果"
                                                color: "#888888"
                                                font.pixelSize: 12
                                                font.bold: true
                                                width: 60
                                            }

                                            Text {
                                                text: "操作描述"
                                                color: "#888888"
                                                font.pixelSize: 12
                                                font.bold: true
                                                Layout.fillWidth: true
                                            }

                                            Text {
                                                text: "时间"
                                                color: "#888888"
                                                font.pixelSize: 12
                                                font.bold: true
                                                width: 150
                                                horizontalAlignment: Text.AlignRight
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        // 初始化加载日志
                        Component.onCompleted: {
                            auditLogModel.loadLogs(0, new Date(0), new Date(), "")
                        }
                    }
                }

                            }
        }

        // 状态栏
        StatusBarArea {
            Layout.fillWidth: true
            Layout.preferredHeight: 24
        }
    }
}