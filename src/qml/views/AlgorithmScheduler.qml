import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

// 算法调度组件
Rectangle {
    id: schedulerContainer
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
                    placeholderText: "搜索场景类型..."
                }

                Button {
                    text: "新建调度策略"
                    onClicked: {
                        showScheduleDialog(null)
                    }
                }

                Button {
                    text: "刷新列表"
                    onClicked: {
                        scheduleParamModel.loadParams()
                    }
                }
            }
        }

        // 调度参数列表
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "#252526"

            ListView {
                id: scheduleListView
                anchors.fill: parent
                anchors.margins: 10
                clip: true
                spacing: 5
                model: scheduleParamModel

                delegate: Rectangle {
                    width: parent.width
                    height: 160
                    color: "#2D2D2D"
                    radius: 4
                    border.color: "#3D3D3D"
                    border.width: 1

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 8

                        // 场景类型和调度ID
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 15

                            Text {
                                text: model.sceneType
                                color: "#00D4AA"
                                font.pixelSize: 16
                                font.bold: true
                            }

                            Text {
                                text: "调度ID: " + model.scheduleId
                                color: "#888888"
                                font.pixelSize: 12
                            }

                            Item { Layout.fillWidth: true }

                            Text {
                                text: "阈值: " + model.sceneThreshold
                                color: "#888888"
                                font.pixelSize: 12
                            }
                        }

                        // 预测周期和权重配置
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 20

                            Column {
                                spacing: 3
                                Text {
                                    text: "预测周期: " + model.predictCycle + "分钟"
                                    color: "#888888"
                                    font.pixelSize: 12
                                }
                                Text {
                                    text: "环境权重: " + model.envWeight
                                    color: "#888888"
                                    font.pixelSize: 12
                                }
                            }

                            Column {
                                spacing: 3
                                Text {
                                    text: "场景权重: " + model.sceneWeight
                                    color: "#888888"
                                    font.pixelSize: 12
                                }
                                Text {
                                    text: "亮度范围: " + model.brightnessMin + "% - " + model.brightnessMax + "%"
                                    color: "#888888"
                                    font.pixelSize: 12
                                }
                            }
                        }

                        // 策略JSON
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 50
                            color: "#1E1E1E"
                            radius: 4
                            Flickable {
                                anchors.fill: parent
                                anchors.margins: 8
                                contentWidth: strategyText.width
                                contentHeight: strategyText.height
                                clip: true
                                Text {
                                    id: strategyText
                                    text: "策略: " + (model.strategyJson || "{}")
                                    color: "#666666"
                                    font.pixelSize: 11
                                    wrapMode: Text.Wrap
                                }
                            }
                        }

                        // 操作按钮
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 10
                            Layout.alignment: Qt.AlignRight

                            Button {
                                text: "编辑"
                                onClicked: {
                                    showScheduleDialog(model.scheduleId)
                                }
                            }

                            Button {
                                text: "删除"
                                // color: "#FF6B6B"
                                onClicked: {
                                    if (confirmDelete(model.sceneType, model.scheduleId)) {
                                        scheduleParamModel.deleteParam(model.scheduleId, "system")
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
                            text: "场景类型"
                            color: "#888888"
                            font.pixelSize: 12
                            font.bold: true
                            width: 150
                        }

                        Text {
                            text: "预测周期"
                            color: "#888888"
                            font.pixelSize: 12
                            font.bold: true
                            width: 100
                        }

                        Text {
                            text: "权重配置"
                            color: "#888888"
                            font.pixelSize: 12
                            font.bold: true
                            width: 150
                        }

                        Text {
                            text: "亮度范围"
                            color: "#888888"
                            font.pixelSize: 12
                            font.bold: true
                            width: 120
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

    // 调度参数对话框
    Component {
        id: scheduleDialogComponent
        Rectangle {
            id: scheduleDialog
            width: 500
            height: 550
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
                            text: isEditMode ? "编辑调度策略" : "新建调度策略"
                            color: "#FFFFFF"
                            font.pixelSize: 18
                            font.bold: true
                        }
                        Item { Layout.fillWidth: true }
                        Button {
                            text: "×"
                            onClicked: {
                                scheduleDialog.visible = false
                            }
                        }
                    }

                    // 场景类型
                    ColumnLayout {
                        spacing: 5
                        Layout.fillWidth: true
                        Text {
                            text: "场景类型 *"
                            color: "#888888"
                            font.pixelSize: 12
                        }
                        TextField {
                            id: sceneTypeField
                            Layout.fillWidth: true
                            placeholderText: "例如: news, sports, entertainment"
                        }
                    }

                    // 场景阈值
                    ColumnLayout {
                        spacing: 5
                        Layout.fillWidth: true
                        Text {
                            text: "场景阈值"
                            color: "#888888"
                            font.pixelSize: 12
                        }
                        RowLayout {
                            Layout.fillWidth: true
                            Slider {
                                id: thresholdSlider
                                from: 0
                                to: 1
                                stepSize: 0.1
                                Layout.fillWidth: true
                                onMoved: {
                                    thresholdValue.text = value.toFixed(1)
                                }
                            }
                            Text {
                                id: thresholdValue
                                text: "0.5"
                                color: "#00D4AA"
                                font.pixelSize: 14
                                Layout.preferredWidth: 40
                            }
                        }
                    }

                    // 预测周期
                    ColumnLayout {
                        spacing: 5
                        Layout.fillWidth: true
                        Text {
                            text: "预测周期（分钟）"
                            color: "#888888"
                            font.pixelSize: 12
                        }
                        TextField {
                            id: predictCycleField
                            Layout.fillWidth: true
                            placeholderText: "5"
                            inputMethodHints: Qt.ImhDigitsOnly
                        }
                    }

                    // 权重配置
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 15

                        ColumnLayout {
                            spacing: 5
                            Layout.fillWidth: true
                            Text {
                                text: "环境权重"
                                color: "#888888"
                                font.pixelSize: 12
                            }
                            RowLayout {
                                Layout.fillWidth: true
                                Slider {
                                    id: envWeightSlider
                                    from: 0
                                    to: 1
                                    stepSize: 0.1
                                    Layout.fillWidth: true
                                    onMoved: {
                                        envWeightValue.text = value.toFixed(1)
                                    }
                                }
                                Text {
                                    id: envWeightValue
                                    text: "0.5"
                                    color: "#00D4AA"
                                    font.pixelSize: 14
                                    Layout.preferredWidth: 40
                                }
                            }
                        }

                        ColumnLayout {
                            spacing: 5
                            Layout.fillWidth: true
                            Text {
                                text: "场景权重"
                                color: "#888888"
                                font.pixelSize: 12
                            }
                            RowLayout {
                                Layout.fillWidth: true
                                Slider {
                                    id: sceneWeightSlider
                                    from: 0
                                    to: 1
                                    stepSize: 0.1
                                    Layout.fillWidth: true
                                    onMoved: {
                                        sceneWeightValue.text = value.toFixed(1)
                                    }
                                }
                                Text {
                                    id: sceneWeightValue
                                    text: "0.5"
                                    color: "#00D4AA"
                                    font.pixelSize: 14
                                    Layout.preferredWidth: 40
                                }
                            }
                        }
                    }

                    // 亮度范围
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 15

                        ColumnLayout {
                            spacing: 5
                            Layout.fillWidth: true
                            Text {
                                text: "最小亮度%"
                                color: "#888888"
                                font.pixelSize: 12
                            }
                            TextField {
                                id: brightnessMinField
                                Layout.fillWidth: true
                                placeholderText: "10"
                                inputMethodHints: Qt.ImhDigitsOnly
                            }
                        }

                        ColumnLayout {
                            spacing: 5
                            Layout.fillWidth: true
                            Text {
                                text: "最大亮度%"
                                color: "#888888"
                                font.pixelSize: 12
                            }
                            TextField {
                                id: brightnessMaxField
                                Layout.fillWidth: true
                                placeholderText: "100"
                                inputMethodHints: Qt.ImhDigitsOnly
                            }
                        }
                    }

                    // 策略JSON
                    ColumnLayout {
                        spacing: 5
                        Layout.fillWidth: true
                        Text {
                            text: "策略配置(JSON)"
                            color: "#888888"
                            font.pixelSize: 12
                        }
                        TextArea {
                            id: strategyJsonField
                            Layout.fillWidth: true
                            Layout.preferredHeight: 100
                            placeholderText: '{\n  "adaptive": true,\n  "priority": "balanced"\n}'
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
                                scheduleDialog.visible = false
                            }
                        }

                        Button {
                            text: isEditMode ? "保存" : "创建"
                            onClicked: {
                                saveSchedule(scheduleDialog)
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
                    text: "确定要删除调度策略 '" + confirmSceneType + "' 吗？"
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
    property int editingScheduleId: 0
    property string confirmSceneType: ""
    property var confirmCallback: null

    // 显示调度对话框
    function showScheduleDialog(scheduleId) {
        isEditMode = scheduleId !== null

        var dialog = scheduleDialogComponent.createObject(schedulerContainer.parent)

        if (isEditMode) {
            editingScheduleId = scheduleId
            var paramData = scheduleParamModel.findParamById(scheduleId)
            if (paramData) {
                dialog.sceneTypeField.text = paramData.sceneType || ""
                dialog.thresholdSlider.value = parseFloat(paramData.sceneThreshold) || 0.5
                dialog.thresholdValue.text = paramData.sceneThreshold || "0.5"
                dialog.predictCycleField.text = paramData.predictCycle || "5"
                dialog.envWeightSlider.value = parseFloat(paramData.envWeight) || 0.5
                dialog.envWeightValue.text = paramData.envWeight || "0.5"
                dialog.sceneWeightSlider.value = parseFloat(paramData.sceneWeight) || 0.5
                dialog.sceneWeightValue.text = paramData.sceneWeight || "0.5"
                dialog.brightnessMinField.text = paramData.brightnessMin || "10"
                dialog.brightnessMaxField.text = paramData.brightnessMax || "100"
                dialog.strategyJsonField.text = paramData.strategyJson || "{}"
            }
        } else {
            dialog.sceneTypeField.text = ""
            dialog.thresholdSlider.value = 0.5
            dialog.thresholdValue.text = "0.5"
            dialog.predictCycleField.text = "5"
            dialog.envWeightSlider.value = 0.5
            dialog.envWeightValue.text = "0.5"
            dialog.sceneWeightSlider.value = 0.5
            dialog.sceneWeightValue.text = "0.5"
            dialog.brightnessMinField.text = "10"
            dialog.brightnessMaxField.text = "100"
            dialog.strategyJsonField.text = '{\n  "adaptive": true,\n  "priority": "balanced"\n}'
        }

        dialog.visible = true
        dialog.x = (schedulerContainer.width - dialog.width) / 2
        dialog.y = (schedulerContainer.height - dialog.height) / 2
    }

    // 保存调度策略
    function saveSchedule(dialog) {
        if (!dialog.sceneTypeField.text.trim()) {
            return
        }

        var threshold = parseFloat(dialog.thresholdValue.text) || 0.5
        var predictCycle = parseInt(dialog.predictCycleField.text) || 5
        var envWeight = parseFloat(dialog.envWeightValue.text) || 0.5
        var sceneWeight = parseFloat(dialog.sceneWeightValue.text) || 0.5
        var brightnessMin = parseInt(dialog.brightnessMinField.text) || 10
        var brightnessMax = parseInt(dialog.brightnessMaxField.text) || 100

        if (isEditMode) {
            scheduleParamModel.updateParam(
                editingScheduleId,
                dialog.sceneTypeField.text,
                threshold,
                predictCycle,
                envWeight,
                sceneWeight,
                brightnessMin,
                brightnessMax,
                dialog.strategyJsonField.text,
                "system"
            )
        } else {
            scheduleParamModel.addParam(
                dialog.sceneTypeField.text,
                threshold,
                predictCycle,
                envWeight,
                sceneWeight,
                brightnessMin,
                brightnessMax,
                dialog.strategyJsonField.text,
                "system"
            )
        }

        dialog.visible = false
    }

    // 确认删除
    function confirmDelete(sceneType, scheduleId) {
        confirmSceneType = sceneType
        confirmCallback = function() {
            scheduleParamModel.deleteParam(scheduleId, "system")
        }

        var dialog = confirmDialogComponent.createObject(schedulerContainer.parent)
        dialog.visible = true
        dialog.x = (schedulerContainer.width - dialog.width) / 2
        dialog.y = (schedulerContainer.height - dialog.height) / 2
    }

    // 初始化加载
    Component.onCompleted: {
        scheduleParamModel.loadParams()
    }
}