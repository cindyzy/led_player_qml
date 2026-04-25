// Tree.qml - 树视图组件，配合C++ TreeViewModel使用
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: treeView
    color: "transparent"

    // 属性
    property alias model: listView.model
    property alias currentIndex: listView.currentIndex
    property int itemHeight: 30
    property int indentation: 20
    property color textColor: "#D4D4D4"
    property color selectedColor: "#094771"
    property color hoverColor: "#2A2D2E"
    property color backgroundColor: "transparent"
    property color deleteButtonHoverColor: "#aa2e2e"   // 删除按钮悬停颜色
    property color addButtonHoverColor: "#4a5568"      // 添加按钮悬停颜色

    // 信号
    signal itemClicked(var item, int index)
    signal itemDoubleClicked(var item, int index)
    signal itemExpanded(var item, int index)
    signal itemCollapsed(var item, int index)
    signal addChildRequested(var item, int index)
    // 新增：删除节点请求信号（外部可监听，但内部已直接删除）
    signal deleteRequested(var item, int index)

    // 当前选中项
    property var selectedItem: null
    property int selectedIndex: -1

    // 获取节点数据（保持不变）
    function getNodeData(index) {
        if (!model) return null
        if (model.get && typeof model.get === 'function') {
            return model.get(index)
        }
        if (Array.isArray(model) && index >= 0 && index < model.length) {
            return model[index]
        }
        return null
    }

    function getNodeDepth(index) {
        var nodeData = getNodeData(index)
        return (nodeData && nodeData.display && nodeData.display.TModel_depth) || 0
    }

    function hasChildren(index) {
        var nodeData = getNodeData(index)
        return nodeData && nodeData.display && nodeData.display.TModel_hasChildren
    }

    function isExpanded(index) {
        var nodeData = getNodeData(index)
        return nodeData && nodeData.display && nodeData.display.TModel_expend
    }

    function addRootNode(nodeData) {
        if (model && model.addNode) return model.addNode(-1, nodeData)
        return -1
    }

    function addChildNode(parentIndex, nodeData) {
        if (model && model.addNode) return model.addNode(parentIndex, nodeData)
        return -1
    }

    // 删除节点（内部直接调用model的remove）
    function removeNode(index) {
        if (model && model.remove) {
            model.remove(index)
            // 可选：若删除后当前选中的索引失效，清空选中状态
            if (selectedIndex === index || selectedIndex > index) {
                selectedItem = null
                selectedIndex = -1
            }
        }
    }

    function clear() {
        if (model && model.clear) model.clear()
    }

    function expand(index) {
        if (model && model.expand) model.expand(index)
        listView.model = listView.model   // 刷新视图
    }

    function collapse(index) {
        if (model && model.collapse) model.collapse(index)
        listView.model = listView.model
    }

    function expandAll() {
        if (model && model.expandAll) model.expandAll()
        listView.model = listView.model
    }

    function collapseAll() {
        if (model && model.collapseAll) model.collapseAll()
        listView.model = listView.model
    }

    function expandTo(index) {
        if (model && model.expandTo) model.expandTo(index)
        listView.model = listView.model
    }

    // 列表视图
    ListView {
        id: listView
        anchors.fill: parent
        clip: true

        delegate: Item {
            id: delegateItem
            width: listView.width
            height: visible ? effectiveHeight : 0
            clip: effectiveHeight === 0
            visible: isVisible

            property var nodeData: model
            property var displayData: nodeData && nodeData.display ? nodeData.display : null

            property int nodeDepth: displayData?.TModel_depth ?? 0
            property bool nodeHasChildren: displayData?.TModel_hasChildren ?? false
            property bool nodeExpanded: displayData?.TModel_childrenExpend === true
            property bool isSelected: listView.currentIndex === index

            // 计算可见性（保持不变）
            property bool isVisible: {
                if (nodeDepth === 0) return true
                for (var i = index - 1; i >= 0; i--) {
                    var item = null
                    if (listView.model && listView.model.get) {
                        try { item = listView.model.get(i) } catch(e) {}
                    } else {
                        item = treeView.getNodeData(i)
                    }
                    if (item) {
                        var itemDisplay = item.display ? item.display : item
                        if (itemDisplay.TModel_depth === nodeDepth - 1) {
                            return itemDisplay.TModel_expend == true
                        }
                    }
                }
                return true
            }

            property int effectiveHeight: isVisible ? itemHeight : 0

            // 节点背景
            Rectangle {
                id: nodeBackground
                anchors.fill: parent
                color: nodeMouseArea.containsMouse ? hoverColor :
                                                    (isSelected ? selectedColor : backgroundColor)

                RowLayout {
                    id: rowLayout
                    anchors.fill: parent
                    anchors.leftMargin: nodeDepth * indentation + 5
                    anchors.rightMargin: 5
                    spacing: 5

                    // 展开/折叠按钮（不变）
                    Rectangle {
                        id: expandButton
                        width: 20; height: 20
                        color: "transparent"
                        visible: nodeHasChildren
                        enabled: nodeHasChildren
                        Text {
                            anchors.centerIn: parent
                            text: nodeExpanded ? "▼" : "▶"
                            color: textColor
                            font.pixelSize: 10
                        }
                        MouseArea {
                            id: expandMouseArea
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: function(mouseEvent) {
                                if (nodeExpanded) treeView.collapse(index)
                                else treeView.expand(index)
                                mouseEvent.accepted = true
                            }
                        }
                    }

                    Item { width: 20; height: 20; visible: !nodeHasChildren } // 占位符

                    Text {  // 图标
                        id: iconText
                        text: displayData?.icon || "📄"
                        font.pixelSize: 14
                        color: textColor
                        Layout.alignment: Qt.AlignVCenter
                    }

                    Text {  // 名称
                        id: nameText
                        text: {
                            if (displayData) {
                                if (displayData.name) return displayData.name
                                if (displayData.toString && displayData.toString() !== '[object Object]')
                                    return displayData.toString()
                                return "节点 " + index
                            }
                            return "节点 " + index
                        }
                        font.pixelSize: 12
                        color: textColor
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignVCenter
                        elide: Text.ElideRight
                    }

                    Text {  // 时长（可选）
                        id: durationText
                        text: displayData?.duration || ""
                        font.pixelSize: 10
                        color: "#999999"
                        Layout.alignment: Qt.AlignVCenter
                        visible: text !== ""
                    }

                    // ============= 添加按钮（原有） =============
                    Rectangle {
                        id: addChildButton
                        width: 20; height: 20
                        color: addChildMouseArea.containsMouse ? addButtonHoverColor : "transparent"
                        radius: 3
                        visible: displayData?.type !== "material"   // 保持原有逻辑
                        z: 100

                        Text {
                            anchors.centerIn: parent
                            text: "+"
                            color: textColor
                            font.pixelSize: 14
                            font.bold: true
                        }

                        MouseArea {
                            id: addChildMouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: function(mouseEvent) {
                                treeView.addChildRequested(displayData, index)
                                mouseEvent.accepted = true
                            }
                        }
                    }

                    // ============= 新增：删除按钮 =============
                    Rectangle {
                        id: deleteButton
                        width: 20; height: 20
                        color: deleteMouseArea.containsMouse ? deleteButtonHoverColor : "transparent"
                        radius: 3
                        visible: true   // 可自定义条件，例如只对非根节点显示
                        z: 100

                        Text {
                            anchors.centerIn: parent
                            text: "🗑"   // 或 "🗑" / "✖"
                            color: textColor
                            font.pixelSize: 12
                            font.bold: true
                        }

                        MouseArea {
                            id: deleteMouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: function(mouseEvent) {
                                // 直接调用删除函数
                                treeView.removeNode(index)
                                // 发射删除信号，供外部监听（可选）
                                treeView.deleteRequested(displayData, index)
                                mouseEvent.accepted = true
                            }
                        }
                    }
                }
            }

            // 节点鼠标区域（需要扩大右侧留空，避免遮挡两个按钮）
            MouseArea {
                id: nodeMouseArea
                anchors.fill: parent
                anchors.rightMargin: 50   // 原为30，现增加删除按钮宽度20+间距5 => 需留出约50
                hoverEnabled: true
                acceptedButtons: Qt.LeftButton | Qt.RightButton

                function isMouseOverButton(buttonItem, mouseX, mouseY) {
                    if (!buttonItem || !buttonItem.visible) return false
                    var globalPos = buttonItem.mapToItem(delegateItem, 0, 0)
                    var rect = Qt.rect(globalPos.x, globalPos.y, buttonItem.width, buttonItem.height)
                    return rect.contains(Qt.point(mouseX, mouseY))
                }

                function isMouseOverAnyButton(mouseX, mouseY) {
                    return isMouseOverButton(expandButton, mouseX, mouseY) ||
                           isMouseOverButton(addChildButton, mouseX, mouseY) ||
                           isMouseOverButton(deleteButton, mouseX, mouseY)
                }

                onClicked: function(mouseEvent) {
                    if (isMouseOverAnyButton(mouseEvent.x, mouseEvent.y)) return
                    listView.currentIndex = index
                    selectedItem = displayData
                    selectedIndex = index
                    treeView.itemClicked(displayData, index)
                }

                onDoubleClicked: function(mouseEvent) {
                    if (isMouseOverAnyButton(mouseEvent.x, mouseEvent.y)) return
                    if (nodeHasChildren) {
                        if (nodeExpanded) treeView.collapse(index)
                        else treeView.expand(index)
                    }
                    treeView.itemDoubleClicked(displayData, index)
                }

                onPositionChanged: function(mouseEvent) {
                    // 当鼠标移动到任意按钮上时，暂时隐藏自身的悬停效果
                    nodeMouseArea.containsMouse = !isMouseOverAnyButton(mouseEvent.x, mouseEvent.y)
                }
            }
        }

        highlightFollowsCurrentItem: false
        highlight: Rectangle { visible: false }
    }
}