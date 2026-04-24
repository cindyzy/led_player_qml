import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Window

Window {
    id: win
    width: 360
    height: 160
    title: "提示"
    modality: Qt.ApplicationModal   // 模态窗口，阻止操作其他窗口
    flags: Qt.FramelessWindowHint   // 无边框，自定义标题栏
    color: "#00000000"              // 窗口背景透明，内容由 contentItem 绘制

    // 对外属性
    property alias text: messageText.text

    // 便捷函数
    function success(titleText, msgText) {
        win.title = titleText
        messageText.text = msgText
        win.show()
    }
    function error(titleText, msgText) {
        win.title = titleText
        messageText.text = msgText
        win.show()
    }

    // 窗口内容（黑色背景圆角面板）
    Rectangle {
        anchors.fill: parent
        color: "#1E1E1E"            // 黑色背景
        border.color: "#3E3E3E"
        border.width: 1
        radius: 4

        // 自定义标题栏（可拖拽移动）
        Rectangle {
            id: titleBar
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            height: 30
            color: "#2D2D2D"
            radius: 4
            // 让标题栏顶部圆角与父窗口一致
            clip: true

            // 标题文字
            Text {
                text: win.title
                color: "#FFFFFF"
                font.pointSize: 11
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: 10
            }

            // 关闭按钮
            Button {
                width: 24
                height: 24
                anchors.right: parent.right
                anchors.rightMargin: 8
                anchors.verticalCenter: parent.verticalCenter
                text: "✕"
                font.pixelSize: 12
                flat: true
                background: Rectangle {
                    color: parent.hovered ? (parent.pressed ? "#E81123" : "#E81123") : "transparent"
                    radius: 2
                }
                contentItem: Text {
                    text: parent.text
                    color: parent.hovered ? "#FFFFFF" : "#CCCCCC"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                onClicked: win.close()
            }

            // 拖动移动窗口
            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton
                onPressed: (mouse) => {
                    if (win.startSystemMove) {
                        win.startSystemMove()   // Qt 5.15+ 原生拖动
                    } else {
                        // 低版本回退：手动记录位置
                        win.__dragPos = Qt.point(mouse.x, mouse.y)
                    }
                }
                onPositionChanged: (mouse) => {
                    if (!win.startSystemMove && pressed) {
                        win.x += mouse.x - win.__dragPos.x
                        win.y += mouse.y - win.__dragPos.y
                    }
                }
            }

            // 低版本存储拖动起点
            property point __dragPos: Qt.point(0,0)
        }

        // 内容区域
        ColumnLayout {
            anchors.top: titleBar.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: buttonRow.top
            spacing: 12
            anchors.margins: 8

            Text {
                id: messageText
                Layout.fillWidth: true
                Layout.fillHeight: true
                wrapMode: Text.Wrap
                color: "#F0F0F0"
                font.pixelSize: 12
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        }

        // 底部按钮（确定）
        RowLayout {
            id: buttonRow
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            anchors.margins: 8
            spacing: 8

            Button {
                text: "确定"
                implicitWidth: 60
                background: Rectangle {
                    color: parent.hovered ? "#3E3E3E" : "#2D2D2D"
                    border.color: "#555555"
                    border.width: 1
                    radius: 3
                }
                contentItem: Text {
                    text: parent.text
                    color: "#FFFFFF"
                    font.pointSize: 10
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                onClicked: win.close()
            }
        }
    }
}