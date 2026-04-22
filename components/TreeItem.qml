// TreeItem.qml
import QtQuick
import QtQml.Models

QtObject {
    id: treeItem

    // 属性
    property string name: ""
    property string duration: ""
    property string icon: ""
    property bool expanded: false
    property var children: []
    property int depth: 0

    // 方法
    function addChild(item) {
        children.push(item)
    }

    function removeChild(index) {
        children.splice(index, 1)
    }
}