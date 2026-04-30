import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

// AI素材编辑组件
Rectangle {
    id: aiMaterialContainer
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
                    placeholderText: "搜索模型名称..."
                }

                Button {
                    text: "新建模型"
                    onClicked: {
                        showModelDialog(null)
                    }
                }

                Button {
                    text: "刷新列表"
                    onClicked: {
                        aiModelConfigModel.loadConfigs()
                    }
                }
            }
        }

        // 模型配置列表
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "#252526"

            ListView {
                id: modelListView
                anchors.fill: parent
                anchors.margins: 10
                clip: true
                spacing: 5
                model: aiModelConfigModel

                delegate: Rectangle {
                    width: parent.width
                    height: 130
                    color: "#2D2D2D"
                    radius: 4
                    border.color: "#3D3D3D"
                    border.width: 1

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 8

                        // 模型名称和状态
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 15

                            Text {
                                text: model.modelName
                                color: "#FFFFFF"
                                font.pixelSize: 16
                                font.bold: true
                            }

                            Rectangle {
                                Layout.preferredWidth: 60
                                Layout.preferredHeight: 24
                                radius: 12
                                color: model.status === 1 ? "#00D4AA" : "#FF6B6B"
                                Text {
                                    anchors.centerIn: parent
                                    text: model.status === 1 ? "启用" : "禁用"
                                    color: "#000000"
                                    font.pixelSize: 11
                                    font.bold: true
                                }
                            }

                            Text {
                                text: "超时: " + model.timeout + "ms"
                                color: "#888888"
                                font.pixelSize: 12
                            }

                            Text {
                                text: model.createTime
                                color: "#888888"
                                font.pixelSize: 12
                                Layout.alignment: Qt.AlignRight
                            }
                        }

                        // API配置信息
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 20

                            Column {
                                spacing: 3
                                Text {
                                    text: "API地址: " + (model.apiUrl || "-")
                                    color: "#888888"
                                    font.pixelSize: 12
                                    wrapMode: Text.WrapAnywhere
                                    width: 300
                                }
                                Text {
                                    text: "端点: " + (model.apiEndpoint || "-")
                                    color: "#888888"
                                    font.pixelSize: 12
                                }
                            }

                            Column {
                                spacing: 3
                                Text {
                                    text: "模型路径: " + (model.modelPath || "本地")
                                    color: "#888888"
                                    font.pixelSize: 12
                                }
                                Text {
                                    text: "离线策略: " + (model.offlineStrategy || "local")
                                    color: "#888888"
                                    font.pixelSize: 12
                                }
                            }
                        }

                        // 模型参数字段
                        Text {
                            text: "模型参数: " + (model.modelParams || "{}")
                            color: "#666666"
                            font.pixelSize: 11
                            Layout.fillWidth: true
                            wrapMode: Text.Wrap
                            elide: Text.ElideRight
                            maximumLineCount: 1
                        }

                        // 操作按钮
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 10
                            Layout.alignment: Qt.AlignRight

                            Button {
                                text: model.status === 1 ? "禁用" : "启用"
                                onClicked: {
                                    aiModelConfigModel.updateConfig(
                                        model.configId,
                                        model.modelName,
                                        model.modelPath,
                                        model.apiUrl,
                                        "",
                                        model.timeout,
                                        model.modelParams,
                                        model.status === 1 ? 0 : 1,
                                        "system"
                                    )
                                }
                            }

                            Button {
                                text: "编辑"
                                onClicked: {
                                    showModelDialog(model.configId)
                                }
                            }

                            Button {
                                text: "删除"
                                // color: "#FF6B6B"
                                onClicked: {
                                    if (confirmDelete(model.modelName, model.configId)) {
                                        aiModelConfigModel.deleteConfig(model.configId, "system")
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
                            text: "模型名称"
                            color: "#888888"
                            font.pixelSize: 12
                            font.bold: true
                            width: 150
                        }

                        Text {
                            text: "状态"
                            color: "#888888"
                            font.pixelSize: 12
                            font.bold: true
                            width: 60
                        }

                        Text {
                            text: "API配置"
                            color: "#888888"
                            font.pixelSize: 12
                            font.bold: true
                            width: 350
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

    // 模型配置对话框
    Component {
        id: modelDialogComponent
        Rectangle {
            id: modelDialog
            width: 500
            height: 500
            color: "#252526"
            radius: 8
            border.color: "#3D3D3D"
            border.width: 1

            Flickable {
                anchors.fill: parent
                anchors.margins: 20
                contentHeight: dialogContent.height + 40
                clip: true

                ColumnLayout {
                    id: dialogContent
                    anchors.fill: parent
                    spacing: 15

                    // 标题
                    RowLayout {
                        Layout.fillWidth: true
                        Text {
                            text: isEditMode ? "编辑AI模型" : "新建AI模型"
                            color: "#FFFFFF"
                            font.pixelSize: 18
                            font.bold: true
                        }
                        Item { Layout.fillWidth: true }
                        Button {
                            text: "×"
                            onClicked: {
                                modelDialog.visible = false
                            }
                        }
                    }

                    // 模型名称
                    ColumnLayout {
                        spacing: 5
                        Layout.fillWidth: true
                        Text {
                            text: "模型名称 *"
                            color: "#888888"
                            font.pixelSize: 12
                        }
                        TextField {
                            id: modelNameField
                            Layout.fillWidth: true
                            placeholderText: "请输入模型名称"
                        }
                    }

                    // API地址
                    ColumnLayout {
                        spacing: 5
                        Layout.fillWidth: true
                        Text {
                            text: "API地址 *"
                            color: "#888888"
                            font.pixelSize: 12
                        }
                        TextField {
                            id: apiUrlField
                            Layout.fillWidth: true
                            placeholderText: "https://api.openai.com"
                        }
                    }

                    // API端点
                    ColumnLayout {
                        spacing: 5
                        Layout.fillWidth: true
                        Text {
                            text: "API端点"
                            color: "#888888"
                            font.pixelSize: 12
                        }
                        TextField {
                            id: apiEndpointField
                            Layout.fillWidth: true
                            placeholderText: "/v1/chat/completions"
                        }
                    }

                    // API密钥
                    ColumnLayout {
                        spacing: 5
                        Layout.fillWidth: true
                        Text {
                            text: isEditMode ? "API密钥（留空不修改）" : "API密钥 *"
                            color: "#888888"
                            font.pixelSize: 12
                        }
                        TextField {
                            id: apiKeyField
                            Layout.fillWidth: true
                            placeholderText: "sk-..."
                            echoMode: TextInput.Password
                        }
                    }

                    // 超时时间和离线策略
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 15

                        ColumnLayout {
                            spacing: 5
                            Layout.fillWidth: true
                            Text {
                                text: "超时(ms)"
                                color: "#888888"
                                font.pixelSize: 12
                            }
                            TextField {
                                id: timeoutField
                                Layout.fillWidth: true
                                placeholderText: "10000"
                                inputMethodHints: Qt.ImhDigitsOnly
                            }
                        }

                        ColumnLayout {
                            spacing: 5
                            Layout.fillWidth: true
                            Text {
                                text: "离线策略"
                                color: "#888888"
                                font.pixelSize: 12
                            }
                            ComboBox {
                                id: offlineStrategyCombo
                                Layout.fillWidth: true
                                model: ["local", "cache", "disable"]
                                currentIndex: 0
                            }
                        }
                    }

                    // 模型路径
                    ColumnLayout {
                        spacing: 5
                        Layout.fillWidth: true
                        Text {
                            text: "模型路径"
                            color: "#888888"
                            font.pixelSize: 12
                        }
                        RowLayout {
                            Layout.fillWidth: true
                            TextField {
                                id: modelPathField
                                Layout.fillWidth: true
                                placeholderText: "本地模型文件路径或下载地址"
                            }
                            Button {
                                text: "浏览..."
                                Layout.preferredWidth: 80
                            }
                        }
                    }

                    // 模型参数字段
                    ColumnLayout {
                        spacing: 5
                        Layout.fillWidth: true
                        Text {
                            text: "模型参数(JSON)"
                            color: "#888888"
                            font.pixelSize: 12
                        }
                        TextArea {
                            id: modelParamsField
                            Layout.fillWidth: true
                            Layout.preferredHeight: 80
                            placeholderText: '{\n  "temperature": 0.7,\n  "max_tokens": 1000\n}'
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
                                modelDialog.visible = false
                            }
                        }

                        Button {
                            text: isEditMode ? "保存" : "创建"
                            onClicked: {
                                saveModel(modelDialog)
                            }
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
                    text: "确认删除"
                    color: "#FFFFFF"
                    font.pixelSize: 16
                    font.bold: true
                }

                Text {
                    text: "确定要删除AI模型 '" + confirmModelName + "' 吗？"
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
    property int editingConfigId: 0
    property string confirmModelName: ""
    property var confirmCallback: null

    // 显示模型对话框
    function showModelDialog(configId) {
        isEditMode = configId !== null

        var dialog = modelDialogComponent.createObject(aiMaterialContainer.parent)

        if (isEditMode) {
            editingConfigId = configId
            var configData = aiModelConfigModel.findConfigById(configId)
            if (configData) {
                dialog.modelNameField.text = configData.modelName || ""
                dialog.apiUrlField.text = configData.apiUrl || ""
                dialog.apiEndpointField.text = configData.apiEndpoint || ""
                dialog.apiKeyField.text = ""
                dialog.timeoutField.text = configData.timeout || "10000"
                dialog.modelPathField.text = configData.modelPath || ""
                dialog.modelParamsField.text = configData.modelParams || "{}"

                var strategyIndex = 0
                if (configData.offlineStrategy === "cache") strategyIndex = 1
                else if (configData.offlineStrategy === "disable") strategyIndex = 2
                dialog.offlineStrategyCombo.currentIndex = strategyIndex
            }
        } else {
            dialog.modelNameField.text = ""
            dialog.apiUrlField.text = ""
            dialog.apiEndpointField.text = ""
            dialog.apiKeyField.text = ""
            dialog.timeoutField.text = "10000"
            dialog.modelPathField.text = ""
            dialog.modelParamsField.text = '{"temperature": 0.7, "max_tokens": 1000}'
            dialog.offlineStrategyCombo.currentIndex = 0
        }

        dialog.visible = true
        dialog.x = (aiMaterialContainer.width - dialog.width) / 2
        dialog.y = (aiMaterialContainer.height - dialog.height) / 2
    }

    // 保存模型
    function saveModel(dialog) {
        if (!dialog.modelNameField.text.trim() || !dialog.apiUrlField.text.trim()) {
            return
        }

        var timeout = parseInt(dialog.timeoutField.text) || 10000
        var offlineStrategy = dialog.offlineStrategyCombo.currentText

        if (isEditMode) {
            aiModelConfigModel.updateConfig(
                editingConfigId,
                dialog.modelNameField.text,
                dialog.modelPathField.text,
                dialog.apiUrlField.text,
                dialog.apiKeyField.text,
                timeout,
                dialog.modelParamsField.text,
                1,
                "system"
            )
        } else {
            if (!dialog.apiKeyField.text.trim()) {
                return
            }
            aiModelConfigModel.addConfig(
                dialog.modelNameField.text,
                dialog.modelPathField.text,
                dialog.apiUrlField.text,
                dialog.apiKeyField.text,
                timeout,
                dialog.modelParamsField.text,
                "system"
            )
        }

        dialog.visible = false
    }

    // 确认删除
    function confirmDelete(modelName, configId) {
        confirmModelName = modelName
        confirmCallback = function() {
            aiModelConfigModel.deleteConfig(configId, "system")
        }

        var dialog = confirmDialogComponent.createObject(aiMaterialContainer.parent)
        dialog.visible = true
        dialog.x = (aiMaterialContainer.width - dialog.width) / 2
        dialog.y = (aiMaterialContainer.height - dialog.height) / 2
    }

    // 初始化加载
    Component.onCompleted: {
        aiModelConfigModel.loadConfigs()
    }
}