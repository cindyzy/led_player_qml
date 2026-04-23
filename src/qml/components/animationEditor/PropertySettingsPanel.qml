// LED属性设置面板优化版
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "../"

ScrollView {
    id: propertyPanel
    width: 320
    clip: true

    // 属性接口
    property var currentItemProperties: ({})
    property var animationParameters: ({})
    property var quickWiringConfig: ({})

    // 内部属性
    property int charWidthLeds: 8
    property int spacingCols: 1
    property int gridCellWidth: 10

    // 信号
    signal propertyChanged(string name, variant value)
    signal textChanged(string newText)
    signal generateLedData()
    signal exportEffect()
    signal canvasRepaintRequested()

    ColumnLayout {
        width: parent.width
        spacing: 12

        // 文本输入区域
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 45
            color: "#1e1e1e"
            radius: 6
            border.color: "#3a3a3a"
            border.width: 1

            TextField {
                id: animationText
                anchors.fill: parent
                anchors.margins: 8
                text: currentItemProperties.text || "LED文字效果"
                color: "#ffffff"
                placeholderText: "请输入文字内容..."
                placeholderTextColor: "#666666"
                font.pixelSize: 16
                selectByMouse: true
                background: Rectangle {
                    color: "transparent"
                }

                onTextChanged: {
                    propertyChanged("text", text)
                    textChanged(text)

                    // 重新计算文字容器宽度
                    var totalCols = text.length * charWidthLeds + (text.length - 1) * spacingCols;
                    var newWidth = totalCols * gridCellWidth;
                    console.log("文本容器新宽度:", newWidth);

                    // 请求重绘画布
                    canvasRepaintRequested();
                }
            }
        }

        // LED网格设置组
        PropertyGroup {
            title: "LED网格设置"
            expanded: true

            ColumnLayout {
                spacing: 8

                PropertyField {
                    label: "网格宽度"
                    value: quickWiringConfig.width || 16
                    fieldType: "spin"
                    from: 1
                    to: 64
                    // unit: "格"
                    onValueChanged: {
                        propertyChanged("gridWidth", value)
                        if (quickWiringConfig) quickWiringConfig.width = value
                        canvasRepaintRequested()
                    }
                }

                PropertyField {
                    label: "网格高度"
                    value: quickWiringConfig.height || 8
                    fieldType: "spin"
                    from: 1
                    to: 32
                    // unit: "格"
                    onValueChanged: {
                        propertyChanged("gridHeight", value)
                        if (quickWiringConfig) quickWiringConfig.height = value
                        canvasRepaintRequested()
                    }
                }

                PropertyField {
                    label: "LED大小"
                    value: currentItemProperties.ledSize || "70%"
                    fieldType: "combo"
                    options: ["50%", "60%", "70%", "80%", "90%"]
                    onValueChanged: propertyChanged("ledSize", value)
                }

                PropertyField {
                    label: "亮度"
                    value: currentItemProperties.brightness || "高"
                    fieldType: "combo"
                    options: ["低", "中", "高", "极高"]
                    onValueChanged: propertyChanged("brightness", value)
                }
            }
        }

        // 字体设置组
        PropertyGroup {
            title: "字体设置"
            expanded: true

            ColumnLayout {
                spacing: 8

                RowLayout {
                    Layout.fillWidth: true

                    PropertyField {
                        id: fontNameProperty
                        label: "字体名称"
                        value: currentItemProperties.fontName || "宋体"
                        fieldType: "combo"
                        options: ["宋体", "微软雅黑", "黑体", "楷体", "仿宋", "隶书"]
                        Layout.fillWidth: true
                        onValueChanged: {
                            propertyChanged("fontName", value)
                            canvasRepaintRequested()
                        }
                    }

                    Button {
                        text: "更多"
                        flat: true
                        Layout.preferredWidth: 60
                        Layout.preferredHeight: 30
                        onClicked: fontDialog.open()

                        background: Rectangle {
                            color: parent.pressed ? "#2a2a2a" : "transparent"
                            border.color: "#007ACC"
                            border.width: 1
                            radius: 4
                        }

                        contentItem: Text {
                            text: parent.text
                            color: "#007ACC"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            font.pixelSize: 12
                        }
                    }
                }

                PropertyField {
                    id: fontSizeProperty
                    label: "字体大小"
                    value: currentItemProperties.fontSize || 54
                    fieldType: "spin"
                    from: 1
                    to: 200
                    // unit: "px"
                    onValueChanged: {
                        propertyChanged("fontSize", value)
                        canvasRepaintRequested()
                    }
                }
            }
        }

        // 基本属性组
        PropertyGroup {
            title: "基本属性"
            expanded: true

            ColumnLayout {
                spacing: 8

                PropertyField {
                    label: "素材名称"
                    value: currentItemProperties.materialName || "LED文字效果"
                    fieldType: "text"
                    onValueChanged: propertyChanged("materialName", value)
                }

                // 位置和尺寸网格
                GridLayout {
                    columns: 2
                    columnSpacing: 12
                    rowSpacing: 8

                    PropertyField {
                        label: "起点X坐标"
                        value: currentItemProperties.startX || 0
                        fieldType: "spin"
                        from: 0
                        to: 9999
                        // unit: "px"
                        onValueChanged: propertyChanged("startX", value)
                    }

                    PropertyField {
                        label: "起点Y坐标"
                        value: currentItemProperties.startY || 0
                        fieldType: "spin"
                        from: 0
                        to: 9999
                        // unit: "px"
                        onValueChanged: propertyChanged("startY", value)
                    }

                    PropertyField {
                        label: "素材宽度"
                        value: currentItemProperties.materialWidth || 60
                        fieldType: "spin"
                        from: 1
                        to: 9999
                        // unit: "px"
                        onValueChanged: propertyChanged("materialWidth", value)
                    }

                    PropertyField {
                        label: "素材高度"
                        value: currentItemProperties.materialHeight || 270
                        fieldType: "spin"
                        from: 1
                        to: 9999
                        // unit: "px"
                        onValueChanged: propertyChanged("materialHeight", value)
                    }
                }
            }
        }

        // 帧设置组
        PropertyGroup {
            title: "帧设置"
            expanded: false

            ColumnLayout {
                spacing: 8

                PropertyField {
                    label: "帧数"
                    value: currentItemProperties.frameCount || 80
                    fieldType: "spin"
                    from: 1
                    to: 9999
                    // unit: "帧"
                    onValueChanged: propertyChanged("frameCount", value)
                }

                GridLayout {
                    columns: 2
                    columnSpacing: 12
                    rowSpacing: 8

                    PropertyField {
                        label: "素材起始帧"
                        value: currentItemProperties.startFrame || 1
                        fieldType: "spin"
                        from: 1
                        to: 9999
                        // unit: "帧"
                        onValueChanged: propertyChanged("startFrame", value)
                    }

                    PropertyField {
                        label: "素材结束帧"
                        value: currentItemProperties.endFrame || 80
                        fieldType: "spin"
                        from: 1
                        to: 9999
                        // unit: "帧"
                        onValueChanged: propertyChanged("endFrame", value)
                    }

                    PropertyField {
                        label: "入场帧"
                        value: currentItemProperties.enterFrame || 1
                        fieldType: "spin"
                        from: 1
                        to: 9999
                        // unit: "帧"
                        onValueChanged: propertyChanged("enterFrame", value)
                    }

                    PropertyField {
                        label: "出场帧"
                        value: currentItemProperties.exitFrame || 80
                        fieldType: "spin"
                        from: 1
                        to: 9999
                        // unit: "帧"
                        onValueChanged: propertyChanged("exitFrame", value)
                    }
                }

                PropertyField {
                    label: "重复次数"
                    value: currentItemProperties.repeatCount || 1
                    fieldType: "spin"
                    from: 1
                    to: 9999
                    // unit: "次"
                    onValueChanged: propertyChanged("repeatCount", value)
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    Label {
                        text: "总帧数: 410 帧"
                        color: "#CCCCCC"
                        font.pixelSize: 12
                        Layout.fillWidth: true
                    }

                    Button {
                        text: "追加"
                        flat: true
                        Layout.preferredWidth: 60
                        Layout.preferredHeight: 28

                        background: Rectangle {
                            color: parent.pressed ? "#333333" : "transparent"
                            border.color: "#555555"
                            border.width: 1
                            radius: 4
                        }

                        contentItem: Text {
                            text: parent.text
                            color: "#CCCCCC"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            font.pixelSize: 12
                        }
                    }
                }
            }
        }

        // 效果设置组
        PropertyGroup {
            title: "效果设置"
            expanded: false

            ColumnLayout {
                spacing: 8

                PropertyField {
                    label: "混合类型"
                    value: currentItemProperties.blendType || "黑色透明"
                    fieldType: "combo"
                    options: ["黑色透明", "正常", "叠加", "滤色", "正片叠底"]
                    onValueChanged: propertyChanged("blendType", value)
                }

                PropertyField {
                    label: "镜像方式"
                    value: currentItemProperties.mirrorMode || "复制"
                    fieldType: "combo"
                    options: ["复制", "镜像", "不镜像"]
                    onValueChanged: propertyChanged("mirrorMode", value)
                }

                PropertyField {
                    label: "横向分区数"
                    value: currentItemProperties.horizontalSections || 1
                    fieldType: "spin"
                    from: 1
                    to: 10
                    // unit: "区"
                    onValueChanged: propertyChanged("horizontalSections", value)
                }
            }
        }

        // 操作按钮组
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 8

            Button {
                id: generateButton
                text: "生成LED数据"
                Layout.fillWidth: true
                Layout.preferredHeight: 36
                onClicked: {
                    console.log("开始生成LED数据...")
                    generateLedData()
                }

                background: Rectangle {
                    color: parent.pressed ? "#2c5282" : "#2b6cb0"
                    radius: 6
                }

                contentItem: Text {
                    text: parent.text
                    color: "white"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.bold: true
                    font.pixelSize: 14
                }
            }

            Button {
                id: exportButton
                text: "导出效果"
                Layout.fillWidth: true
                Layout.preferredHeight: 36
                onClicked: {
                    console.log("导出效果...")
                    exportEffect()
                }

                background: Rectangle {
                    color: parent.pressed ? "#2d3748" : "#4a5568"
                    border.color: "#555555"
                    border.width: 1
                    radius: 6
                }

                contentItem: Text {
                    text: parent.text
                    color: "white"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: 14
                }
            }
        }
    }

    // 字体选择对话框
    Dialog {
        id: fontDialog
        title: "选择字体"
        modal: true
        standardButtons: Dialog.Ok | Dialog.Cancel
        width: 400
        height: 300

        onAccepted: {
            console.log("字体选择确认")
        }

        onRejected: {
            console.log("字体选择取消")
        }
    }
}
