// main.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import DMX512LEDController

ApplicationWindow {
    id: root
    width: 1200
    height: 800
    visible: true
    title: "DMX512-A LED灯光控制器演示"
    color: "#2c3e50"

    property var dmxCtrl: DMXController { }

    header: ToolBar {
        background: Rectangle { color: "#1a252f" }
        RowLayout {
            anchors.fill: parent
            Label {
                text: "DMX512-A 灯光控制协议 (WH/T 32—2008)"
                font.pixelSize: 18
                font.bold: true
                color: "#ecf0f1"
                Layout.leftMargin: 16
            }
            Item { Layout.fillWidth: true }
            Button {
                text: "重置所有通道"
                onClicked: dmxCtrl.resetAllChannels()
                flat: false
                background: Rectangle { color: "#e67e22"; radius: 4 }
                contentItem: Text { text: parent.text; color: "white" }
            }
            Button {
                text: "全亮"
                onClicked: dmxCtrl.setAllChannels(255)
                background: Rectangle { color: "#27ae60"; radius: 4 }
                contentItem: Text { text: parent.text; color: "white" }
            }
            Button {
                text: "清除日志"
                onClicked: dmxCtrl.clearLog()
                background: Rectangle { color: "#95a5a6"; radius: 4 }
                contentItem: Text { text: parent.text; color: "white" }
            }
        }
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 16

        // 左侧: 8个LED通道控制面板
        ScrollView {
            Layout.fillWidth: true
            Layout.minimumWidth: 380
            Layout.preferredWidth: 420
            Layout.fillHeight: true
            clip: true

            ColumnLayout {
                width: parent.width
                spacing: 12

                Label {
                    text: "DMX512 数据通道 (字段1~8)"
                    font.pixelSize: 16
                    font.bold: true
                    color: "#ecf0f1"
                }

                Repeater {
                    model: 8
                    delegate: Rectangle {
                        Layout.fillWidth: true
                        height: 100
                        color: "#34495e"
                        radius: 8
                        border.color: "#2c3e50"

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 8
                            spacing: 12

                            Rectangle {
                                width: 60
                                height: 60
                                radius: 30
                                color: Qt.hsla(0.55, 0.8, 0.5, 1)
                                border.color: "#ecf0f1"
                                border.width: 2
                                opacity: {
                                    var value = dmxCtrl["channel" + index];
                                    return 0.2 + (value / 255.0) * 0.8;
                                }
                                Behavior on opacity { NumberAnimation { duration: 20 } }

                                Label {
                                    anchors.centerIn: parent
                                    text: (index + 1).toString()
                                    color: "white"
                                    font.bold: true
                                    font.pixelSize: 18
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 4

                                Label {
                                    text: "通道 " + (index + 1)
                                    font.bold: true
                                    color: "#ecf0f1"
                                }
                                Slider {
                                    id: slider
                                    Layout.fillWidth: true
                                    from: 0
                                    to: 255
                                    stepSize: 1
                                    value:  dmxCtrl.channels[index]
                                    onValueChanged: {
                                        // console.log("setChannel:" + index)
                                        var channel=dmxCtrl.channels[index]
                                        // console.log("channel:" +dmxCtrl.channel0)
                                        // console.log("channels:" +channel)
                                          // console.log(dmxCtrl["setChannel" + index](value))
                                        dmxCtrl.channels[index]=value;
                                    }
                                    background: Rectangle {
                                        implicitHeight: 8
                                        color: "#7f8c8d"
                                        radius: 4
                                        Rectangle {
                                            width: slider.visualPosition * parent.width
                                            height: parent.height
                                            color: "#f39c12"
                                            radius: 4
                                        }
                                    }
                                }
                                Label {
                                    text: "数值: " + slider.value + " / 255"
                                    color: "#bdc3c7"
                                    font.pixelSize: 12
                                }
                            }

                            Rectangle {
                                width: 40
                                height: 20
                                radius: 10
                                color: {
                                    var lvl =dmxCtrl.channels[index] / 255;
                                    return Qt.rgba(1, 1, 1, lvl);
                                }
                                border.color: "#bdc3c7"
                            }
                        }
                    }
                }

                // 动画模式选择
                GroupBox {
                    title: "LED 动画效果 (符合DMX512数据动态刷新)"
                    Layout.fillWidth: true
                    Layout.topMargin: 8
                    background: Rectangle { color: "#2c3e50"; radius: 6; border.color: "#1abc9c" }
                    label: Label { text: parent.title; color: "#1abc9c"; font.bold: true }

                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 8
                        RowLayout {
                            spacing: 12
                            ButtonGroup { id: animGroup }
                            Repeater {
                                model: ["静态(手动)", "呼吸效果", "彩虹轮", "跑马灯", "正弦波"]
                                Button {
                                    text: modelData
                                    checkable: true
                                    ButtonGroup.group: animGroup
                                    checked: (index === dmxCtrl.animationMode)
                                    onClicked: dmxCtrl.animationMode = index
                                    background: Rectangle {
                                        color: parent.checked ? "#1abc9c" : "#34495e"
                                        radius: 6
                                    }
                                    contentItem: Text {
                                        text: parent.text
                                        color: parent.checked ? "#2c3e50" : "#ecf0f1"
                                        horizontalAlignment: Text.AlignHCenter
                                    }
                                }
                            }
                        }
                        RowLayout {
                            Label { text: "自动发送数据包:"; color: "#ecf0f1" }
                            Switch {
                                id: autoSendSwitch
                                checked: dmxCtrl.autoSendEnabled
                                onCheckedChanged: dmxCtrl.autoSendEnabled = checked
                            }
                            Label { text: autoSendSwitch.checked ? "启用 (刷新率约20Hz)" : "禁用(手动拖动滑块发送)"; color: "#bdc3c7"; font.pixelSize: 11 }
                        }
                    }
                }
            }
        }

        // 右侧: DMX512协议细节与日志输出
        ColumnLayout {
            Layout.fillWidth: true
            Layout.preferredWidth: 400
            Layout.fillHeight: true

            GroupBox {
                title: "DMX512-A 协议数据包监控"
                Layout.fillWidth: true
                Layout.fillHeight: true
                background: Rectangle { color: "#1e272e"; radius: 8 }
                label: Label { text: parent.title; color: "#f1c40f"; font.bold: true }

                ScrollView {
                    anchors.fill: parent
                    anchors.margins: 8
                    clip: true
                    ListView {
                        id: logView
                        model: dmxCtrl.logMessages
                        spacing: 4
                        delegate: Rectangle {
                            width: parent.width
                            height: 32
                            color: index % 2 ? "#2c3e50" : "#34495e"
                            radius: 4
                            Label {
                                anchors.fill: parent
                                anchors.leftMargin: 8
                                text: modelData
                                color: "#ecf0f1"
                                font.pixelSize: 11
                                font.family: "Courier"
                                verticalAlignment: Text.AlignVCenter
                                wrapMode: Text.Wrap
                                elide: Text.ElideRight
                            }
                        }
                        onCountChanged: positionViewAtIndex(0, ListView.Beginning)
                    }
                }
            }

            GroupBox {
                title: "DMX512-A 标准摘要 (ANSI E1.11-2004 / WH/T 32—2008)"
                Layout.fillWidth: true
                Layout.preferredHeight: 240
                background: Rectangle { color: "#1e272e"; radius: 8 }
                label: Label { text: parent.title; color: "#3498db"; font.bold: true }

                Flickable {
                    anchors.fill: parent
                    anchors.margins: 8
                    contentHeight: infoText.implicitHeight
                    ScrollBar.vertical: ScrollBar { }
                    Text {
                        id: infoText
                        width: parent.width
                        wrapMode: Text.WordWrap
                        color: "#ecf0f1"
                        font.pixelSize: 12
                        text: "• 电气特性: EIA-485-A 平衡传输，差分信号，异步串行格式\n" +
                              "• 数据包结构: 复位信号(Break ≥88μs) + 复位后标记(MAB 12μs) + 起始码(字段0) + 数据字段(1~512)\n" +
                              "• 起始码: 00h为零起始码(调光数据或通用数据)，01h~FFh为备用起始码(扩展用途)\n" +
                              "• 本控制器使用零起始码数据包，最多支持512个通道，演示8通道LED亮度控制\n" +
                              "• 刷新率:每秒至少1次，典型值44Hz，本演示动画模式定时刷新数据包\n" +
                              "• 接地拓扑:推荐隔离接收器/参考地发送器，设备标记符合标准\n" +
                              "• 数据字段值0~255对应LED亮度/调光等级(0=关闭,255=最大)\n" +
                              "• 备用起始码用于系统信息或文本(SIP包)，本demo未使用但符合标准扩展理念"
                    }
                }
            }
        }
    }

    footer: Rectangle {
        height: 28
        color: "#1a252f"
        Label {
            anchors.centerIn: parent
            text: "符合WH/T 32—2008 (DMX512-A) | 演示LED控制器 | 使用异步串行协议模拟数据包发送"
            color: "#7f8c8d"
            font.pixelSize: 10
        }
    }
}