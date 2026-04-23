// PropertyField.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

RowLayout {
    id: propertyField
    property string label: ""
    property var value
    property string fieldType: "text"  // text, spin, combo, switch, label
    property var options: []
    property int from: 0
    property int to: 100
    property real stepSize: 1          // 新增：步进值
    property int decimals: 0           // 新增：小数位数

    Layout.fillWidth: true
    spacing: 8

    signal btnclicked()
    // 标签
    Text {
        text: label
        color: "#999999"
        Layout.preferredWidth: 100
    }

    // 字段
    Loader {
        Layout.fillWidth: true
        sourceComponent: {
            switch(fieldType) {
            case "text": return textFieldComponent
            case "spin": return spinFieldComponent
            case "combo": return comboFieldComponent
            case "switch": return switchFieldComponent
            case "label": return labelFieldComponent
            case "button": return buttonFieldComponent
            default: return textFieldComponent
            }
        }

        // 文本输入框
        Component {
            id: textFieldComponent
            TextField {
                text: propertyField.value
                placeholderText: "请输入"

                background: Rectangle {
                    color: "#333333"
                    border.color: "#555555"
                    border.width: 1
                    radius: 2
                }

                onTextChanged: propertyField.value = text
            }
        }

        // 数字输入框
        Component {
            id: spinFieldComponent
            SpinBox {
                value: propertyField.value
                from: propertyField.from
                to: propertyField.to
                stepSize: propertyField.stepSize
                // decimals: propertyField.decimals
                editable: propertyField.decimals > 0

                background: Rectangle {
                    color: "#333333"
                    border.color: "#555555"
                    border.width: 1
                    radius: 2
                }

                contentItem: TextInput {
                    text: decimals > 0 ? value.toFixed(decimals) : value.toString()
                    color: "#D4D4D4"
                    font.pixelSize: 12
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    readOnly: !editable
                }

                onValueChanged: propertyField.value = value
            }
        }

        // 下拉框
        Component {
            id: comboFieldComponent
            ComboBox {
                currentIndex: {
                    var index = propertyField.options.indexOf(propertyField.value)
                    return index >= 0 ? index : 0
                }
                model: propertyField.options

                background: Rectangle {
                    color: "#333333"
                    border.color: "#555555"
                    border.width: 1
                    radius: 2
                }

                contentItem: Text {
                    text: currentText
                    color: "#D4D4D4"
                    leftPadding: 8
                    verticalAlignment: Text.AlignVCenter
                }

                popup.background: Rectangle {
                    color: "#333333"
                    border.color: "#555555"
                }

                onCurrentTextChanged: propertyField.value = currentText
            }
        }

        // 开关
        Component {
            id: switchFieldComponent
            Switch {
                checked: propertyField.value

                indicator: Rectangle {
                    implicitWidth: 50
                    implicitHeight: 20
                    radius: 10
                    color: checked ? "#007ACC" : "#444444"
                    border.color: checked ? "#0066CC" : "#666666"

                    Rectangle {
                        x: checked ? parent.width - width - 2 : 2
                        y: 2
                        width: parent.height - 4
                        height: parent.height - 4
                        radius: 8
                        color: "#FFFFFF"
                        border.color: "#CCCCCC"

                        Behavior on x {
                            NumberAnimation { duration: 200 }
                        }
                    }
                }

                onCheckedChanged: propertyField.value = checked
            }
        }

        // 只读标签
        Component {
            id: labelFieldComponent
            Text {
                text: propertyField.decimals > 0 && typeof propertyField.value === "number"
                      ? propertyField.value.toFixed(propertyField.decimals)
                      : propertyField.value.toString()
                color: "#D4D4D4"
                verticalAlignment: Text.AlignVCenter
                height: parent.height
                font.pixelSize: 12
            }
        }
        Component {
            id: buttonFieldComponent
            Button {
                text: propertyField.decimals > 0 && typeof propertyField.value === "number"
                      ? propertyField.value.toFixed(propertyField.decimals)
                      : propertyField.value.toString()
                height: parent.height
                font.pixelSize: 12
                onClicked: btnclicked()
            }
        }


    }
}