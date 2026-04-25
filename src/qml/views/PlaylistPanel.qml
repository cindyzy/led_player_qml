// PlaylistPanel.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQml.Models
import "../components"
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
    property var playlistData:[
        {
            name: "节目1",
            icon: "📁",
            duration: "10.00s",
            expanded: true,
            children: [
                {
                    name: "视窗1",
                    icon: "🖼",
                    duration: "5.00s",
                    expanded: false,
                    children: [
                        {
                            name: "素材1",
                            icon: "📄",
                            duration: "2.50s",
                            children: []
                        },
                        {
                            name: "素材2",
                            icon: "📄",
                            duration: "2.50s",
                            children: []
                        }
                    ]
                },
                {
                    name: "视窗2",
                    icon: "🖼",
                    duration: "5.00s",
                    expanded: false,
                    children: []
                }
            ]
        },
        {
            name: "节目2",
            icon: "📁",
            duration: "15.00s",
            expanded: false,
            children: [
                {
                    name: "视窗1",
                    icon: "🖼",
                    duration: "15.00s",
                    expanded: false,
                    children: []
                }
            ]
        },
        {
            name: "节目3",
            icon: "📁",
            duration: "20.00s",
            expanded: false,
            children: []
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
            Tree {
                id: treeView
                Layout.fillWidth: true
                Layout.fillHeight: true

                // 初始化模型数据
                model:playlistPanel.playlistData

                // 事件处理
                onItemClicked: function(item, index) {
                    console.log("点击节点:", item.name, "索引:", index)
                    // infoText.text = "选中: " + item.name
                }

                onItemDoubleClicked: function(item, index) {
                    console.log("双击节点:", item.name, "索引:", index)
                }

                onItemExpanded: function(item, index) {
                    console.log("展开节点:", item.name, "索引:", index)
                }

                onItemCollapsed: function(item, index) {
                    console.log("折叠节点:", item.name, "索引:", index)
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
        // 保存当前的节目和视窗索引
        currentProgramIndex = programIndex
        currentWindowIndex = windowIndex
        // 显示动画编辑器
        animationEditorDialog.show()
        animationEditorDialog.quickWiringConfig=previewArea.quickWiringConfig
    }
    
    // 保存当前操作的节目和视窗索引
    property int currentProgramIndex: -1
    property int currentWindowIndex: -1
    
    // 处理动画编辑器返回的素材库数据
    function handleMaterialReady(materialData) {
        console.log("收到素材库数据:", materialData.name)
        
        // 检查节目和视窗索引是否有效
        if (currentProgramIndex >= 0 && currentProgramIndex < playlistData.length) {
            var program = playlistData[currentProgramIndex]
            if (currentWindowIndex >= 0 && currentWindowIndex < program.children.length) {
                var window = program.children[currentWindowIndex]
                
                // 添加素材到视窗的子项
                window.children.push({
                                         name: materialData.name,
                                         type: materialData.type,
                                         duration: materialData.duration + "s",
                                         properties: materialData.properties
                                     })
                
                // 触发UI更新
                playlistData = playlistData.slice()
                
                console.log("素材已添加到视窗:", window.name)
            }
        }
        
        // 重置索引
        currentProgramIndex = -1
        currentWindowIndex = -1
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
    
    // 保存项目
    function saveProject() {
        var projectData = {
            name: currentPlaylistName,
            version: "1.0",
            saveDate: new Date().toISOString(),
            playlistData: playlistData
        };
        var projectJson = JSON.stringify(projectData, null, 2);

        var defaultFileName = currentPlaylistName.replace(/[^a-zA-Z0-9]/g, "_") + ".sproj";
        var saveDir = Qt.application.dataPath + "/projects/";
        var savePath = saveDir + defaultFileName;

        // 确保目录存在
        var dirError = fileHelper.ensureDirectoryExists(saveDir);
        if (dirError !== "") {
            console.error("创建目录失败:", dirError);
            messageDialog.error("保存失败", "无法创建保存目录:\n" + dirError);
            return;
        }

        // 保存文件
        var errorMsg = fileHelper.saveTextFile(savePath, projectJson);
        if (errorMsg === "") {
            console.log("项目保存成功:", savePath);
            messageDialog.success("保存成功", "项目已保存到:\n" + savePath);
        } else {
            console.error("保存失败:", errorMsg);
            messageDialog.error("保存失败", errorMsg);
        }
    }
    function loadProject(filePath) {
        var errorMsg = "";
        var content = fileHelper.readTextFile(filePath, errorMsg);
        if (errorMsg !== "") {
            console.error("读取失败:", errorMsg);
            messageDialog.error("打开失败", errorMsg);
            return;
        }

        try {
            var projectData = JSON.parse(content);
            // 恢复播放列表数据
            currentPlaylistName = projectData.name;
            playlistData = projectData.playlistData;
            console.log("项目加载成功");
        } catch (e) {
            console.error("JSON解析失败:", e);
            messageDialog.error("格式错误", "项目文件损坏或版本不兼容");
        }
    }
}