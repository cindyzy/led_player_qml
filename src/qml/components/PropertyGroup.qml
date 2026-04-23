// PropertyGroup.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ColumnLayout {
    id: propertyGroup
    property string title: ""
    property bool expanded: true

    Layout.fillWidth: true
    spacing: 8

    // 标题栏
    Rectangle {
        Layout.fillWidth: true
        height: 30
        color: expanded ? "#2D2D2D" : "#252526"
        border.color: "#3E3E3E"
        radius: 4

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 8
            anchors.rightMargin: 8
            spacing: 8

            // 展开/折叠按钮
            Button {
                id: expandButton
                width: 20
                height: 20
                text: expanded ? "▼" : "▶"
                flat: true

                contentItem: Text {
                    text: parent.text
                    color: "#999999"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                onClicked: expanded = !expanded
            }

            // 标题
            Text {
                text: title
                color: "#D4D4D4"
                font.bold: true
                Layout.fillWidth: true
            }
        }
    }

    // 内容区域
    ColumnLayout {
        id: contentArea
        Layout.fillWidth: true
        spacing: 8
        visible: expanded

        // 子项
        children: propertyGroup.children
    }
}