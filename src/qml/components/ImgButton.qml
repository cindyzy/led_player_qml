import QtQuick
import QtQuick.Controls
Button {
    id: upArrow

    width: 30
    height: 30

    background: Rectangle {
        color: "#333333"
        border.color: upArrow.hovered ? "#007ACC" : "#555555"
        border.width: 1
        radius: 3
    }

    contentItem: Text {
        text: text
        color: "#FFFFFF"
        font.pixelSize: 16
        anchors.centerIn: parent
    }

}
