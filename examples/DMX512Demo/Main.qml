import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtQuick.Window 2.12
import ArtNet
ApplicationWindow {
    visible: true
    width: 700
    height: 850
    title: "ArtNet 配置软件"

    property bool udpOpen: false

    // 连接C++对象
    UdpManager {
        id: udpManager
        onBoundChanged: udpOpen = udpManager.isBound
        onDataReceived: function(fromIp, fromPort, hexData, asciiData) {
                logArea.appendText(`[${fromIp}:${fromPort}] Hex: ${hexData}`)
                logArea.appendText(`[${fromIp}:${fromPort}] Ascii: ${asciiData}`)
            }

            onNodeFound: function(ip, shortName) {
                logArea.appendText(`[节点发现] ${ip} - ${shortName}`)
            }
    }

    ScrollView {
        anchors.fill: parent
        contentWidth: availableWidth
        clip: true

        ColumnLayout {
            width: parent.width - 20
            anchors.centerIn: parent
            spacing: 12

            // 端口区域
            GroupBox {
                title: "网络设置"
                Layout.fillWidth: true
                GridLayout {
                    columns: 2
                    rowSpacing: 8
                    columnSpacing: 12

                    Label { text: "对方端口号：" }
                    TextField { id: remotePortTf; text: "6454"; Layout.fillWidth: true }

                    Label { text: "本地端口号：" }
                    TextField { id: localPortTf; text: "6454"; Layout.fillWidth: true }

                    Label { text: "对方IP：" }
                    TextField { id: remoteIpTf; text: "192.168.1.100"; Layout.fillWidth: true }

                    Label { text: "本地IP：" }
                    ComboBox {
                        id: localIpCombo
                        model: udpManager.localIpList
                        currentIndex: 0
                        Layout.fillWidth: true
                    }

                    Button {
                        text: udpOpen ? "关闭UDP" : "打开UDP"
                        onClicked: {
                            if (!udpOpen) {
                                if (udpManager.bindPort(parseInt(localPortTf.text)))
                                    logArea.appendText("UDP 绑定成功，本地端口 " + localPortTf.text)
                                else
                                    logArea.appendText("UDP 绑定失败")
                            } else {
                                udpManager.unbind()
                                logArea.appendText("UDP 已关闭")
                            }
                        }
                    }

                    Button { text: "获取IP状态"; onClicked: udpManager.sendData(remoteIpTf.text, parseInt(remotePortTf.text), "GET_IP_STATUS") }
                    Button { text: "发送修改"; onClicked: udpManager.sendNetConfig(remoteIpTf.text, parseInt(remotePortTf.text), dhcpSwitch.checked, ipTf.text, maskTf.text, gatewayTf.text) }
                }
            }

            // ArtNet 功能区域
            RowLayout {
                Button { text: "ArtNet"; onClicked: logArea.appendText("ArtNet 模式已选") }
                Button { text: "DMX512"; onClicked: logArea.appendText("DMX512 模式已选") }
                Button { text: "刷新"; onClicked: udpManager.sendArtPoll(remoteIpTf.text, parseInt(remotePortTf.text)) }
                CheckBox { id: customProtocolCb; text: "开启自定义协议" }
            }

            // DHCP / IP配置区域
            GroupBox {
                title: "网络参数配置 (发送给对方IP)"
                Layout.fillWidth: true
                GridLayout {
                    columns: 4
                    rowSpacing: 8
                    columnSpacing: 8

                    Label { text: "DHCP" }
                    Switch { id: dhcpSwitch; Layout.columnSpan: 3 }

                    Label { text: "IP地址" }
                    TextField { id: ipTf; text: "192.168.1.200"; Layout.fillWidth: true; Layout.columnSpan: 3 }

                    Label { text: "子网掩码" }
                    TextField { id: maskTf; text: "255.255.255.0"; Layout.fillWidth: true; Layout.columnSpan: 3 }

                    Label { text: "网关" }
                    TextField { id: gatewayTf; text: "192.168.1.1"; Layout.fillWidth: true; Layout.columnSpan: 3 }
                }
            }

            // 设备模式
            GroupBox {
                title: "设备模式"
                Layout.fillWidth: true
                RowLayout {
                    Button { text: "获取设备模式"; onClicked: udpManager.requestDeviceMode(remoteIpTf.text, parseInt(remotePortTf.text)) }
                    Button { text: "发送修改"; onClicked: logArea.appendText("当前UI不支持该修改") }
                    Label { text: "设备模式：不支持该修改"; color: "gray" }
                }
            }

            // 设置输入模式的目标IP
            GroupBox {
                title: "设置输入模式的目标IP"
                Layout.fillWidth: true
                GridLayout {
                    columns: 3
                    rowSpacing: 8
                    columnSpacing: 12

                    Label { text: "目标IP地址" }
                    TextField { id: targetIpTf; text: "192.168.1.150"; Layout.fillWidth: true }
                    Button { text: "获取目标IP"; onClicked: udpManager.sendData(remoteIpTf.text, parseInt(remotePortTf.text), "GET_TARGET_IP") }
                    Button { text: "发送修改"; onClicked: udpManager.sendSetTargetIp(remoteIpTf.text, parseInt(remotePortTf.text), targetIpTf.text) }
                }
            }

            // 日志显示
            GroupBox {
                title: "通信日志"
                Layout.fillWidth: true
                Layout.preferredHeight: 300
                ScrollView {
                    id: logScroll
                    width: parent.width
                    height: parent.height
                    TextArea {
                        id: logArea
                        readOnly: true
                        wrapMode: Text.Wrap
                        font.family: "Monospace"
                        function appendText(msg) {
                            let date = new Date()
                            let timeStr = date.toLocaleTimeString() + "." + date.getMilliseconds()
                            text += `[${timeStr}] ${msg}\n`
                            logScroll.ScrollBar.vertical.position = 1.0
                        }
                    }
                }
            }
        }
    }
}