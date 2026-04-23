import QtQuick 2.15
import QtQuick.Controls 2.15

Rectangle {
    id: button
    width: 320
    height: 50
    color: "transparent"
    border.color: "#FFFFFF"
    border.width: 1
    radius: 0

    property string text: ""
    property bool isHovered: mouseArea.containsMouse
    property bool isPressed: mouseArea.pressed

    signal clicked()

    // 背景颜色变化
    Behavior on color {
        ColorAnimation { duration: 150 }
    }

    // 文字
    Text {
        id: buttonText
        text: parent.text
        color: "#FFFFFF"
        font.pixelSize: 16
        font.bold: true
        anchors.centerIn: parent
    }

    // 鼠标区域
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        onClicked: {
            button.clicked()
        }

        onPressed: {
            button.color = "#333333"
        }

        onReleased: {
            button.color = isHovered ? "#222222" : "transparent"
        }

        onEntered: {
            button.color = "#222222"
        }

        onExited: {
            button.color = "transparent"
        }
    }
}