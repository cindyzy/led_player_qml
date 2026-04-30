import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

// 项目管理组件
Rectangle {
    id: projectContainer
    anchors.fill: parent
    color: "#252526"

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // 工具栏
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 50
            color: "#1E1E1E"
            RowLayout {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 10

                TextField {
                    id: searchField
                    Layout.preferredWidth: 200
                    placeholderText: "搜索项目名称..."
                    onTextChanged: {
                        filterProjects()
                    }
                }

                Button {
                    text: "新建项目"
                    onClicked: {
                        showProjectDialog(null)
                    }
                }

                Button {
                    text: "刷新列表"
                    onClicked: {
                        projectConfigModel.loadProjects()
                    }
                }
            }
        }

        // 项目列表
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "#252526"

            ListView {
                id: projectListView
                anchors.fill: parent
                anchors.margins: 10
                clip: true
                spacing: 5
                model: projectConfigModel

                delegate: Rectangle {
                    width: parent.width
                    height: 100
                    color: "#2D2D2D"
                    radius: 4
                    border.color: "#3D3D3D"
                    border.width: 1

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 8

                        // 项目名称和状态
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 15

                            Text {
                                text: model.projectName
                                color: "#FFFFFF"
                                font.pixelSize: 16
                                font.bold: true
                            }

                            Rectangle {
                                Layout.preferredWidth: 80
                                Layout.preferredHeight: 24
                                radius: 12
                                color: model.isValid === 1 ? "#00D4AA" : "#FF6B6B"
                                Text {
                                    anchors.centerIn: parent
                                    text: model.isValid === 1 ? "已启用" : "已禁用"
                                    color: "#000000"
                                    font.pixelSize: 11
                                    font.bold: true
                                }
                            }

                            Text {
                                text: model.createTime
                                color: "#888888"
                                font.pixelSize: 12
                                Layout.alignment: Qt.AlignRight
                            }
                        }

                        // 项目描述信息
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 20

                            Column {
                                spacing: 3
                                Text {
                                    text: "项目路径: " + (model.projectPath || "-")
                                    color: "#888888"
                                    font.pixelSize: 12
                                    wrapMode: Text.Wrap
                                    width: 250
                                }
                                Text {
                                    text: "窗口布局: " + (model.windowLayout ? "已配置" : "未配置")
                                    color: "#888888"
                                    font.pixelSize: 12
                                }
                                Text {
                                    text: "灯光映射: " + (model.lightMapping ? "已配置" : "未配置")
                                    color: "#888888"
                                    font.pixelSize: 12
                                }
                            }

                            Column {
                                spacing: 3
                                Text {
                                    text: "调度策略: " + (model.cronStrategy || "默认")
                                    color: "#888888"
                                    font.pixelSize: 12
                                }
                                Text {
                                    text: "项目ID: " + model.projectId
                                    color: "#888888"
                                    font.pixelSize: 12
                                }
                            }
                        }

                        // 操作按钮
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 10
                            Layout.alignment: Qt.AlignRight

                            Button {
                                text: model.isValid === 1 ? "禁用" : "启用"
                                // color: model.isValid === 1 ? "#FF6B6B" : "#00D4AA"
                                onClicked: {
                                    projectConfigModel.updateProject(
                                        model.projectId,
                                        model.projectName,
                                        model.projectPath,
                                        model.windowLayout,
                                        model.lightMapping,
                                        model.cronStrategy,
                                        model.isValid === 1 ? 0 : 1,
                                        "system"
                                    )
                                }
                            }

                            Button {
                                text: "编辑"
                                onClicked: {
                                    showProjectDialog(model.projectId)
                                }
                            }

                            Button {
                                text: "删除"
                                // color: "#FF6B6B"
                                onClicked: {
                                    if (confirmDelete(model.projectName, model.projectId)) {
                                        projectConfigModel.deleteProject(model.projectId, "system")
                                    }
                                }
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
                            text: "项目名称"
                            color: "#888888"
                            font.pixelSize: 12
                            font.bold: true
                            width: 150
                        }

                        Text {
                            text: "项目路径"
                            color: "#888888"
                            font.pixelSize: 12
                            font.bold: true
                            width: 250
                        }

                        Text {
                            text: "状态"
                            color: "#888888"
                            font.pixelSize: 12
                            font.bold: true
                            width: 80
                        }

                        Text {
                            text: "创建时间"
                            color: "#888888"
                            font.pixelSize: 12
                            font.bold: true
                            width: 150
                        }

                        Text {
                            text: "操作"
                            color: "#888888"
                            font.pixelSize: 12
                            font.bold: true
                            Layout.fillWidth: true
                            horizontalAlignment: Text.AlignRight
                        }
                    }
                }
            }
        }
    }

    // 项目对话框
    Component {
        id: projectDialogComponent
        Rectangle {
            id: projectDialog
            width: 500
            height: 450
            color: "#252526"
            radius: 8
            border.color: "#3D3D3D"
            border.width: 1

            ColumnLayout {
                anchors.fill: parent
                spacing: 15
                anchors.margins: 20

                // 标题
                RowLayout {
                    Layout.fillWidth: true
                    Text {
                        text: isEditMode ? "编辑项目" : "新建项目"
                        color: "#FFFFFF"
                        font.pixelSize: 18
                        font.bold: true
                    }
                    Item { Layout.fillWidth: true }
                    Button {
                        text: "×"
                        // color: "#888888"
                        onClicked: {
                            projectDialog.visible = false
                        }
                    }
                }

                // 项目名称
                ColumnLayout {
                    spacing: 5
                    Text {
                        text: "项目名称 *"
                        color: "#888888"
                        font.pixelSize: 12
                    }
                    TextField {
                        id: projectNameField
                        Layout.fillWidth: true
                        placeholderText: "请输入项目名称"
                    }
                }

                // 项目路径
                ColumnLayout {
                    spacing: 5
                    Text {
                        text: "项目路径"
                        color: "#888888"
                        font.pixelSize: 12
                    }
                    RowLayout {
                        Layout.fillWidth: true
                        TextField {
                            id: projectPathField
                            Layout.fillWidth: true
                            placeholderText: "项目文件存储路径"
                        }
                        Button {
                            text: "浏览..."
                            Layout.preferredWidth: 80
                            onClicked: {
                                // 这里可以调用文件选择对话框
                            }
                        }
                    }
                }

                // 窗口布局
                ColumnLayout {
                    spacing: 5
                    Text {
                        text: "窗口布局（JSON）"
                        color: "#888888"
                        font.pixelSize: 12
                    }
                    TextArea {
                        id: windowLayoutField
                        Layout.fillWidth: true
                        Layout.preferredHeight: 50
                        placeholderText: "{}"
                    }
                }

                // 灯光映射
                ColumnLayout {
                    spacing: 5
                    Text {
                        text: "灯光映射（JSON）"
                        color: "#888888"
                        font.pixelSize: 12
                    }
                    TextArea {
                        id: lightMappingField
                        Layout.fillWidth: true
                        Layout.preferredHeight: 50
                        placeholderText: "{}"
                    }
                }

                // 调度策略
                ColumnLayout {
                    spacing: 5
                    Text {
                        text: "调度策略（Cron表达式）"
                        color: "#888888"
                        font.pixelSize: 12
                    }
                    TextField {
                        id: cronStrategyField
                        Layout.fillWidth: true
                        placeholderText: "* * * * *"
                    }
                }

                // 按钮
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 15
                    Layout.alignment: Qt.AlignRight

                    Button {
                        text: "取消"
                        onClicked: {
                            projectDialog.visible = false
                        }
                    }

                    Button {
                        text: isEditMode ? "保存" : "创建"
                        onClicked: {
                            saveProject()
                        }
                    }
                }
            }
        }
    }

    // 确认对话框
    Component {
        id: confirmDialogComponent
        Rectangle {
            id: confirmDialog
            width: 350
            height: 150
            color: "#252526"
            radius: 8
            border.color: "#3D3D3D"
            border.width: 1

            ColumnLayout {
                anchors.fill: parent
                spacing: 15
                anchors.margins: 20

                Text {
                    text: "确认删除项目"
                    color: "#FFFFFF"
                    font.pixelSize: 16
                    font.bold: true
                }

                Text {
                    text: "确定要删除项目 '" + confirmProjectName + "' 吗？"
                    color: "#888888"
                    font.pixelSize: 13
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 15
                    Layout.alignment: Qt.AlignRight

                    Button {
                        text: "取消"
                        onClicked: {
                            confirmDialog.visible = false
                        }
                    }

                    Button {
                        text: "删除"
                        // color: "#FF6B6B"
                        onClicked: {
                            confirmDialog.visible = false
                            if (confirmCallback) {
                                confirmCallback()
                            }
                        }
                    }
                }
            }
        }
    }

    // 状态变量
    property bool isEditMode: false
    property int editingProjectId: 0
    property string confirmProjectName: ""
    property var confirmCallback: null

    // 显示项目对话框
    function showProjectDialog(projectId) {
        isEditMode = projectId !== null

        if (isEditMode) {
            editingProjectId = projectId
            var projectData = projectConfigModel.findProjectById(projectId)
            if (projectData) {
                projectNameField.text = projectData.projectName || ""
                projectPathField.text = projectData.projectPath || ""
                windowLayoutField.text = projectData.windowLayout || ""
                lightMappingField.text = projectData.lightMapping || ""
                cronStrategyField.text = projectData.cronStrategy || ""
            }
        } else {
            projectNameField.text = ""
            projectPathField.text = ""
            windowLayoutField.text = "{}"
            lightMappingField.text = "{}"
            cronStrategyField.text = "* * * * *"
        }

        var dialog = projectDialogComponent.createObject(projectContainer.parent)
        dialog.visible = true
        dialog.x = (projectContainer.width - dialog.width) / 2
        dialog.y = (projectContainer.height - dialog.height) / 2
    }

    // 保存项目
    function saveProject() {
        if (!projectNameField.text.trim()) {
            return
        }

        if (isEditMode) {
            projectConfigModel.updateProject(
                editingProjectId,
                projectNameField.text,
                projectPathField.text,
                windowLayoutField.text,
                lightMappingField.text,
                cronStrategyField.text,
                1,
                "system"
            )
        } else {
            projectConfigModel.addProject(
                projectNameField.text,
                projectPathField.text,
                windowLayoutField.text,
                lightMappingField.text,
                cronStrategyField.text,
                "system"
            )
        }

        // 关闭对话框
        projectContainer.parent.children.forEach(function(child) {
            if (child === projectDialogComponent) {
                child.visible = false
            }
        })
    }

    // 确认删除
    function confirmDelete(projectName, projectId) {
        confirmProjectName = projectName
        confirmCallback = function() {
            projectConfigModel.deleteProject(projectId, "system")
        }

        var dialog = confirmDialogComponent.createObject(projectContainer.parent)
        dialog.visible = true
        dialog.x = (projectContainer.width - dialog.width) / 2
        dialog.y = (projectContainer.height - dialog.height) / 2
    }

    // 过滤项目
    function filterProjects() {
        projectConfigModel.loadProjects()
    }

    // 初始化加载
    Component.onCompleted: {
        projectConfigModel.loadProjects()
    }
}