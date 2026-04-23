// VideoPreviewArea.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtMultimedia

Rectangle {
    id: previewArea
    color: "#1E1E1E"
    property var quickWiringConfig: null

    function applyQuickWiringPreview(config) {
        quickWiringConfig = config
        wiringCanvas.requestPaint()
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // 预览区域
        Rectangle {
            id: previewContainer
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "#000000"

            // 网格背景
            Grid {
                anchors.fill: parent
                columns: 8
                rows: 6
                spacing: 0

                Repeater {
                    model: 48
                    Rectangle {
                        width: previewContainer.width / 8
                        height: previewContainer.height / 6
                        color: index % 2 ? "#0A0A0A" : "#121212"
                        border.color: "#1A1A1A"
                        border.width: 1
                    }
                }
            }

            // 当前帧显示
            Text {
                anchors.centerIn: parent
                visible: !quickWiringConfig
                text: "预览区域"
                color: "#666666"
                font.pixelSize: 24
            }

            Canvas {
                id: wiringCanvas
                anchors.fill: parent
                anchors.margins: 5
                visible: !!quickWiringConfig
                z: 5
                onPaint: {
                    var ctx = getContext("2d")
                    ctx.clearRect(0, 0, width, height)
                    if (!quickWiringConfig) {
                        return
                    }

                    var baseWidthVal = Math.max(1, quickWiringConfig.width || 16)
                    var baseHeightVal = Math.max(1, quickWiringConfig.height || 8)
                    var hSpacing = Math.max(0, quickWiringConfig.hSpacing || 0)
                    var vSpacing = Math.max(0, quickWiringConfig.vSpacing || 0)
                    var direction = quickWiringConfig.direction || "wiring_StartLeftBottom_EndRightTop_M_Horizontal"

                    var hFactor = hSpacing + 1
                    var vFactor = vSpacing + 1
                    var widthVal = baseWidthVal * hFactor
                    var heightVal = baseHeightVal * vFactor

                    var baseCellWidth = (width - 20) / baseWidthVal
                    var baseCellHeight = (height - 20) / baseHeightVal
                    var cellWidth = baseCellWidth
                    var cellHeight = baseCellHeight
                    var drawWidth = widthVal * cellWidth
                    var drawHeight = heightVal * cellHeight
                    var routeCellWidth = baseCellWidth * hFactor
                    var routeCellHeight = baseCellHeight * vFactor
                    var squareSize = Math.max(2, Math.min(baseCellWidth, baseCellHeight) * 0.45)

                    // 黑色底图
                    ctx.fillStyle = "#000000"
                    ctx.fillRect(0, 0, drawWidth, drawHeight)

                    // 网格
                    ctx.strokeStyle = "#202020"
                    ctx.lineWidth = 1
                    for (var i = 0; i <= widthVal; i++) {
                        var gx = i * cellWidth
                        ctx.beginPath()
                        ctx.moveTo(gx, 0)
                        ctx.lineTo(gx, drawHeight)
                        ctx.stroke()
                    }
                    for (var j = 0; j <= heightVal; j++) {
                        var gy = j * cellHeight
                        ctx.beginPath()
                        ctx.moveTo(0, gy)
                        ctx.lineTo(drawWidth, gy)
                        ctx.stroke()
                    }

                    // 白色方块（替代圆圈）
                    ctx.fillStyle = "#FFFFFF"
                    for (j = 0; j < heightVal; j++) {
                        for (i = 0; i < widthVal; i++) {
                            var px = i * cellWidth + cellWidth / 2
                            var py = j * cellHeight + cellHeight / 2
                            ctx.fillRect(px - squareSize / 2, py - squareSize / 2, squareSize, squareSize)
                        }
                    }


                    ctx.stroke()
                }
            }

            // 安全框
            Rectangle {
                anchors.centerIn: parent
                width: parent.width * 0.9
                height: parent.height * 0.9
                color: "transparent"
                border.color: "#FF6B6B"
                border.width: 1
            }

            // 当前时间显示
            Text {
                anchors.top: parent.top
                anchors.right: parent.right
                anchors.margins: 10
                text: "00:00:00 / 00:00:04"
                color: "#FFFFFF"
                font.pixelSize: 12
                style: Text.Outline
                styleColor: "#000000"
            }
        }

        // 播放控制条
        PlaybackControlBar {
            id: controlBar
            Layout.fillWidth: true
            Layout.preferredHeight: 50
        }
    }
}