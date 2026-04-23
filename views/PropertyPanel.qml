// PropertyPanel.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Material
import "../components"
Rectangle {
    id: propertyPanel
    color: "#252526"
    border.color: "#3E3E3E"
    border.width: 1

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 8
        spacing: 8

        // 标题
        Text {
            text: "属性设置"
            color: "#D4D4D4"
            font.bold: true
            font.pixelSize: 16
        }

        // 属性组
        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true

            ScrollBar.vertical.policy: ScrollBar.AlwaysOn

            ColumnLayout {
                width: parent.width
                spacing: 5
                // padding: 10

                // 项目属性
                PropertyGroup {
                    title: "项目属性"
                    expanded: true

                    ColumnLayout {
                        spacing: 8

                        // 项目名
                        PropertyField {
                            label: "项目名"
                            value: "新建项目1"
                            fieldType: "text"
                        }

                        // 项目宽度
                        PropertyField {
                            label: "项目宽度"
                            value: 192
                            fieldType: "spin"
                            from: 32
                            to: 8192
                        }

                        // 项目高度
                        PropertyField {
                            label: "项目高度"
                            value: 144
                            fieldType: "spin"
                            from: 32
                            to: 8192
                        }

                        // 播放列表数量
                        PropertyField {
                            label: "播放列表数量"
                            value: "1"
                            fieldType: "label"
                        }

                        // 播放帧速档位
                        PropertyField {
                            label: "播放帧速档位"
                            value: "05 (50ms, 20.0fps)"
                            fieldType: "combo"
                            options: [
                                "01 (1000ms, 1.0fps)",
                                "02 (500ms, 2.0fps)",
                                "03 (250ms, 4.0fps)",
                                "04 (100ms, 10.0fps)",
                                "05 (50ms, 20.0fps)",
                                "06 (40ms, 25.0fps)"
                            ]
                        }

                        // 布线遮罩
                        PropertyField {
                            label: "布线遮罩"
                            value: true
                            fieldType: "switch"
                        }

                        // 显示图像
                        PropertyField {
                            label: "显示图像"
                            value: true
                            fieldType: "switch"
                        }

                        // 循环方式
                        PropertyField {
                            label: "循环方式"
                            value: "整体循环"
                            fieldType: "combo"
                            options: ["整体循环", "单个循环"]
                        }

                        // 总时控
                        PropertyField {
                            label: "总时控"
                            value: "关闭"
                            fieldType: "combo"
                            options: ["关闭", "启动"]
                        }

                        // 视窗锁定
                        PropertyField {
                            label: "视窗锁定"
                            value: "关闭"
                            fieldType: "combo"
                            options: ["关闭", "启动"]
                        }
                    }
                }

                // 播放列表属性
                PropertyGroup {
                    id: playlistPropertiesGroup
                    title: "播放列表属性"
                    Layout.fillWidth: true

                    ColumnLayout {
                        width: parent.width
                        spacing: 5
                        PropertyField {
                            label: "播放列表名称"
                            value: "播放列表1"
                            fieldType: "text"
                        }
                        PropertyField {
                            label: "节目数量"
                            value: 1
                            fieldType: "spin"
                            from: 1
                            to: 9999
                        }
                        PropertyField {
                            label: "总帧数"
                            value: 80
                            fieldType: "spin"
                            from: 1
                            to: 9999
                        }

                        PropertyField {
                            label: "总时长(秒)"
                            value: 4
                            fieldType: "spin"
                            from: 1
                            to: 9999
                        }

                    }
                }

                // 节目属性
                PropertyGroup {
                    id: programPropertiesGroup
                    title: "节目属性"
                    Layout.fillWidth: true

                    ColumnLayout {
                        width: parent.width
                        spacing: 5
                        PropertyField {
                            label: "节目名称"
                            value: "节目1"
                            fieldType: "text"
                        }
                        PropertyField {
                            label: "启用"
                            value: "关闭"
                            fieldType: "combo"
                            options: ["关闭", "启动"]
                        }


                        // 帧数
                        PropertyField {
                            label: "帧数"
                            value: 80
                            fieldType: "spin"
                            from: 1
                            to: 9999
                        }

                        // 播放次数
                        PropertyField {
                            label: "播放次数"
                            value: 1
                            fieldType: "spin"
                            from: 1
                            to: 9999
                        }


                        // 播放时长(秒)
                        PropertyField {
                            label: "播放时长(秒)"
                            value: 4.00
                            fieldType: "spin"
                            from: 0
                            to: 9999
                            stepSize: 0.01
                            // decimals: 2
                        }

                        // 播放方式
                        PropertyField {
                            label: "播放方式"
                            value: "自动"
                            fieldType: "combo"
                            options: ["自动", "手动", "定时"]
                        }
                    }
                }

                // 节目渐入渐出设置
                PropertyGroup {
                    title: "节目渐入渐出设置"
                    // expanded: false
                    Layout.fillWidth: true
                    ColumnLayout {
                        spacing: 8

                        // 渐入
                        PropertyField {
                            label: "渐入"
                            value: false
                            fieldType: "switch"
                        }

                        // 渐出
                        PropertyField {
                            label: "渐出"
                            value: false
                            fieldType: "switch"
                        }

                        // 应用到勾选节目按钮
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 5

                            Item { Layout.fillWidth: true }

                            Button {
                                text: "应用到勾选节目"
                                Layout.preferredWidth: 120
                                Layout.preferredHeight: 25

                                background: Rectangle {
                                    color: parent.pressed ? "#666666" : "#333333"
                                    border.color: "#555555"
                                    border.width: 1
                                    radius: 3
                                }

                                contentItem: Text {
                                    text: parent.text
                                    color: "#CCCCCC"
                                    font.pixelSize: 11
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }

                                onClicked: {
                                    console.log("应用到勾选节目")
                                }
                            }
                        }
                    }
                }

                // 节目转场属性
                PropertyGroup {
                    title: "节目转场属性"
                    // expanded: false
                    Layout.fillWidth: true

                    ColumnLayout {
                        spacing: 8

                        // 转场启用
                        PropertyField {
                            label: "转场启用"
                            value: false
                            fieldType: "switch"
                        }

                        // 应用到勾选节目按钮
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 5

                            Item { Layout.fillWidth: true }

                            Button {
                                text: "应用到勾选节目"
                                Layout.preferredWidth: 120
                                Layout.preferredHeight: 25

                                background: Rectangle {
                                    color: parent.pressed ? "#666666" : "#333333"
                                    border.color: "#555555"
                                    border.width: 1
                                    radius: 3
                                }

                                contentItem: Text {
                                    text: parent.text
                                    color: "#CCCCCC"
                                    font.pixelSize: 11
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }

                                onClicked: {
                                    console.log("应用到勾选节目")
                                }
                            }
                        }
                    }
                }

                // 节目音控属性
                PropertyGroup {
                    title: "节目音控属性"
                    // expanded: false
                    Layout.fillWidth: true

                    ColumnLayout {
                        spacing: 8

                        // 音控启用
                        PropertyField {
                            label: "音控启用"
                            value: false
                            fieldType: "switch"
                        }

                        // 应用到勾选节目按钮
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 5

                            Item { Layout.fillWidth: true }

                            Button {
                                text: "应用到勾选节目"
                                Layout.preferredWidth: 120
                                Layout.preferredHeight: 25

                                background: Rectangle {
                                    color: parent.pressed ? "#666666" : "#333333"
                                    border.color: "#555555"
                                    border.width: 1
                                    radius: 3
                                }

                                contentItem: Text {
                                    text: parent.text
                                    color: "#CCCCCC"
                                    font.pixelSize: 11
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }

                                onClicked: {
                                    console.log("应用到勾选节目")
                                }
                            }
                        }
                    }
                }

                // 视窗属性
                PropertyGroup {
                    title: "视窗属性"
                    // expanded: false
                    Layout.fillWidth: true

                    ColumnLayout {
                        spacing: 8

                        // 视窗名称
                        PropertyField {
                            label: "视窗名称"
                            value: "视窗1"
                            fieldType: "text"
                        }

                        // 起点X坐标
                        PropertyField {
                            label: "起点X坐标"
                            value: 0
                            fieldType: "spin"
                            from: 0
                            to: 9999
                        }

                        // 起点Y坐标
                        PropertyField {
                            label: "起点Y坐标"
                            value: 0
                            fieldType: "spin"
                            from: 0
                            to: 9999
                        }

                        // 视窗宽度
                        PropertyField {
                            label: "视窗宽度"
                            value: 192
                            fieldType: "spin"
                            from: 1
                            to: 9999
                        }

                        // 视窗高度
                        PropertyField {
                            label: "视窗高度"
                            value: 144
                            fieldType: "spin"
                            from: 1
                            to: 9999
                        }

                        // 播放次数
                        PropertyField {
                            label: "播放次数"
                            value: 1
                            fieldType: "spin"
                            from: 1
                            to: 9999
                        }

                        // 锁定位置
                        PropertyField {
                            label: "锁定位置"
                            value: false
                            fieldType: "switch"
                        }

                        // 视窗颜色
                        PropertyField {
                            label: "视窗颜色"
                            value: "0,120,215"
                            fieldType: "text"
                        }

                        // 混合类型
                        PropertyField {
                            label: "混合类型"
                            value: "覆盖"
                            fieldType: "combo"
                            options: ["覆盖", "叠加", "透明"]
                        }
                    }
                }

                // 素材属性
                PropertyGroup {
                    title: "素材属性"
                    // expanded: false
                    Layout.fillWidth: true
                    ColumnLayout {
                        spacing: 8

                        // 素材名称
                        PropertyField {
                            label: "素材名称"
                            value: "炫彩文字1"
                            fieldType: "text"
                        }

                        // 帧数
                        PropertyField {
                            label: "帧数"
                            value: 80
                            fieldType: "spin"
                            from: 1
                            to: 9999
                        }

                        // 播放时长(秒)
                        PropertyField {
                            label: "播放时长(秒)"
                            value: 4.00
                            fieldType: "spin"
                            from: 0
                            to: 9999
                            stepSize: 0.01
                            decimals: 2
                        }

                        // 启用
                        PropertyField {
                            label: "启用"
                            value: true
                            fieldType: "switch"
                        }

                        // 总时控
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 5

                            Item { Layout.preferredWidth: 100 }

                            Text {
                                text: "总时控 0/0"
                                color: "#CCCCCC"
                                font.pixelSize: 12
                            }
                        }

                        // 时间码
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 5

                            Item { Layout.preferredWidth: 100 }

                            Text {
                                text: "00:00:00/0:00:00"
                                color: "#CCCCCC"
                                font.pixelSize: 12
                            }
                        }

                        // 布线遮罩提示
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 5

                            Item { Layout.preferredWidth: 100 }

                            Text {
                                text: "设置是否开启布线遮罩"
                                color: "#CCCCCC"
                                font.pixelSize: 12
                                font.italic: true
                            }
                        }
                    }
                }

            }
        }
    }
}