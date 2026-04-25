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
    
    // 信号
    signal itemClicked(var item, int index)
    signal itemDoubleClicked(var item, int index)
    signal itemExpanded(var item, int index)
    signal itemCollapsed(var item, int index)
    
    // 当前选中项
    property var selectedItem: null
    property int selectedIndex: -1
    
    // 获取节点数据
    function getNodeData(index) {
        if (!model || index < 0 || index >= model.count) {
            return null
        }
        return model.data(model.index(index, 0), Qt.DisplayRole)
    }
    
    // 获取节点深度
    function getNodeDepth(index) {
        var nodeData = getNodeData(index)
        if (nodeData) {
            return nodeData.TModel_depth || 0
        }
        return 0
    }
    
    // 检查节点是否有子节点
    function hasChildren(index) {
        var nodeData = getNodeData(index)
        if (nodeData) {
            return nodeData.TModel_hasChildren || false
        }
        return false
    }
    
    // 检查节点是否展开
    function isExpanded(index) {
        var nodeData = getNodeData(index)
        if (nodeData) {
            return nodeData.TModel_expend || false
        }
        return false
    }
    
    // 添加根节点
    function addRootNode(nodeData) {
        if (model && model.addNode) {
            return model.addNode(-1, nodeData)
        }
        return -1
    }
    
    // 在指定父节点下添加子节点
    function addChildNode(parentIndex, nodeData) {
        if (model && model.addNode) {
            return model.addNode(parentIndex, nodeData)
        }
        return -1
    }
    
    // 删除节点
    function removeNode(index) {
        if (model && model.remove) {
            model.remove(index)
        }
    }
    
    // 清空所有节点
    function clear() {
        if (model && model.clear) {
            model.clear()
        }
    }
    
    // 展开节点
    function expand(index) {
        if (model && model.expand) {
            model.expand(index)
        }
    }
    
    // 折叠节点
    function collapse(index) {
        if (model && model.collapse) {
            model.collapse(index)
        }
    }
    
    // 展开所有节点
    function expandAll() {
        if (model && model.expandAll) {
            model.expandAll()
        }
    }
    
    // 折叠所有节点
    function collapseAll() {
        if (model && model.collapseAll) {
            model.collapseAll()
        }
    }
    
    // 展开到指定节点
    function expandTo(index) {
        if (model && model.expandTo) {
            model.expandTo(index)
        }
    }
    
    // 列表视图
    ListView {
        id: listView
        anchors.fill: parent
        clip: true
        
        // ScrollBar.horizontal.policy: ScrollBar.AsNeeded
        // ScrollBar.vertical.policy: ScrollBar.AsNeeded
        
        delegate: Item {
            id: delegateItem
            width: listView.width
            height: itemHeight
            
            property var nodeData: model.modelData
            property int nodeDepth: nodeData ? (nodeData.TModel_depth || 0) : 0
            property bool nodeHasChildren: nodeData ? (nodeData.TModel_hasChildren || false) : false
            property bool nodeExpanded: nodeData ? (nodeData.TModel_expend || false) : false
            property bool isSelected: listView.currentIndex === index
            
            // 节点背景
            Rectangle {
                anchors.fill: parent
                color: mouseArea.containsMouse ? hoverColor : 
                       (isSelected ? selectedColor : backgroundColor)
                
                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: nodeDepth * indentation + 5
                    anchors.rightMargin: 5
                    spacing: 5
                    
                    // 展开/折叠按钮
                    Rectangle {
                        id: expandButton
                        width: 20
                        height: 20
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
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (nodeExpanded) {
                                    if (model.collapse) {
                                        model.collapse(index)
                                    }
                                    treeView.itemCollapsed(nodeData, index)
                                } else {
                                    if (model.expand) {
                                        model.expand(index)
                                    }
                                    treeView.itemExpanded(nodeData, index)
                                }
                            }
                        }
                    }
                    
                    // 占位符（无子节点时）
                    Item {
                        width: 20
                        height: 20
                        visible: !nodeHasChildren
                    }
                    
                    // 图标
                    Text {
                        id: iconText
                        text: nodeData && nodeData.icon ? nodeData.icon : "📄"
                        font.pixelSize: 14
                        color: textColor
                        Layout.alignment: Qt.AlignVCenter
                    }
                    
                    // 名称
                    Text {
                        id: nameText
                        text: nodeData ? (nodeData.name || nodeData.title || nodeData.text || ("节点 " + index)) : ""
                        font.pixelSize: 12
                        color: textColor
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignVCenter
                        elide: Text.ElideRight
                    }
                    
                    // 时长（可选）
                    Text {
                        id: durationText
                        text: nodeData && nodeData.duration ? nodeData.duration : ""
                        font.pixelSize: 10
                        color: "#999999"
                        Layout.alignment: Qt.AlignVCenter
                        visible: text !== ""
                    }
                    
                    // 添加子节点按钮
                    Rectangle {
                        id: addChildButton
                        width: 20
                        height: 20
                        color: addChildMouseArea.containsMouse ? "#4a5568" : "transparent"
                        radius: 3
                        visible: mouseArea.containsMouse
                        
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
                            onClicked: {
                                var newNode = {
                                    name: "新节点",
                                    icon: "📄",
                                    duration: "0.00s"
                                }
                                treeView.addChildNode(index, newNode)
                            }
                        }
                    }
                }
            }
            
            // 鼠标区域
            MouseArea {
                id: mouseArea
                anchors.fill: parent
                hoverEnabled: true
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                
                onClicked: function(mouse) {
                    listView.currentIndex = index
                    selectedItem = nodeData
                    selectedIndex = index
                    treeView.itemClicked(nodeData, index)
                }
                
                onDoubleClicked: {
                    if (nodeHasChildren) {
                        if (nodeExpanded) {
                            if (model.collapse) {
                                model.collapse(index)
                            }
                            treeView.itemCollapsed(nodeData, index)
                        } else {
                            if (model.expand) {
                                model.expand(index)
                            }
                            treeView.itemExpanded(nodeData, index)
                        }
                    }
                    treeView.itemDoubleClicked(nodeData, index)
                }
            }
        }
        
        highlightFollowsCurrentItem: false
        highlight: Rectangle {
            visible: false
        }
    }
}