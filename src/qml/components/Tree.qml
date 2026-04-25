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
        if (!model) {
            return null
        }

        // 对于C++模型，使用model.get方法
        if (model.get && typeof model.get === 'function') {
            return model.get(index)
        }

        // 检查是否是JavaScript数组模型
        if (Array.isArray(model) && index >= 0 && index < model.length) {
            return model[index]
        }

        return null
    }

    // 获取节点深度
    function getNodeDepth(index) {
        var nodeData = getNodeData(index)
        if (nodeData && nodeData.display) {
            return nodeData.display.TModel_depth || 0
        }
        return 0
    }

    // 检查节点是否有子节点
    function hasChildren(index) {
        var nodeData = getNodeData(index)
        if (nodeData && nodeData.display) {
            return nodeData.display.TModel_hasChildren || false
        }
        return false
    }

    // 检查节点是否展开
    function isExpanded(index) {
        var nodeData = getNodeData(index)
        if (nodeData && nodeData.display) {
            return nodeData.display.TModel_expend || false
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
        // 刷新整个视图以更新子节点的可见性
        listView.model = listView.model
    }

    // 折叠节点
    function collapse(index) {
        if (model && model.collapse) {
            model.collapse(index)
        }
        // 刷新整个视图以更新子节点的可见性
        listView.model = listView.model
    }

    // 展开所有节点
    function expandAll() {
        if (model && model.expandAll) {
            model.expandAll()
        }
        // 刷新整个视图以更新所有节点的可见性
        listView.model = listView.model
    }

    // 折叠所有节点
    function collapseAll() {
        if (model && model.collapseAll) {
            model.collapseAll()
        }
        // 刷新整个视图以更新所有节点的可见性
        listView.model = listView.model
    }

    // 展开到指定节点
    function expandTo(index) {
        if (model && model.expandTo) {
            model.expandTo(index)
        }
        // 刷新整个视图以更新节点的可见性
        listView.model = listView.model
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
            height:visible? effectiveHeight:0
            clip: effectiveHeight === 0
            visible: displayData.TModel_expend
            // 获取节点数据
            property var nodeData: model

            // 获取display对象
            property var displayData: nodeData && nodeData.display ? nodeData.display : null

            property int nodeDepth: {
                if (displayData) {
                    if (displayData.TModel_depth !== undefined) {
                        return displayData.TModel_depth
                    } else if (displayData.TModel_depth === 0) {
                        return 0
                    }
                }
                return 0
            }
            property bool nodeHasChildren: {
                if (displayData) {
                    if (displayData.TModel_hasChildren !== undefined) {
                        return displayData.TModel_hasChildren
                    }
                }
                return false
            }
            property bool nodeExpanded: {
                if (displayData) {
                    if (displayData.TModel_childrenExpend !== undefined) {
                        return displayData.TModel_childrenExpend
                    }
                }
                return falsenodeExpanded
            }
            property bool isSelected: listView.currentIndex === index

            // 计算节点是否可见（根据父节点的展开状态）
            property bool isVisible: {
                // 根节点总是可见
                if (nodeDepth === 0) return true

                // 查找当前节点的直接父节点
                // 父节点的深度比当前节点小1
                for (var i = index - 1; i >= 0; i--) {
                    var item = null

                    // 对于C++模型，使用listView.model.get
                    if (listView.model && listView.model.get) {
                        try {
                            item = listView.model.get(i)
                        } catch (e) {
                            console.log("Error getting item:", e)
                        }
                    } else {
                        // 对于JavaScript数组模型
                        item = treeView.getNodeData(i)
                    }

                    if (item) {
                        var itemDisplay = item.display ? item.display : item
                        if (itemDisplay.TModel_depth !== undefined && itemDisplay.TModel_depth === nodeDepth - 1) {
                            // 使用宽松比较，因为C++ bool可能转换为不同的类型
                            return itemDisplay.TModel_expend == true
                        }
                    }
                }
                return true
            }

            // 高度：如果不可见则高度为0
            property int effectiveHeight: isVisible ? itemHeight : 0

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
                                    treeView.collapse(index)
                                } else {
                                    treeView.expand(index)
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
                        text: displayData && displayData.icon ? displayData.icon : "📄"
                        font.pixelSize: 14
                        color: textColor
                        Layout.alignment: Qt.AlignVCenter
                    }

                    // 名称
                    Text {
                        id: nameText
                        text: {
                            if (displayData) {
                                // 尝试不同的方式获取name属性
                                if (displayData.name) {
                                    return displayData.name
                                } else if (displayData.toString && displayData.toString() !== '[object Object]') {
                                    return displayData.toString()
                                } else {
                                    return "节点 " + index
                                }
                            } else {
                                return "节点 " + index
                            }
                        }
                        font.pixelSize: 12
                        color: textColor
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignVCenter
                        elide: Text.ElideRight
                    }

                    // 时长（可选）
                    Text {
                        id: durationText
                        text: displayData && displayData.duration ? displayData.duration : ""
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
                    selectedItem = displayData
                    selectedIndex = index
                    treeView.itemClicked(displayData, index)
                }

                onDoubleClicked: {
                    if (nodeHasChildren) {
                        if (nodeExpanded) {
                            treeView.collapse(index)
                        } else {
                            treeView.expand(index)
                        }
                    }
                    treeView.itemDoubleClicked(displayData, index)
                }
            }
        }

        highlightFollowsCurrentItem: false
        highlight: Rectangle {
            visible: false
        }
    }
}