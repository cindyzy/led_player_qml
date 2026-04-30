import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

// 素材编辑组件
Rectangle {
    id: mediaContainer
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
                    placeholderText: "搜索素材名称..."
                }

                Button {
                    text: "添加素材"
                    onClicked: {
                        showMediaDialog(null)
                    }
                }

                Button {
                    text: "刷新列表"
                    onClicked: {
                        mediaSourceModel.loadMedias(0)
                    }
                }
            }
        }

        // 素材列表
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "#252526"

            ListView {
                id: mediaListView
                anchors.fill: parent
                anchors.margins: 10
                clip: true
                spacing: 5
                model: mediaSourceModel

                delegate: Rectangle {
                    width: parent.width
                    height: 140
                    color: "#2D2D2D"
                    radius: 4
                    border.color: "#3D3D3D"
                    border.width: 1

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 8

                        // 素材名称和状态
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 15

                            Text {
                                text: model.mediaName
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
                                text: "时长: " + formatDuration(model.duration)
                                color: "#888888"
                                font.pixelSize: 12
                            }

                            Text {
                                text: "类型: " + (model.mediaType || "未知")
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

                        // 文件路径
                        Text {
                            text: "文件路径: " + (model.filePath || "-")
                            color: "#666666"
                            font.pixelSize: 11
                            Layout.fillWidth: true
                            wrapMode: Text.Wrap
                            elide: Text.ElideRight
                            maximumLineCount: 2
                        }

                        // 缩略图预览
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 15

                            Rectangle {
                                Layout.preferredWidth: 120
                                Layout.preferredHeight: 68
                                color: "#1E1E1E"
                                radius: 4
                                border.color: "#3D3D3D"
                                border.width: 1

                                Image {
                                    anchors.fill: parent
                                    anchors.margins: 2
                                    source: model.thumbnailPath || ""
                                    fillMode: Image.PreserveAspectFit
                                    fallback: Text {
                                        anchors.centerIn: parent
                                        text: "无缩略图"
                                        color: "#666666"
                                        font.pixelSize: 11
                                    }
                                }
                            }

                            Column {
                                spacing: 5
                                Text {
                                    text: "ID: " + model.mediaId
                                    color: "#888888"
                                    font.pixelSize: 12
                                }
                                Text {
                                    text: "窗口ID: " + model.windowId
                                    color: "#888888"
                                    font.pixelSize: 12
                                }
                                Text {
                                    text: "更新时间: " + model.updateTime
                                    color: "#888888"
                                    font.pixelSize: 12
                                }
                            }

                            Item { Layout.fillWidth: true }
                        }

                        // 操作按钮
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 10
                            Layout.alignment: Qt.AlignRight

                            Button {
                                text: model.status === 1 ? "禁用" : "启用"
                                onClicked: {
                                    mediaSourceModel.updateMedia(
                                        model.mediaId,
                                        model.mediaName,
                                        model.duration,
                                        model.status === 1 ? 0 : 1,
                                        "system"
                                    )
                                }
                            }

                            Button {
                                text: "编辑"
                                onClicked: {
                                    showMediaDialog(model.mediaId)
                                }
                            }

                            Button {
                                text: "删除"
                                color: "#FF6B6B"
                                onClicked: {
                                    if (confirmDelete(model.mediaName, model.mediaId)) {
                                        mediaSourceModel.deleteMedia(model.mediaId, "system")
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
                            text: "素材名称"
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
                            text: "时长"
                            color: "#888888"
                            font.pixelSize: 12
                            font.bold: true
                            width: 80
                        }

                        Text {
                            text: "类型"
                            color: "#888888"
                            font.pixelSize: 12
                            font.bold: true
                            width: 80
                        }

                        Text {
                            text: "缩略图"
                            color: "#888888"
                            font.pixelSize: 12
                            font.bold: true
                            width: 140
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

    // 素材对话框
    Component {
        id: mediaDialogComponent
        Rectangle {
            id: mediaDialog
            width: 500
            height: 450
            color: "#252526"
            radius: 8
            border.color: "#3D3D3D"
            border.width: 1

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 15

                // 标题
                RowLayout {
                    Layout.fillWidth: true
                    Text {
                        text: isEditMode ? "编辑素材" : "添加素材"
                        color: "#FFFFFF"
                        font.pixelSize: 18
                        font.bold: true
                    }
                    Item { Layout.fillWidth: true }
                    Button {
                        text: "×"
                        onClicked: {
                            mediaDialog.visible = false
                        }
                    }
                }

                // 素材名称
                ColumnLayout {
                    spacing: 5
                    Layout.fillWidth: true
                    Text {
                        text: "素材名称 *"
                        color: "#888888"
                        font.pixelSize: 12
                    }
                    TextField {
                        id: mediaNameField
                        Layout.fillWidth: true
                        placeholderText: "请输入素材名称"
                    }
                }

                // 文件路径
                ColumnLayout {
                    spacing: 5
                    Layout.fillWidth: true
                    Text {
                        text: "文件路径 *"
                        color: "#888888"
                        font.pixelSize: 12
                    }
                    RowLayout {
                        Layout.fillWidth: true
                        TextField {
                            id: filePathField
                            Layout.fillWidth: true
                            placeholderText: "选择素材文件"
                            readOnly: true
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

                // 时长和类型
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 15

                    ColumnLayout {
                        spacing: 5
                        Layout.fillWidth: true
                        Text {
                            text: "时长(秒)"
                            color: "#888888"
                            font.pixelSize: 12
                        }
                        TextField {
                            id: durationField
                            Layout.fillWidth: true
                            placeholderText: "10.0"
                        }
                    }

                    ColumnLayout {
                        spacing: 5
                        Layout.fillWidth: true
                        Text {
                            text: "媒体类型"
                            color: "#888888"
                            font.pixelSize: 12
                        }
                        ComboBox {
                            id: mediaTypeCombo
                            Layout.fillWidth: true
                            model: ["video", "image", "audio", "text", "other"]
                            currentIndex: 0
                        }
                    }
                }

                // 缩略图路径
                ColumnLayout {
                    spacing: 5
                    Layout.fillWidth: true
                    Text {
                        text: "缩略图路径"
                        color: "#888888"
                        font.pixelSize: 12
                    }
                    RowLayout {
                        Layout.fillWidth: true
                        TextField {
                            id: thumbnailPathField
                            Layout.fillWidth: true
                            placeholderText: "缩略图文件路径"
                            readOnly: true
                        }
                        Button {
                            text: "浏览..."
                            Layout.preferredWidth: 80
                        }
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
                            mediaDialog.visible = false
                        }
                    }

                    Button {
                        text: isEditMode ? "保存" : "添加"
                        onClicked: {
                            saveMedia(mediaDialog)
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
                    text: "确定要删除素材 '" + confirmMediaName + "' 吗？"
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
                        color: "#FF6B6B"
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
    property int editingMediaId: 0
    property string confirmMediaName: ""
    property var confirmCallback: null

    // 格式化时长
    function formatDuration(seconds) {
        var mins = Math.floor(seconds / 60)
        var secs = Math.floor(seconds % 60)
        var ms = Math.floor((seconds - Math.floor(seconds)) * 100)
        return mins.toString().padStart(2, "0") + ":" + secs.toString().padStart(2, "0") + "." + ms.toString().padStart(2, "0")
    }

    // 显示素材对话框
    function showMediaDialog(mediaId) {
        isEditMode = mediaId !== null

        var dialog = mediaDialogComponent.createObject(mediaContainer.parent)

        if (isEditMode) {
            editingMediaId = mediaId
            var mediaData = mediaSourceModel.findMediaById(mediaId)
            if (mediaData) {
                dialog.mediaNameField.text = mediaData.mediaName || ""
                dialog.filePathField.text = mediaData.filePath || ""
                dialog.durationField.text = mediaData.duration || "10.0"
                dialog.thumbnailPathField.text = mediaData.thumbnailPath || ""

                var typeIndex = 0
                if (mediaData.mediaType === "image") typeIndex = 1
                else if (mediaData.mediaType === "audio") typeIndex = 2
                else if (mediaData.mediaType === "text") typeIndex = 3
                else if (mediaData.mediaType === "other") typeIndex = 4
                dialog.mediaTypeCombo.currentIndex = typeIndex
            }
        } else {
            dialog.mediaNameField.text = ""
            dialog.filePathField.text = ""
            dialog.durationField.text = "10.0"
            dialog.thumbnailPathField.text = ""
            dialog.mediaTypeCombo.currentIndex = 0
        }

        dialog.visible = true
        dialog.x = (mediaContainer.width - dialog.width) / 2
        dialog.y = (mediaContainer.height - dialog.height) / 2
    }

    // 保存素材
    function saveMedia(dialog) {
        if (!dialog.mediaNameField.text.trim() || !dialog.filePathField.text.trim()) {
            return
        }

        var duration = parseFloat(dialog.durationField.text) || 10.0
        var mediaType = dialog.mediaTypeCombo.currentText

        if (isEditMode) {
            mediaSourceModel.updateMedia(
                editingMediaId,
                dialog.mediaNameField.text,
                duration,
                1,
                "system"
            )
        } else {
            mediaSourceModel.addMedia(
                0,
                dialog.filePathField.text,
                dialog.mediaNameField.text,
                duration,
                mediaType,
                dialog.thumbnailPathField.text,
                "system"
            )
        }

        dialog.visible = false
    }

    // 确认删除
    function confirmDelete(mediaName, mediaId) {
        confirmMediaName = mediaName
        confirmCallback = function() {
            mediaSourceModel.deleteMedia(mediaId, "system")
        }

        var dialog = confirmDialogComponent.createObject(mediaContainer.parent)
        dialog.visible = true
        dialog.x = (mediaContainer.width - dialog.width) / 2
        dialog.y = (mediaContainer.height - dialog.height) / 2
    }

    // 初始化加载
    Component.onCompleted: {
        mediaSourceModel.loadMedias(0)
    }
}