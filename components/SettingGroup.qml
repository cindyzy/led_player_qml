import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

GroupBox {
    id: groupBox
    Layout.fillWidth: true
    padding: 12
    topPadding: 10

    label: Label {
        text: groupBox.title
        color: "white"
        font.bold: true
        topPadding: 2
        bottomPadding: 2
    }

    background: Rectangle {
        color: "#2d2d2d"
        radius: 4
        border.color: "#404040"
        border.width: 1
    }
}