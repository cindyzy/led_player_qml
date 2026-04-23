import QtQuick 2.15
//单色按钮
Rectangle {
    id: colorSwatch
    property color swatchColor: "#FFFFFF"
    width: 30
    height: 20
    color: swatchColor
    border.color: "#444444"
    signal swatchClicked(color c)

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: colorSwatch.swatchClicked(colorSwatch.swatchColor)
    }
}