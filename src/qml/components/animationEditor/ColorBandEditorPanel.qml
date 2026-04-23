// 色带编辑面板优化版
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "../"
Rectangle {
    id: colorBandPanel
    implicitHeight: 350
    color: "#2a2a2a"
    border.color: "#333333"
    border.width: 1
    radius: 4

    // 属性接口
    property var gradients: []
    property int currentGradientIndex: -1
    property var selectedColorStop: null
    property bool useGradient: true
    property color textColor: "#FF0000"
    property bool previewPlaying: false
    property var externalTemplates: ["模板1", "模板2", "模板3"]
    property string selectedTemplate: "模板1"
    property var gradientStops: [
        {color: "#FF0000", position: 0.0},
        {color: "#FFFF00", position: 0.5},
        {color: "#00FF00", position: 1.0}
    ]
    // 内置色带预设
    property var presetGradients: [
        {
            "name": "红黄绿渐变",
            "stops": [
                {color: "#FF0000", position: 0.0},
                {color: "#FFFF00", position: 0.5},
                {color: "#00FF00", position: 1.0}
            ]
        },
        {
            "name": "蓝青白渐变",
            "stops": [
                {color: "#0000FF", position: 0.0},
                {color: "#00FFFF", position: 0.5},
                {color: "#FFFFFF", position: 1.0}
            ]
        },
        {
            "name": "洋红黄青渐变",
            "stops": [
                {color: "#FF00FF", position: 0.0},
                {color: "#FFFF00", position: 0.5},
                {color: "#00FFFF", position: 1.0}
            ]
        },
        {
            "name": "红白渐变",
            "stops": [
                {color: "#FF0000", position: 0.0},
                {color: "#FFFFFF", position: 1.0}
            ]
        },
        {
            "name": "黑绿蓝渐变",
            "stops": [
                {color: "#000000", position: 0.0},
                {color: "#00FF00", position: 0.5},
                {color: "#0000FF", position: 1.0}
            ]
        }
    ]

    property var presetColors: [
        "#FF0000", "#FF9900", "#FFFF00", "#00FF00", "#0000FF",
        "#9900FF", "#FF0099", "#00FFFF", "#FF6600", "#66FF00"
    ]

    // 信号
    signal gradientSelected(int index, var gradient)
    signal colorSelected(color color)
    signal templateChanged(string templateName)
    signal canvasRepaintRequested()
    // signal gradientStopsChanged(var stops)
    signal gradientApplied(var gradient)

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 10

        // 内置色带区域
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 5

            Label {
                text: "内置色带"
                color: "#CCCCCC"
                font.pixelSize: 12
                font.bold: true
            }

            // 内置色带预设
            ScrollView {
                id: presetGradientScroll
                Layout.fillWidth: true
                Layout.preferredHeight: 60
                clip: true

                Row {
                    spacing: 5

                    Repeater {
                        model: presetGradients

                        GradientSwatch {
                            width: 50
                            height: 50
                            gradientSwatchStops: modelData.stops
                            // tooltip: modelData.name

                            onSwatchClicked: {
                                console.log("应用内置渐变:", modelData.name);
                                useGradient = true;
                                gradientStops = modelData.stops;
                                gradientApplied(modelData.stops);
                                canvasRepaintRequested();
                            }
                        }
                    }
                }
            }
        }

        // 单色色带区域
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 5

            Label {
                text: "单色色带"
                color: "#CCCCCC"
                font.pixelSize: 12
                font.bold: true
            }

            // 单色预设
            ScrollView {
                id: presetColorScroll
                Layout.fillWidth: true
                Layout.preferredHeight: 50
                clip: true

                Row {
                    spacing: 5

                    Repeater {
                        model: presetColors

                        ColorSwatch {
                            width: 40
                            height: 40
                            swatchColor: modelData
                            // tooltip: modelData

                            onSwatchClicked: {
                                console.log("应用单色:", modelData);
                                useGradient = false;
                                textColor = modelData;
                                colorSelected(modelData);
                                canvasRepaintRequested();
                            }
                        }
                    }
                }
            }
        }

        // 外置模板区域
        PropertyField {
            id: templateField
            label: "外置模板"
            value: selectedTemplate
            fieldType: "combo"
            options: externalTemplates
            Layout.fillWidth: true

            onValueChanged: {
                selectedTemplate = value;
                console.log("选择模板:", value);
                templateChanged(value);
            }
        }

        // 当前色带预览区域
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 5

            Label {
                text: "当前色带"
                color: "#CCCCCC"
                font.pixelSize: 12
                font.bold: true
            }

            Rectangle {
                id: currentColorPreview
                Layout.fillWidth: true
                Layout.preferredHeight: 40
                color: useGradient ? "transparent" : textColor
                border.color: "#444444"
                border.width: 1
                radius: 4

                // 渐变预览
                // LinearGradient {
                //     anchors.fill: parent
                //     anchors.margins: 2
                //     visible: useGradient
                //     start: Qt.point(0, 0)
                //     end: Qt.point(parent.width, 0)
                //     gradient: Gradient {
                //         stops: useGradient && gradientStops ? gradientStops : []
                //     }
                // }

                // 色标显示
                Row {
                    anchors.fill: parent
                    anchors.margins: 2
                    spacing: 0
                    visible: useGradient && gradientStops

                    Repeater {
                        model: useGradient && gradientStops ? gradientStops : []

                        Rectangle {
                            width: parent.width / (gradientStops ? gradientStops.length : 1)
                            height: parent.height
                            color: modelData.color
                        }
                    }
                }
            }
        }

        // 预览控制区域
        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            // 色带控制按钮
            RowLayout {
                spacing: 5

                Button {
                    text: "+"
                    // tooltip: "添加新色带"
                    onClicked: {
                        console.log("添加新色带");
                        var newGradient = {
                            "stops": [
                                {color: "#FF0000", position: 0.0},
                                {color: "#00FF00", position: 0.5},
                                {color: "#0000FF", position: 1.0}
                            ]
                        };
                        if (!gradients) gradients = [];
                        gradients.push(newGradient);
                        currentGradientIndex = gradients.length - 1;
                    }

                    background: Rectangle {
                        color: parent.pressed ? "#666666" : "#333333"
                        border.color: "#555555"
                        border.width: 1
                        radius: 3
                    }

                    contentItem: Text {
                        text: parent.text
                        color: "#CCCCCC"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }

                Button {
                    text: "✎"
                    // tooltip: "编辑当前色带"
                    enabled: useGradient && gradientStops
                    onClicked: {
                        console.log("编辑色带");
                        // 打开色带编辑器
                        gradientEditorDialog.open();
                    }

                    background: Rectangle {
                        color: parent.pressed ? "#666666" : "#333333"
                        border.color: "#555555"
                        border.width: 1
                        radius: 3
                    }

                    contentItem: Text {
                        text: parent.text
                        color: "#CCCCCC"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }

                Button {
                    text: "×"
                    // tooltip: "删除当前色带"
                    enabled: useGradient && gradientStops
                    onClicked: {
                        console.log("删除色带");
                        gradientStops = null;
                        useGradient = false;
                        gradientStopsChanged(null);
                    }

                    background: Rectangle {
                        color: parent.pressed ? "#666666" : "#333333"
                        border.color: "#555555"
                        border.width: 1
                        radius: 3
                    }

                    contentItem: Text {
                        text: parent.text
                        color: "#CCCCCC"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }
            }

            Item { Layout.fillWidth: true }

            }
    }

    // 色带编辑器对话框
    Dialog {
        id: gradientEditorDialog
        title: "编辑色带"
        modal: true
        standardButtons: Dialog.Save | Dialog.Cancel
        width: 500
        height: 300

        onAccepted: {
            console.log("保存色带编辑");
        }

        onRejected: {
            console.log("取消色带编辑");
        }
    }

}
