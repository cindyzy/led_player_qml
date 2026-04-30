import QtQuick 2.15
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: sidebar
    width: 60
    color: "#1E1E1E"

    property int currentIndex: 0

    signal menuItemClicked(int index, string title)

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // 顶部 Logo 区域
        // Rectangle {
        //     Layout.fillWidth: true
        //     Layout.preferredHeight: 60
        //     color: "#0D0D0D"
        //     ColumnLayout {
        //         anchors.centerIn: parent
        //         spacing: 8
        //         Image {
        //             width: 32
        //             height: 32
        //             source: "qrc:/images/led_logo.png"
        //             fillMode: Image.PreserveAspectFit
        //         }
        //         Text {
        //             text: "LED Player"
        //             color: "#FFFFFF"
        //             font.bold: true
        //             font.pixelSize: 16
        //         }
        //     }
        // }

        // 导航菜单项
        Column {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 0
            anchors.topMargin: 20

            Repeater {
                model: [
                    { icon: "📁", title: "项目", desc: "项目管理" },
                    { icon: "⚙", title: "硬件配置", desc: "硬件设置" },
                    { icon: "🔗", title: "布线", desc: "布线适配" },
                    { icon: "📋", title: "播放列表", desc: "节目管理" },
                    { icon: "📁", title: "素材编辑", desc: "素材资源管理" },
                    { icon: "📡", title: "监控", desc: "设备状态监控" },
                    { icon: "�", title: "权限", desc: "账号角色权限管理" },
                    { icon: "�", title: "系统日志", desc: "系统审计日志" },
                    { icon: "🤖", title: "AI素材", desc: "AI素材编辑" },
                    { icon: "⚡", title: "算法调度", desc: "智能调度算法" }
                ]

                delegate: Item {
                    id: menuItem
                    width: sidebar.width
                    height: 70
                    property int itemIndex: index

                    Rectangle {
                        anchors.fill: parent
                        color: sidebar.currentIndex === itemIndex ? "#2D2D2D" : "transparent"
                        border.color: sidebar.currentIndex === itemIndex ? "#00D4AA" : "transparent"
                        border.width: sidebar.currentIndex === itemIndex ? 2 : 0
                        // border.left: true
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            sidebar.currentIndex = itemIndex
                            sidebar.menuItemClicked(itemIndex, modelData.title)
                        }

                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: 12
                            anchors.leftMargin: 20

                            Text {
                                text: modelData.icon
                                font.pixelSize: 20
                                verticalAlignment: Text.AlignVCenter
                            }

                            Column {
                                spacing: 2
                                Text {
                                    text: modelData.title
                                    color: sidebar.currentIndex === itemIndex ? "#00D4AA" : "#CCCCCC"
                                    font.pixelSize: 12
                                }
                                // Text {
                                //     text: modelData.desc
                                //     color: "#666666"
                                //     font.pixelSize: 10
                                // }
                            }
                        }
                    }
                }
            }
        }

        // 底部区域
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 60
            color: "#0D0D0D"
            RowLayout {
                anchors.centerIn: parent
                spacing: 10
                Image {
                    width: 24
                    height: 24
                    source: "qrc:/images/user_icon.png"
                    fillMode: Image.PreserveAspectFit
                }
                Column {
                    Text {
                        text: "管理员"
                        color: "#FFFFFF"
                        font.pixelSize: 12
                    }
                    Text {
                        text: "在线"
                        color: "#00D4AA"
                        font.pixelSize: 10
                    }
                }
            }
        }
    }
}