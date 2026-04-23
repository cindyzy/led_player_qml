// PlaybackControlBar.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: controlBar
    color: "#252526"
    border.color: "#3E3E3E"
    border.width: 1

    RowLayout {
        anchors.fill: parent
        anchors.margins: 5
        spacing: 10

        // 播放/暂停按钮
        Button {
            id: playPauseButton
            text: "▶"
            implicitWidth: 40
            implicitHeight: 30

            background: Rectangle {
                color: parent.pressed ? "#007ACC" : "#333333"
                border.color: "#555555"
                radius: 4
            }

            contentItem: Text {
                text: parent.text
                color: "#D4D4D4"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            onClicked: {
                parent.text = parent.text === "▶" ? "⏸" : "▶"
            }
        }

        // 时间线滑块
        Slider {
            id: timelineSlider
            Layout.fillWidth: true
            from: 0
            to: 100
            value: 0

            background: Rectangle {
                x: timelineSlider.leftPadding
                y: timelineSlider.topPadding + timelineSlider.availableHeight / 2 - height / 2
                implicitWidth: 200
                implicitHeight: 4
                width: timelineSlider.availableWidth
                height: implicitHeight
                radius: 2
                color: "#555555"

                Rectangle {
                    width: timelineSlider.visualPosition * parent.width
                    height: parent.height
                    color: "#007ACC"
                    radius: 2
                }
            }

            handle: Rectangle {
                x: timelineSlider.leftPadding + timelineSlider.visualPosition * (timelineSlider.availableWidth - width)
                y: timelineSlider.topPadding + timelineSlider.availableHeight / 2 - height / 2
                implicitWidth: 16
                implicitHeight: 16
                radius: 8
                color: timelineSlider.pressed ? "#FFFFFF" : "#CCCCCC"
                border.color: "#666666"
            }
        }

        // 时间显示
        Text {
            text: "00:00:00/00:00:04"
            color: "#D4D4D4"
            font.pixelSize: 12
        }

        // 缩放控制
        RowLayout {
            spacing: 2

            Button {
                text: "-"
                implicitWidth: 30
                implicitHeight: 30

                background: Rectangle {
                    color: parent.pressed ? "#007ACC" : "#333333"
                    border.color: "#555555"
                    radius: 4
                }

                contentItem: Text {
                    text: parent.text
                    color: "#D4D4D4"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }

            Text {
                text: "400%"
                color: "#D4D4D4"
                font.pixelSize: 12
            }

            Button {
                text: "+"
                implicitWidth: 30
                implicitHeight: 30

                background: Rectangle {
                    color: parent.pressed ? "#007ACC" : "#333333"
                    border.color: "#555555"
                    radius: 4
                }

                contentItem: Text {
                    text: parent.text
                    color: "#D4D4D4"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }
    }
}