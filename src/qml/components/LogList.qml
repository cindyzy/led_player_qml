import QtQuick 2.15
import QtQuick.Controls
import QtQuick.Layouts
import QtQml.Models

// 系统日志列表组件
Rectangle {
    id: logContainer
    anchors.fill: parent
    color: "#252526"

    property alias model: logListView.model
    property int currentPage: 0
    property int pageSize: 50
    property int totalCount: 0

    signal requestLogs(int offset, int limit)
    signal filterLogs(int userId, QString operationType, QDateTime startTime, QDateTime endTime)

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // 搜索和过滤栏
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 60
            color: "#1E1E1E"
            RowLayout {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 10

                // 用户ID过滤
                ColumnLayout {
                    spacing: 5
                    Text {
                        text: "用户ID:"
                        color: "#888888"
                        font.pixelSize: 12
                    }
                    TextField {
                        id: userIdField
                        Layout.preferredWidth: 80
                        placeholderText: "全部"
                        inputMethodHints: Qt.ImhDigitsOnly
                    }
                }

                // 操作类型过滤
                ColumnLayout {
                    spacing: 5
                    Text {
                        text: "操作类型:"
                        color: "#888888"
                        font.pixelSize: 12
                    }
                    ComboBox {
                        id: operationTypeCombo
                        Layout.preferredWidth: 120
                        model: ["全部", "登录", "创建用户", "更新用户", "删除用户", 
                                "创建角色", "更新角色", "删除角色", "创建项目", 
                                "更新项目", "删除项目", "创建设备", "更新设备", "删除设备"]
                        currentIndex: 0
                    }
                }

                // 时间范围过滤
                ColumnLayout {
                    spacing: 5
                    Text {
                        text: "开始时间:"
                        color: "#888888"
                        font.pixelSize: 12
                    }

                    DateTimeEdit {
                        id: startTimeEdit
                        Layout.preferredWidth: 150
                        displayFormat: "yyyy-MM-dd HH:mm"
                    }
                }

                ColumnLayout {
                    spacing: 5
                    Text {
                        text: "结束时间:"
                        color: "#888888"
                        font.pixelSize: 12
                    }
                    DateTimeEdit {
                        id: endTimeEdit
                        Layout.preferredWidth: 150
                        displayFormat: "yyyy-MM-dd HH:mm"
                        date: new Date()
                    }
                }

                // 搜索按钮
                Button {
                    text: "搜索"
                    Layout.alignment: Qt.AlignBottom
                    onClicked: {
                        var userId = userIdField.text ? parseInt(userIdField.text) : -1
                        var opType = operationTypeCombo.currentIndex === 0 ? "" : operationTypeCombo.currentText
                        filterLogs(userId, opType, startTimeEdit.dateTime, endTimeEdit.dateTime)
                    }
                }

                // 重置按钮
                Button {
                    text: "重置"
                    Layout.alignment: Qt.AlignBottom
                    onClicked: {
                        userIdField.text = ""
                        operationTypeCombo.currentIndex = 0
                        startTimeEdit.dateTime = new Date(0)
                        endTimeEdit.dateTime = new Date()
                        requestLogs(0, pageSize)
                    }
                }
            }
        }

        // 日志列表
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "#252526"

            ListView {
                id: logListView
                anchors.fill: parent
                anchors.margins: 10
                clip: true
                spacing: 5

                delegate: Rectangle {
                    width: parent.width
                    height: 80
                    color: "#2D2D2D"
                    radius: 4
                    border.color: "#3D3D3D"
                    border.width: 1

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 5

                        // 第一行：操作类型和结果
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 20

                            Text {
                                text: model.operationType
                                color: "#00D4AA"
                                font.pixelSize: 14
                                font.bold: true
                            }

                            Text {
                                text: model.operateResult
                                color: model.operateResult === "成功" ? "#00FF00" : "#FF6B6B"
                                font.pixelSize: 12
                                font.bold: true
                            }

                            Text {
                                text: model.operateTime
                                color: "#888888"
                                font.pixelSize: 12
                                Layout.alignment: Qt.AlignRight
                            }
                        }

                        // 第二行：操作描述
                        Text {
                            text: model.operationDesc
                            color: "#CCCCCC"
                            font.pixelSize: 13
                            Layout.fillWidth: true
                            wrapMode: Text.Wrap
                        }

                        // 第三行：用户ID、目标表、目标ID、IP
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 20

                            Text {
                                text: "用户ID: " + model.userId
                                color: "#888888"
                                font.pixelSize: 11
                            }

                            Text {
                                text: "目标表: " + (model.targetTable || "-")
                                color: "#888888"
                                font.pixelSize: 11
                            }

                            Text {
                                text: "目标ID: " + (model.targetId || "-")
                                color: "#888888"
                                font.pixelSize: 11
                            }

                            Text {
                                text: "IP: " + (model.clientIp || "-")
                                color: "#888888"
                                font.pixelSize: 11
                                Layout.alignment: Qt.AlignRight
                            }
                        }
                    }
                }

                header: Rectangle {
                    width: parent.width
                    height: 35
                    color: "#1E1E1E"
                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 20

                        Text {
                            text: "操作类型"
                            color: "#888888"
                            font.pixelSize: 12
                            font.bold: true
                            width: 100
                        }

                        Text {
                            text: "结果"
                            color: "#888888"
                            font.pixelSize: 12
                            font.bold: true
                            width: 60
                        }

                        Text {
                            text: "操作描述"
                            color: "#888888"
                            font.pixelSize: 12
                            font.bold: true
                            Layout.fillWidth: true
                        }

                        Text {
                            text: "时间"
                            color: "#888888"
                            font.pixelSize: 12
                            font.bold: true
                            width: 150
                            horizontalAlignment: Text.AlignRight
                        }
                    }
                }

                // 滚动到底部时加载更多
                onCountChanged: {
                    if (logListView.count > 0 && 
                        logListView.currentIndex === logListView.count - 1 && 
                        logListView.count < totalCount) {
                        currentPage++
                        requestLogs(currentPage * pageSize, pageSize)
                    }
                }
            }
        }

        // 分页信息栏
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 30
            color: "#1E1E1E"
            RowLayout {
                anchors.centerIn: parent
                spacing: 20

                Text {
                    text: "共 " + totalCount + " 条记录"
                    color: "#888888"
                    font.pixelSize: 12
                }

                Button {
                    text: "上一页"
                    enabled: currentPage > 0
                    onClicked: {
                        currentPage--
                        requestLogs(currentPage * pageSize, pageSize)
                    }
                }

                Text {
                    text: "第 " + (currentPage + 1) + " 页"
                    color: "#CCCCCC"
                    font.pixelSize: 12
                }

                Button {
                    text: "下一页"
                    enabled: (currentPage + 1) * pageSize < totalCount
                    onClicked: {
                        currentPage++
                        requestLogs(currentPage * pageSize, pageSize)
                    }
                }
            }
        }
    }
}