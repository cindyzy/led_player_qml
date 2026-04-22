// PlaylistPanel.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQml.Models

Rectangle {
    id: playlistPanel
    color: "#252526"
    border.color: "#3E3E3E"
    border.width: 1

    // 属性：当前播放列表名称
    property string currentPlaylistName: "新建项目5-播放列表1"

    // 属性：右键菜单相关
    property int contextMenuProgramIndex: -1
    property int contextMenuWindowIndex: -1
    property string contextMenuSelectedItem: ""

    // 属性：播放列表数据
    property var playlistData: [
        {
            "name": "节目1",
            "type": "program",
            "duration": "0.00s",
            "expanded": true,
            "children": [
                {
                    "name": "监视1",
                    "type": "window",
                    "duration": "0.00s",
                    "children": []
                }
            ]
        }
    ]

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 8
        spacing: 8

        // 标题
        Text {
            text: "播放列表"
            color: "#D4D4D4"
            font.bold: true
            font.pixelSize: 16
        }

        // 播放列表选择
        RowLayout {
            Layout.fillWidth: true
            spacing: 5

            ComboBox {
                id: playlistComboBox
                Layout.fillWidth: true
                Layout.preferredHeight:20
                model: ["播放列表1", "播放列表2", "播放列表3"]
                currentIndex: 0

                background: Rectangle {
                    color: "#333333"
                    border.color: "#555555"
                    border.width: 1
                    radius: 2
                }

                contentItem: Text {
                    text: playlistComboBox.currentText
                    color: "#D4D4D4"
                    leftPadding: 8
                    verticalAlignment: Text.AlignVCenter
                }

                popup.background: Rectangle {
                    color: "#333333"
                    border.color: "#555555"
                }
            }

            // 添加按钮
            Button {
                text: "+"
                implicitWidth: 30
                implicitHeight: 30

                background: Rectangle {
                    color: parent.pressed ? "#007ACC" : "#333333"
                    border.color: "#555555"
                    border.width: 1
                    radius: 2
                }

                contentItem: Text {
                    text: parent.text
                    color: "#D4D4D4"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                onClicked: {
                    console.log("添加播放列表")
                }
            }
        }

        // 播放列表内容
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 5

            // 播放列表标题
            Rectangle {
                id: playlistTitle
                Layout.fillWidth: true
                Layout.preferredHeight: 30
                color: "#333333"
                radius: 4

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 8
                    spacing: 8

                    // 启用开关
                    CheckBox {
                        id: playlistEnabled
                        checked: true

                        indicator: Rectangle {
                            implicitWidth: 16
                            implicitHeight: 16
                            color: parent.checked ? "#007ACC" : "#444444"
                            border.color: "#666666"
                            radius: 3

                            Text {
                                text: "ON"
                                color: "#FFFFFF"
                                font.pixelSize: 8
                                anchors.centerIn: parent
                                visible: parent.parent.checked
                            }
                        }
                    }

                    // 播放列表名称
                    Text {
                        text: playlistPanel.currentPlaylistName
                        color: "#FFFFFF"
                        font.bold: true
                        font.pixelSize: 12
                    }

                    Item { Layout.fillWidth: true }

                    // 总时长
                    Text {
                        text: "0.00s"
                        color: "#999999"
                        font.pixelSize: 12
                    }
                }

                // 播放列表标题右键菜单
                Menu {
                    id: playlistTitleContextMenu
                    modal: false
                    focus: true
                    MenuItem { text: "新建节目"; onTriggered: {/* TODO: 新建节目 */} }
                    MenuItem { text: "新建多个节目"; onTriggered: {/* TODO: 新建多个节目 */} }
                    MenuItem { text: "新建媒资节目"; onTriggered: {/* TODO: 新建媒资节目 */} }
                    MenuItem { text: "导入多个素材"; onTriggered: {/* TODO: 导入多个素材 */} }
                    MenuSeparator {}
                    MenuItem { text: "展开全部节目"; onTriggered: {/* TODO: 展开全部 */} }
                    MenuItem { text: "收起全部节目"; onTriggered: {/* TODO: 收起全部 */} }
                    MenuSeparator {}
                    MenuItem { text: "导入节目列表"; onTriggered: {/* TODO: 导入节目列表 */} }
                    MenuItem { text: "导出节目列表"; onTriggered: {/* TODO: 导出节目列表 */} }
                    MenuSeparator {}
                    MenuItem { text: "全选(Ctrl+A)"; onTriggered: {/* TODO: 全选 */} }
                    MenuItem { text: "反选"; onTriggered: {/* TODO: 反选 */} }
                }

                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.RightButton
                    onClicked: function(mouse) {
                        if (mouse.button === Qt.RightButton) {
                            playlistTitleContextMenu.open()
                        }
                    }
                }
            }

            // 播放列表项
            Repeater {
                model: playlistPanel.playlistData

                delegate: ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2

                    // 保存节目索引
                    property int programIndex: index

                    // 节目项
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 25
                        color: "#2D2D2D"
                        radius: 4

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 8
                            anchors.leftMargin: 20
                            spacing: 8

                            // 启用开关
                            CheckBox {
                                id: programEnabled
                                checked: true

                                indicator: Rectangle {
                                    implicitWidth: 16
                                    implicitHeight: 16
                                    color: parent.checked ? "#007ACC" : "#444444"
                                    border.color: "#666666"
                                    radius: 3

                                    Text {
                                        text: "ON"
                                        color: "#FFFFFF"
                                        font.pixelSize: 8
                                        anchors.centerIn: parent
                                        visible: parent.parent.checked
                                    }
                                }
                            }

                            // 类型图标
                            Text {
                                text: "▶"
                                color: "#CCCCCC"
                                font.pixelSize: 12
                            }

                            // 节目名称
                            Text {
                                text: modelData.name
                                color: "#D4D4D4"
                                font.pixelSize: 12
                            }

                            Item { Layout.fillWidth: true }

                            // 时长
                            Text {
                                text: modelData.duration
                                color: "#999999"
                                font.pixelSize: 12
                            }
                        }

                        // 节目项右键菜单
                        Menu {
                            id: programContextMenu
                            modal: false
                            focus: true

                            MenuItem { text: "禁用"; enabled: false }
                            MenuSeparator {}
                            MenuItem { text: "添加视窗"; onTriggered: {/* TODO: add window */} }
                            MenuItem { text: "窗口均分视窗"; onTriggered: {/* TODO: split window */} }
                            MenuItem { text: "纵向均分视窗"; onTriggered: {/* TODO: split window vertical */} }
                            MenuSeparator {}
                            MenuItem { text: "置顶"; enabled: false }
                            MenuItem { text: "置底"; enabled: false }
                            MenuItem { text: "移动到..."; enabled: false }
                            MenuItem { text: "上移"; enabled: false }
                            MenuItem { text: "下移"; enabled: false }
                            MenuSeparator {}
                            MenuItem { text: "复制 (Ctrl+C)"; enabled: false }
                            MenuItem { text: "粘贴 (Ctrl+V)"; enabled: false }
                            MenuItem { text: "插入复制节目 (Ctrl+/T)"; enabled: false }
                            MenuSeparator {}
                            MenuItem { text: "重命名 (Ctrl+R)"; enabled: false }
                            MenuItem { text: "删除 (Delete)"; enabled: false }
                        }

                        MouseArea {
                            anchors.fill: parent
                            acceptedButtons: Qt.RightButton
                            onClicked: function(mouse) {
                                if (mouse.button === Qt.RightButton) {
                                    contextMenuProgramIndex = programIndex
                                    contextMenuSelectedItem = "program"
                                    programContextMenu.open()
                                }
                            }
                        }
                    }

                    // 视窗项
                    Repeater {
                        model: modelData.children

                        delegate: Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 25
                            color: "#252526"
                            radius: 4

                            // 保存视窗索引
                            property int windowIndex: index

                            // 右键菜单
                            Menu {
                                id: windowContextMenu
                                modal: false
                                focus: true

                                // 1. 添加视频/素材文件
                                MenuItem {
                                    text: "添加视频/素材文件"
                                    icon.name: "A"
                                    onTriggered: addVideoMaterial(programIndex, windowIndex)
                                }

                                // 2. 添加炫彩文字
                                MenuItem {
                                    text: "添加炫彩文字"
                                    icon.name: "F"
                                    onTriggered: addColorfulText(programIndex, windowIndex)
                                }

                                // 3. 添加屏幕录制
                                MenuItem {
                                    text: "添加屏幕录制"
                                    icon.name: "F"
                                    onTriggered: addScreenRecording(programIndex, windowIndex)
                                }

                                // 4. 添加Flash
                                MenuItem {
                                    text: "添加Flash"
                                    icon.name: "G"
                                    onTriggered: addFlash(programIndex, windowIndex)
                                }

                                // 5. 添加旋转文字
                                MenuItem {
                                    text: "添加旋转文字"
                                    icon.name: "F"
                                    onTriggered: addRotatingText(programIndex, windowIndex)
                                }

                                // 6. 添加素材集
                                MenuItem {
                                    text: "添加素材集"
                                    icon.name: "F"
                                    onTriggered: addMaterialSet(programIndex, windowIndex)
                                }

                                MenuSeparator {}

                                // 7. 上移
                                MenuItem {
                                    text: "上移"
                                    onTriggered: moveWindowUp(programIndex, windowIndex)
                                }

                                // 8. 下移
                                MenuItem {
                                    text: "下移"
                                    onTriggered: moveWindowDown(programIndex, windowIndex)
                                }

                                MenuSeparator {}

                                // 9. 复制（Ctrl+C）
                                MenuItem {
                                    text: "复制"
                                    // shortcut: "Ctrl+C"
                                    onTriggered: copyWindow(programIndex, windowIndex)
                                }

                                // 10. 粘贴（Ctrl+V）
                                MenuItem {
                                    text: "粘贴"
                                    // shortcut: "Ctrl+V"
                                    onTriggered: pasteToWindow(programIndex, windowIndex)
                                }

                                // 11. 插入复制的视图（Ctrl+T）
                                MenuItem {
                                    text: "插入复制的视图"
                                    // shortcut: "Ctrl+T"
                                    onTriggered: insertCopiedView(programIndex, windowIndex)
                                }

                                MenuSeparator {}

                                // 12. 重命名（Ctrl+R）
                                MenuItem {
                                    text: "重命名"
                                    // shortcut: "Ctrl+R"
                                    onTriggered: renameWindow(programIndex, windowIndex)
                                }

                                // 13. 删除（Delete）
                                MenuItem {
                                    text: "删除"
                                    // shortcut: "Delete"
                                    onTriggered: deleteWindow(programIndex, windowIndex)
                                }
                            }

                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: 8
                                anchors.leftMargin: 40
                                spacing: 8

                                // 启用开关
                                CheckBox {
                                    id: windowEnabled
                                    checked: true

                                    indicator: Rectangle {
                                        implicitWidth: 16
                                        implicitHeight: 16
                                        color: parent.checked ? "#007ACC" : "#444444"
                                        border.color: "#666666"
                                        radius: 3

                                        Text {
                                            text: "G"
                                            color: "#FFFFFF"
                                            font.pixelSize: 8
                                            anchors.centerIn: parent
                                            visible: parent.parent.checked
                                        }
                                    }
                                }

                                // 类型图标
                                Text {
                                    text: "🖼"
                                    color: "#CCCCCC"
                                    font.pixelSize: 12
                                }

                                // 视窗名称
                                Text {
                                    text: modelData.name
                                    color: "#D4D4D4"
                                    font.pixelSize: 12
                                }

                                Item { Layout.fillWidth: true }

                                // 时长
                                Text {
                                    text: modelData.duration
                                    color: "#999999"
                                    font.pixelSize: 12
                                }
                            }

                            // 右键点击区域
                            MouseArea {
                                anchors.fill: parent
                                acceptedButtons: Qt.RightButton

                                onClicked: function(mouse) {
                                    if (mouse.button === Qt.RightButton) {
                                        contextMenuProgramIndex = programIndex
                                        contextMenuWindowIndex = windowIndex
                                        contextMenuSelectedItem = "window"
                                        windowContextMenu.open()
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // 函数：新建播放列表
    function createNewPlaylist(projectName) {
        console.log("创建播放列表:", projectName)

        // 更新播放列表名称
        currentPlaylistName = projectName + "-播放列表1"

        // 清空原有数据
        playlistData = []

        // 添加默认的节目1和视窗1
        playlistData.push({
            "name": "节目1",
            "type": "program",
            "duration": "0.00s",
            "expanded": true,
            "children": [
                {
                    "name": "监视1",
                    "type": "window",
                    "duration": "0.00s",
                    "children": []
                }
            ]
        })
    }

    // 函数：添加节目
    function addProgram(programName) {
        playlistData.push({
            "name": programName || "节目" + (playlistData.length + 1),
            "type": "program",
            "duration": "0.00s",
            "expanded": true,
            "children": []
        })
    }

    // 函数：添加视窗
    function addWindow(programIndex, windowName) {
        if (programIndex >= 0 && programIndex < playlistData.length) {
            playlistData[programIndex].children.push({
                "name": windowName || "监视" + (playlistData[programIndex].children.length + 1),
                "type": "window",
                "duration": "0.00s",
                "children": []
            })
        }
    }

    // 函数：获取总时长
    function getTotalDuration() {
        var totalSeconds = 0
        for (var i = 0; i < playlistData.length; i++) {
            var program = playlistData[i]
            var duration = parseFloat(program.duration)
            if (!isNaN(duration)) {
                totalSeconds += duration
            }
        }
        return totalSeconds.toFixed(2) + "s"
    }

    // 右键菜单功能函数

    // 添加视频/素材文件
    function addVideoMaterial(programIndex, windowIndex) {
        console.log("添加视频/素材文件到视窗:", programIndex, windowIndex)
        // 这里可以打开文件选择对话框
    }

    // 添加炫彩文字
    function addColorfulText(programIndex, windowIndex) {
        console.log("添加炫彩文字到视窗:", programIndex, windowIndex)
        animationEditorPopup.show()
    }

    // 添加屏幕录制
    function addScreenRecording(programIndex, windowIndex) {
        console.log("添加屏幕录制到视窗:", programIndex, windowIndex)
    }

    // 添加Flash
    function addFlash(programIndex, windowIndex) {
        console.log("添加Flash到视窗:", programIndex, windowIndex)
    }

    // 添加旋转文字
    function addRotatingText(programIndex, windowIndex) {
        console.log("添加旋转文字到视窗:", programIndex, windowIndex)
    }

    // 添加素材集
    function addMaterialSet(programIndex, windowIndex) {
        console.log("添加素材集到视窗:", programIndex, windowIndex)
    }

    // 上移视窗
    function moveWindowUp(programIndex, windowIndex) {
        console.log("上移视窗:", programIndex, windowIndex)
        if (programIndex >= 0 && programIndex < playlistData.length && windowIndex > 0) {
            var program = playlistData[programIndex]
            if (windowIndex < program.children.length) {
                // 交换当前元素和上一个元素
                var temp = program.children[windowIndex]
                program.children[windowIndex] = program.children[windowIndex - 1]
                program.children[windowIndex - 1] = temp
                // 触发UI更新
                playlistData = playlistData.slice()
            }
        }
    }

    // 下移视窗
    function moveWindowDown(programIndex, windowIndex) {
        console.log("下移视窗:", programIndex, windowIndex)
        if (programIndex >= 0 && programIndex < playlistData.length) {
            var program = playlistData[programIndex]
            if (windowIndex >= 0 && windowIndex < program.children.length - 1) {
                // 交换当前元素和下一个元素
                var temp = program.children[windowIndex]
                program.children[windowIndex] = program.children[windowIndex + 1]
                program.children[windowIndex + 1] = temp
                // 触发UI更新
                playlistData = playlistData.slice()
            }
        }
    }

    // 复制视窗
    function copyWindow(programIndex, windowIndex) {
        console.log("复制视窗:", programIndex, windowIndex)
        if (programIndex >= 0 && programIndex < playlistData.length) {
            var program = playlistData[programIndex]
            if (windowIndex >= 0 && windowIndex < program.children.length) {
                var windowData = program.children[windowIndex]
                console.log("复制视窗数据:", windowData.name)
                // 这里可以添加到剪贴板
            }
        }
    }

    // 粘贴到视窗
    function pasteToWindow(programIndex, windowIndex) {
        console.log("粘贴到视窗:", programIndex, windowIndex)
    }

    // 插入复制的视图
    function insertCopiedView(programIndex, windowIndex) {
        console.log("插入复制的视图到视窗:", programIndex, windowIndex)
    }

    // 重命名视窗
    function renameWindow(programIndex, windowIndex) {
        console.log("重命名视窗:", programIndex, windowIndex)
        // 这里可以弹出一个对话框让用户输入新名称
    }

    // 删除视窗
    function deleteWindow(programIndex, windowIndex) {
        console.log("删除视窗:", programIndex, windowIndex)
        if (programIndex >= 0 && programIndex < playlistData.length) {
            var program = playlistData[programIndex]
            if (windowIndex >= 0 && windowIndex < program.children.length) {
                // 从数组中删除指定索引的元素
                program.children.splice(windowIndex, 1)
                // 触发UI更新
                playlistData = playlistData.slice()
            }
        }
    }
}