import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "../components"
Popup {
    id: newWiringDialog
    width: 400
    height: 500
    modal: true
    focus: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent
    anchors.centerIn: Overlay.overlay
    padding: 0

    property int dragMouseX: 0
    property int dragMouseY: 0
    property bool dragging: false
    signal newWiringClicked()
    signal quickWiringClicked()
    signal importWiringClicked()
    signal importDXFClicked()
    signal importTableClicked()
    signal skipWiringClicked()

    // 背景
    background: Rectangle {
        color: "#000000"
        border.color: "#FFFFFF"
        border.width: 1
    }

    // 可拖动的标题栏
    Rectangle {
        id: titleBar
        width: parent.width
        height: 40
        color: "#111111"

        // 标题
        Text {
            text: "新建布线"
            color: "#FFFFFF"
            font.pixelSize: 18
            font.bold: true
            anchors.left: parent.left
            anchors.leftMargin: 20
            anchors.verticalCenter: parent.verticalCenter
        }

        // 关闭按钮
        Rectangle {
            id: closeButton
            width: 30
            height: 30
            color: "transparent"
            anchors {
                verticalCenter: parent.verticalCenter
                right: parent.right
                rightMargin: 10
            }

            Canvas {
                anchors.fill: parent
                onPaint: {
                    var context = getContext("2d")
                    context.reset()
                    context.strokeStyle = "#FFFFFF"
                    context.lineWidth = 2
                    context.beginPath()
                    context.moveTo(5, 5)
                    context.lineTo(25, 25)
                    context.moveTo(25, 5)
                    context.lineTo(5, 25)
                    context.stroke()
                }
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: newWiringDialog.close()

                onEntered: {
                    closeButton.opacity = 0.7
                }

                onExited: {
                    closeButton.opacity = 1.0
                }
            }
        }

        // 拖动区域
        MouseArea {
            id: dragArea
            anchors.fill: parent
            cursorShape: Qt.SizeAllCursor

            onPressed: {
                dragging = true
                startDragPos = Qt.point(mouse.x, mouse.y)
            }

            onPositionChanged: {
                if (dragging) {
                    var deltaX = mouse.x - startDragPos.x
                    var deltaY = mouse.y - startDragPos.y
                    newWiringDialog.x += deltaX
                    newWiringDialog.y += deltaY
                }
            }

            onReleased: {
                dragging = false
            }
        }

    }

    // 主内容区域
    ColumnLayout {
        anchors {
            top: titleBar.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            topMargin: 30
            bottomMargin: 20
            leftMargin: 40
            rightMargin: 40
        }
        spacing: 20

        // 新建布线图按钮
        WiringButton {
            id: newWiringButton
            text: "新建布线图"
            Layout.fillWidth: true
            Layout.preferredHeight: 50

            onClicked: {
                newWiringDialog.newWiringClicked()
                newWiringDialog.close()
            }
        }

        // 快速布线按钮
        WiringButton {
            id: quickWiringButton
            text: "快速布线"
            Layout.fillWidth: true
            Layout.preferredHeight: 50

            onClicked: {
                newWiringDialog.quickWiringClicked()
                newWiringDialog.close()
                quickWiringDialog.open()
            }
        }

        // 导入布线图按钮
        WiringButton {
            id: importWiringButton
            text: "导入布线图"
            Layout.fillWidth: true
            Layout.preferredHeight: 50

            onClicked: {
                newWiringDialog.importWiringClicked()
                newWiringDialog.close()
            }
        }

        // 导入DXF按钮
        WiringButton {
            id: importDXFButton
            text: "导入DXF"
            Layout.fillWidth: true
            Layout.preferredHeight: 50

            onClicked: {
                newWiringDialog.importDXFClicked()
                newWiringDialog.close()
            }
        }

        // 导入表格(POSI)按钮
        WiringButton {
            id: importTableButton
            text: "导入表格(POSI)"
            Layout.fillWidth: true
            Layout.preferredHeight: 50

            onClicked: {
                newWiringDialog.importTableClicked()
                newWiringDialog.close()
            }
        }

        // 暂不布线按钮
        WiringButton {
            id: skipWiringButton
            text: "暂不布线"
            Layout.fillWidth: true
            Layout.preferredHeight: 50

            onClicked: {
                newWiringDialog.skipWiringClicked()
                newWiringDialog.close()
            }
        }

        // 占位空间
        Item {
            Layout.fillHeight: true
        }
    }

    // 显示/隐藏动画
    enter: Transition {
        NumberAnimation {
            property: "opacity";
            from: 0;
            to: 1;
            duration: 200
        }
        NumberAnimation {
            property: "scale";
            from: 0.9;
            to: 1;
            duration: 200;
            easing.type: Easing.OutBack
        }
    }

    exit: Transition {
        NumberAnimation {
            property: "opacity";
            from: 1;
            to: 0;
            duration: 150
        }
        NumberAnimation {
            property: "scale";
            from: 1;
            to: 0.9;
            duration: 150;
            easing.type: Easing.InCubic
        }
    }
}
