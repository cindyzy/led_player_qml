import QtQuick 2.15

Rectangle {
    id: gradientSwatch
    property var gradientStops: [] // [{color: "#fff", position: 0}, ...]
    width: 60
    height: 20
    border.color: "#444444"
    signal swatchClicked(var stops)

    gradient: LinearGradient {
        x1: 0; y1: 0; x2: width; y2: 0 // 水平渐变
        Component.onCompleted: {
            for (var i = 0; i < gradientStops.length; ++i) {
                gradient.append(Qt.createQmlObject('import QtQuick 2.0; GradientStop { position: ' + gradientStops[i].position + '; color: "' + gradientStops[i].color + '" }', gradient, ""));
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: gradientSwatch.swatchClicked(gradientStops)
    }
}