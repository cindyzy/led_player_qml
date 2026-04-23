import QtQuick 2.15
//渐变按钮
Rectangle {
    id: gradientSwatch
    property var gradientSwatchStops: [] // [{color: "#fff", position: 0}, ...]
    width: 60
    height: 20
    border.color: "#444444"
    signal swatchClicked(var stops)

    Canvas {
        id: canvas
        anchors.fill: parent
        onPaint: {
            var ctx = getContext("2d");
            ctx.reset();
            ctx.save();
            ctx.clearRect(0, 0, width, height);
            var g = ctx.createLinearGradient(0, 0, width, 0);
            for (var i = 0; i < gradientSwatch.gradientSwatchStops.length; ++i) {
                var s = gradientSwatch.gradientSwatchStops[i];
                // ensure position in [0,1]
                var pos = Math.max(0, Math.min(1, typeof s.position === 'number' ? s.position : 0));
                g.addColorStop(pos, s.color);
            }
            ctx.fillStyle = g;
            ctx.fillRect(0, 0, width, height);
            ctx.restore();
        }
        Component.onCompleted: canvas.requestPaint()
        onWidthChanged: canvas.requestPaint()
        onHeightChanged: canvas.requestPaint()
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: gradientSwatch.swatchClicked(gradientSwatchStops)
    }
    onGradientSwatchStopsChanged: canvas.requestPaint()
}

