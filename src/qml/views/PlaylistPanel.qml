// PlaylistPanel.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQml.Models
import "../components"
// import "qrc:/qml/components"
import LedPlayer
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

    // 创建PlaylistTreeModel实例
    PlaylistTreeModel {
        id: playlistTreeModel
        Component.onCompleted: {
            initializeModel()
            setBusinessController(businessController)
            console.log("PlaylistTreeModel initialized")
        }
    }

    // 属性：播放列表数据 - 适配Tree.qml和C++ TreeViewModel

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

                // 使用PlaylistTreeModel
                model: playlistTreeModel
                // 事件处理
                onItemClicked: function(item, index) {
                    // console.log("点击节点:", item.name, "索引:", index)
                    // infoText.text = "选中: " + item.name
                }

                onItemDoubleClicked: function(item, index) {
                    console.log("双击节点:", item.name, "索引:", index)
                    // playlistTreeModel.collapse(index)
                }

                onItemExpanded: function(item, index) {
                    console.log("展开节点:", item.name, "索引:", index)
                    // playlistTreeModel.expand(index)
                }

                onItemCollapsed: function(item, index) {
                    console.log("折叠节点:", item.name, "索引:", index)
                    // playlistTreeModel.collapse(index)
                }
                onAddChildRequested:{
                    var type=item.type
                    switch(type)
                    {
                    case "program":
                        playlistTreeModel.createWindowNode(index)
                        break
                    case "window":
                        playlistTreeModel.createMaterialNode(index)
                        break
                    }

                }
                onDeleteRequested: {
                    var type=item.type
                    switch(type)
                    {
                    case "program":
                        playlistTreeModel.removeProgramNode(index)
                        break
                    case "window":
                        playlistTreeModel.removeWindowNode(index)
                        break
                    case "material":
                        playlistTreeModel.removeMaterialNode(index)
                        break
                    }
                }
            }
RowLayout{
    ToolButton {
            text: "➕"  // 或使用图标
            font.pixelSize: 16
            ToolTip.text: "新建节目"
            ToolTip.visible: hovered
            onClicked: playlistTreeModel.createProgramNode(-1)
        }

        ToolButton {
            text: "📋"
            font.pixelSize: 16
            ToolTip.text: "复制节目"
            ToolTip.visible: hovered
            onClicked: copySelectedProgram()
        }

        ToolButton {
            text: "⬆️"
            font.pixelSize: 16
            ToolTip.text: "上移节目"
            ToolTip.visible: hovered
            onClicked: moveProgramUp()
        }

        ToolButton {
            text: "⬇️"
            font.pixelSize: 16
            ToolTip.text: "下移节目"
            ToolTip.visible: hovered
            onClicked: moveProgramDown()
        }
}

        }
    }
    // 获取当前选中的节目在根节点中的索引
    function getSelectedProgramIndex() {
        if (treeView.selectedIndex === -1) {
            console.warn("未选中任何节点")
            return -1
        }

        var node = treeView.selectedItem
        if (!node ) {
            console.warn("无效的选中节点")
            return -1
        }
        // 深度为 0 表示是节目（根节点）
        if (node.TModel_depth !== 0) {
            console.warn("选中的不是节目，请选中节目节点")
            return -1
        }
        // 获取该节目在根节点列表中的实际行号
        // 假设模型提供了 getProgramRow(proxyIndex) 方法，或直接使用 treeView.selectedIndex
        // 注意：treeView.selectedIndex 是代理模型中的行号（含所有展开项），不能直接作为根节点行号
        // 正确做法：调用模型的 rowOfNode 接口（需 C++ 实现）
        // if (playlistTreeModel.getProgramRow) {
            // return playlistTreeModel.getProgramRow(treeView.selectedIndex)
        // } else {
            // 如果模型未暴露，可暂时使用 selectedIndex，但移动时可能出错
            // console.warn("模型未实现 getProgramRow，使用 selectedIndex 替代，移动功能可能不正确")
            return treeView.selectedIndex
        // }
    }

    // 复制当前选中的节目
    function copySelectedProgram() {
        var programIndex = getSelectedProgramIndex()
        if (programIndex === -1) return

        // 调用模型的复制方法（假设存在）
        if (playlistTreeModel.copyProgramNode) {
            playlistTreeModel.copyProgramNode(programIndex)
            console.log("复制节目，源索引:", programIndex)
        } else {
            console.error("模型未实现 copyProgramNode 方法，请在 C++ 中实现")
            // 备用方案：手动获取节点数据并添加（需要模型支持 addNode）
            // var nodeData = playlistTreeModel.getNodeData(programIndex)  // 需要模型提供
            // if (nodeData) playlistTreeModel.addNode(-1, nodeData)
        }
    }

    // 上移当前选中的节目
    function moveProgramUp() {
        var programIndex = getSelectedProgramIndex()
        if (programIndex === -1) return
        if (programIndex === 0) {
            console.log("已在最顶部，无法上移")
            return
        }
        playlistTreeModel.moveRow(programIndex, programIndex - 1)
        treeView.selectedIndex =programIndex -1
    }

    // 下移当前选中的节目
    function moveProgramDown() {
        var programIndex = getSelectedProgramIndex()
        if (programIndex === -1) return
        // 需要知道根节点总数，假设模型提供 getProgramCount 方法
        var maxIndex = playlistTreeModel.getProgramCount ? playlistTreeModel.getProgramCount() - 1 : -1
        if (maxIndex !== -1 && programIndex >= maxIndex) {
            console.log("已在最底部，无法下移")
            return
        }
        playlistTreeModel.moveRow(programIndex, programIndex +1)
        treeView.selectedIndex =programIndex +1

    }
    // 函数：新建播放列表
    function createNewPlaylist(projectName) {
        console.log("创建播放列表:", projectName)

        // 更新播放列表名称
        currentPlaylistName = projectName + "-播放列表1"

        // 清空原有数据
        playlistData = []

        // 添加默认的节目1和视窗1 - 适配Tree.qml
        playlistData.push({
                              "name": "节目1",
                              "type": "program",
                              "duration": "0.00s",
                              "TModel_depth": 0,
                              "TModel_expend": true,
                              "TModel_hasChildren": true,
                              "children": [
                                  {
                                      "name": "视窗1",
                                      "type": "window",
                                      "duration": "0.00s",
                                      "TModel_depth": 1,
                                      "TModel_expend": false,
                                      "TModel_hasChildren": false,
                                      "children": []
                                  }
                              ]
                          })
    }


    // 函数：添加视窗
    function addWindow(programIndex, windowName) {
        if (programIndex >= 0 && programIndex < playlistData.length) {
            var newWindow = {
                                 "name": windowName || "视窗" + (playlistData[programIndex].children.length + 1),
                                 "type": "window",
                                 "duration": "0.00s",
                                 "TModel_depth": 1,
                                 "TModel_expend": false,
                                 "TModel_hasChildren": false,
                                 "children": []
                             }
            playlistData[programIndex].children.push(newWindow)
            // 更新父节点的hasChildren
            playlistData[programIndex].TModel_hasChildren = true
            playlistData = playlistData.slice()
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
                
                // 添加素材到视窗的子项 - 适配Tree.qml
                window.children.push({
                                         name: materialData.name,
                                         type: materialData.type,
                                         duration: materialData.duration + "s",
                                         TModel_depth: 2,
                                         TModel_expend: false,
                                         TModel_hasChildren: false,
                                         properties: materialData.properties
                                     })
                
                // 更新视窗的hasChildren
                window.TModel_hasChildren = true
                
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
                // 更新父节点的hasChildren
                program.TModel_hasChildren = program.children.length > 0
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