// TimelineEditor.qml
import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

Rectangle {
    id: control
    color: "#252526"
    border.color: "#3E3E3E"
    border.width: 1

    // 对外暴露的属性
    property string title: "LED文字效果编辑"
    property int totalFrames: 80
    property int totalDurationMs: 4000  // 总时长（毫秒）
    property int currentFrame: 1
    property int maxFrames: 80
    property int tickInterval: 5  // 刻度间隔
    property int tickCount: 20    // 刻度数量
    property color playheadColor: "#FF0000"
    property color backgroundColor: "#333333"
    property color borderColor: "#555555"
    property real playheadPosition: 0.85  // 0-1 之间的位置

    // 信号
    signal frameChanged(int frame)
    signal playheadMoved(real position)

    // 内部计算属性
    property string formattedDuration: {
        var seconds = Math.floor(totalDurationMs / 1000)
        var minutes = Math.floor(seconds / 60)
        var remainingSeconds = seconds % 60
        var hours = Math.floor(minutes / 60)
        minutes = minutes % 60
        return `${hours.toString().padStart(2, '0')}:${minutes.toString().padStart(2, '0')}:${remainingSeconds.toString().padStart(2, '0')}`
    }

    Layout.fillWidth: true
    Layout.preferredHeight: 100

    ColumnLayout {
        anchors.fill: parent
        spacing: 5
        anchors.margins: 10

        // 标题
        Text {
            text: control.title
            color: "#FFFFFF"
            font.bold: true
            font.pixelSize: 12
        }

        // 信息栏
        RowLayout {
            Text {
                text: `总帧数:${control.totalFrames}`
                color: "#CCCCCC"
                font.pixelSize: 12
            }
            Text {
                text: `总时长:${control.formattedDuration}`
                color: "#CCCCCC"
                font.pixelSize: 12
            }
            Item { Layout.fillWidth: true }
            Text {
                text: "轴标:"
                color: "#CCCCCC"
                font.pixelSize: 12
            }
            Text {
                text: control.currentFrame
                color: "#FFFFFF"
                font.bold: true
                font.pixelSize: 12
            }
        }

        // 时间轴区域
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: control.backgroundColor
            border.color: control.borderColor
            border.width: 1
            radius: 3

            // 刻度尺
            RowLayout {
                anchors.fill: parent
                anchors.margins: 5
                spacing: 0

                Repeater {
                    model: control.tickCount
                    Item {
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        Rectangle {
                            width: 1
                            height: 10
                            color: "#666666"
                            anchors.bottom: parent.bottom
                            anchors.horizontalCenter: parent.horizontalCenter
                        }

                        Text {
                            text: index * control.tickInterval
                            color: "#999999"
                            font.pixelSize: 8
                            anchors.top: parent.top
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                    }
                }
            }

            // 播放头（可拖动）
            Rectangle {
                id: playhead
                width: 2
                height: parent.height
                color: control.playheadColor
                x: parent.width * control.playheadPosition

                MouseArea {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.margins: -5
                    height: parent.height
                    cursorShape: Qt.SizeHorCursor
                    drag {
                        target: null
                        axis: Drag.XAxis
                        minimumX: 0
                        maximumX: parent.parent.width
                    }
                    onPositionChanged: function(mouse) {
                        var newX = Math.max(0, Math.min(parent.parent.width, mouse.x))
                        var newPosition = newX / parent.parent.width
                        control.playheadPosition = newPosition
                        var newFrame = Math.floor(newPosition * control.totalFrames) + 1
                        if (newFrame !== control.currentFrame) {
                            control.currentFrame = Math.min(newFrame, control.totalFrames)
                            control.frameChanged(control.currentFrame)
                        }
                        control.playheadMoved(newPosition)
                    }
                }
            }
        }
    }

    // 公共方法
    function setPlayheadPosition(position) {
        playheadPosition = Math.max(0, Math.min(1, position))
        var newFrame = Math.floor(playheadPosition * totalFrames) + 1
        currentFrame = Math.min(newFrame, totalFrames)
        frameChanged(currentFrame)
    }

    function setFrame(frame) {
        currentFrame = Math.max(1, Math.min(frame, totalFrames))
        playheadPosition = (currentFrame - 1) / totalFrames
        frameChanged(currentFrame)
    }

    function reset() {
        setFrame(1)
    }
}