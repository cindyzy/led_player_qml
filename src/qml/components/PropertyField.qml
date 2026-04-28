// PropertyField.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import ".."
RowLayout {
    id: propertyField

    // 基本属性
    property string label: ""
    property var value
    property string fieldType: "text"  // text, spin, combo, switch, label, button
    property var options: []
    property int from: 0
    property int to: 100
    property real stepSize: 1
    property int decimals: 0

    Layout.fillWidth: true
    spacing: 8

    signal btnclicked()

    // 监听皮肤变化
    Connections {
        target: SkinManager
        onSkinChanged: {
            propertyField.updateTheme()
        }
    }

    // 标签
    Text {
        id: labelText
        text: label
        color: SkinManager.currentSkin ? SkinManager.currentSkin.colors.textSecondary : "#999999"
        Layout.preferredWidth: 100
        font: SkinManager.currentSkin ? SkinManager.currentSkin.fonts.normal : Qt.font({ pixelSize: 12 })

        // 标签颜色动画
        Behavior on color {
            ColorAnimation {
                duration: 300
                easing.type: Easing.InOutQuad
            }
        }
    }

    // 字段
    Loader {
        id: fieldLoader
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
    }

    // 更新主题
    function updateTheme() {
        // 标签颜色更新
        if (labelText) {
            labelText.color = SkinManager.currentSkin ? SkinManager.currentSkin.colors.textSecondary : "#999999"
            labelText.font = SkinManager.currentSkin ? SkinManager.currentSkin.fonts.normal : Qt.font({ pixelSize: 12 })
        }
    }

    // 文本输入框
    Component {
        id: textFieldComponent

        TextField {
            id: textField
            text: propertyField.value
            placeholderText: "请输入"
            font: SkinManager.currentSkin ? SkinManager.currentSkin.fonts.normal : Qt.font({ pixelSize: 12 })
            color: SkinManager.currentSkin ? SkinManager.currentSkin.colors.text : "#D4D4D4"

            background: Rectangle {
                id: textFieldBg
                color: SkinManager.currentSkin ? SkinManager.currentSkin.colors.background : "#333333"
                border.color: textField.activeFocus ? (SkinManager.currentSkin ? SkinManager.currentSkin.colors.primary : "#007ACC") : (SkinManager.currentSkin ? SkinManager.currentSkin.colors.border : "#555555")
                border.width: 1
                radius: SkinManager.currentSkin && SkinManager.currentSkin.sizes ? SkinManager.currentSkin.sizes.radius : 2

                // 文本颜色动画
                Behavior on color {
                    ColorAnimation {
                        duration: 300
                        easing.type: Easing.InOutQuad
                    }
                }

                // 边框颜色动画
                Behavior on border.color {
                    ColorAnimation {
                        duration: 300
                        easing.type: Easing.InOutQuad
                    }
                }
            }

            // 文本颜色动画
            Behavior on color {
                ColorAnimation {
                    duration: 300
                    easing.type: Easing.InOutQuad
                }
            }

            onTextChanged: propertyField.value = text
        }
    }

    // 数字输入框
    Component {
        id: spinFieldComponent

        SpinBox {
            id: spinBox
            value: propertyField.value
            from: propertyField.from
            to: propertyField.to
            stepSize: propertyField.stepSize
            editable: propertyField.decimals > 0

            background: Rectangle {
                id: spinBoxBg
                color: SkinManager.currentSkin ? SkinManager.currentSkin.colors.background : "#333333"
                border.color: spinBox.activeFocus ? (SkinManager.currentSkin ? SkinManager.currentSkin.colors.primary : "#007ACC") : (SkinManager.currentSkin ? SkinManager.currentSkin.colors.border : "#555555")
                border.width: 1
                radius: SkinManager.currentSkin && SkinManager.currentSkin.sizes ? SkinManager.currentSkin.sizes.radius : 2

                // 背景颜色动画
                Behavior on color {
                    ColorAnimation {
                        duration: 300
                        easing.type: Easing.InOutQuad
                    }
                }

                // 边框颜色动画
                Behavior on border.color {
                    ColorAnimation {
                        duration: 300
                        easing.type: Easing.InOutQuad
                    }
                }
            }

            contentItem: TextInput {
                text: propertyField.decimals > 0 ? value.toFixed(propertyField.decimals) : value.toString()
                color: SkinManager.currentSkin ? SkinManager.currentSkin.colors.text : "#D4D4D4"
                font: SkinManager.currentSkin ? SkinManager.currentSkin.fonts.normal : Qt.font({ pixelSize: 12 })
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                readOnly: !editable
                selectionColor: SkinManager.currentSkin ? SkinManager.currentSkin.colors.primary : "#007ACC"
                selectedTextColor: "white"

                // 文本颜色动画
                Behavior on color {
                    ColorAnimation {
                        duration: 300
                        easing.type: Easing.InOutQuad
                    }
                }
            }

            up.indicator: Rectangle {
                x: parent.width - width
                implicitWidth: 20
                implicitHeight: parent.height / 2
                color: SkinManager.currentSkin ? SkinManager.currentSkin.colors.backgroundSecondary : "#444444"
                radius: SkinManager.currentSkin && SkinManager.currentSkin.sizes ? SkinManager.currentSkin.sizes.radius : 2
                border.color: SkinManager.currentSkin ? SkinManager.currentSkin.colors.border : "#555555"

                Text {
                    text: "+"
                    color: SkinManager.currentSkin ? SkinManager.currentSkin.colors.text : "#D4D4D4"
                    font.pixelSize: 10
                    anchors.centerIn: parent
                }
            }

            down.indicator: Rectangle {
                x: parent.width - width
                y: parent.height / 2
                implicitWidth: 20
                implicitHeight: parent.height / 2
                color: SkinManager.currentSkin ? SkinManager.currentSkin.colors.backgroundSecondary : "#444444"
                radius: SkinManager.currentSkin && SkinManager.currentSkin.sizes ? SkinManager.currentSkin.sizes.radius : 2
                border.color: SkinManager.currentSkin ? SkinManager.currentSkin.colors.border : "#555555"

                Text {
                    text: "-"
                    color: SkinManager.currentSkin ? SkinManager.currentSkin.colors.text : "#D4D4D4"
                    font.pixelSize: 10
                    anchors.centerIn: parent
                }
            }

            onValueChanged: propertyField.value = value
        }
    }

    // 下拉框
    Component {
        id: comboFieldComponent

        ComboBox {
            id: comboBox
            currentIndex: {
                var index = propertyField.options.indexOf(propertyField.value)
                return index >= 0 ? index : 0
            }
            model: propertyField.options
            font: SkinManager.currentSkin ? SkinManager.currentSkin.fonts.normal : Qt.font({ pixelSize: 12 })

            background: Rectangle {
                id: comboBoxBg
                color: SkinManager.currentSkin ? SkinManager.currentSkin.colors.background : "#333333"
                border.color: comboBox.hovered ? (SkinManager.currentSkin ? SkinManager.currentSkin.colors.primary : "#007ACC") : (SkinManager.currentSkin ? SkinManager.currentSkin.colors.border : "#555555")
                border.width: 1
                radius: SkinManager.currentSkin && SkinManager.currentSkin.sizes ? SkinManager.currentSkin.sizes.radius : 2

                // 背景颜色动画
                Behavior on color {
                    ColorAnimation {
                        duration: 300
                        easing.type: Easing.InOutQuad
                    }
                }

                // 边框颜色动画
                Behavior on border.color {
                    ColorAnimation {
                        duration: 300
                        easing.type: Easing.InOutQuad
                    }
                }
            }

            contentItem: Text {
                id: comboBoxText
                text: comboBox.displayText
                color: SkinManager.currentSkin ? SkinManager.currentSkin.colors.text : "#D4D4D4"
                font: comboBox.font
                leftPadding: 8
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight

                // 文本颜色动画
                Behavior on color {
                    ColorAnimation {
                        duration: 300
                        easing.type: Easing.InOutQuad
                    }
                }
            }

            indicator: Canvas {
                x: comboBox.width - width - 5
                y: comboBox.topPadding + (comboBox.availableHeight - height) / 2
                width: 10
                height: 5
                contextType: "2d"

                onPaint: {
                    context.reset();
                    context.moveTo(0, 0);
                    context.lineTo(width, 0);
                    context.lineTo(width / 2, height);
                    context.closePath();
                    context.fillStyle = comboBoxText.color;
                    context.fill();
                }
            }

            popup: Popup {
                y: comboBox.height
                width: comboBox.width
                implicitHeight: contentItem.implicitHeight
                padding: 1

                background: Rectangle {
                    color: SkinManager.currentSkin ? SkinManager.currentSkin.colors.background : "#333333"
                    border.color: SkinManager.currentSkin ? SkinManager.currentSkin.colors.border : "#555555"
                    border.width: 1
                    radius: SkinManager.currentSkin && SkinManager.currentSkin.sizes ? SkinManager.currentSkin.sizes.radius : 2
                }

                contentItem: ListView {
                    clip: true
                    implicitHeight: contentHeight
                    model: comboBox.popup.visible ? comboBox.delegateModel : null
                    currentIndex: comboBox.highlightedIndex

                    ScrollIndicator.vertical: ScrollIndicator {
                        active: true
                        contentItem: Rectangle {
                            implicitWidth: 6
                            radius: 3
                            color: SkinManager.currentSkin ? SkinManager.currentSkin.colors.primary : "#007ACC"
                        }
                    }
                }
            }

            delegate: ItemDelegate {
                width: comboBox.width
                text: modelData
                font: comboBox.font
                highlighted: comboBox.highlightedIndex === index

                contentItem: Text {
                    text: modelData
                    color: highlighted ? "white" : (SkinManager.currentSkin ? SkinManager.currentSkin.colors.text : "#D4D4D4")
                    font: parent.font
                    elide: Text.ElideRight
                    verticalAlignment: Text.AlignVCenter
                    leftPadding: 8
                }

                background: Rectangle {
                    color: highlighted ? (SkinManager.currentSkin ? SkinManager.currentSkin.colors.primary : "#007ACC") : "transparent"
                }
            }

            onCurrentTextChanged: propertyField.value = currentText
        }
    }

    // 开关
    Component {
        id: switchFieldComponent

        Switch {
            id: switchControl
            checked: propertyField.value

            indicator: Rectangle {
                implicitWidth: 50
                implicitHeight: 20
                radius: SkinManager.currentSkin && SkinManager.currentSkin.sizes ? SkinManager.currentSkin.sizes.switchRadius : 10
                color: switchControl.checked ? (SkinManager.currentSkin ? SkinManager.currentSkin.colors.primary : "#007ACC") : (SkinManager.currentSkin ? SkinManager.currentSkin.colors.switchTrack : "#444444")
                border.color: switchControl.checked ? (SkinManager.currentSkin ? SkinManager.currentSkin.colors.primaryDark : "#0066CC") : (SkinManager.currentSkin ? SkinManager.currentSkin.colors.borderLight : "#666666")

                // 背景颜色动画
                Behavior on color {
                    ColorAnimation {
                        duration: 300
                        easing.type: Easing.InOutQuad
                    }
                }

                // 边框颜色动画
                Behavior on border.color {
                    ColorAnimation {
                        duration: 300
                        easing.type: Easing.InOutQuad
                    }
                }

                Rectangle {
                    id: thumb
                    x: switchControl.checked ? parent.width - width - 2 : 2
                    y: 2
                    width: parent.height - 4
                    height: parent.height - 4
                    radius: SkinManager.currentSkin && SkinManager.currentSkin.sizes ? SkinManager.currentSkin.sizes.switchThumbRadius : 8
                    color: SkinManager.currentSkin ? SkinManager.currentSkin.colors.switchThumb : "#FFFFFF"
                    border.color: SkinManager.currentSkin ? SkinManager.currentSkin.colors.switchThumbBorder : "#CCCCCC"
                    border.width: 1

                    Behavior on x {
                        enabled: true
                        NumberAnimation {
                            duration: 200
                            easing.type: Easing.OutBack
                        }
                    }
                }
            }

            onCheckedChanged: {
                propertyField.value = checked
            }
        }
    }

    // 只读标签
    Component {
        id: labelFieldComponent

        Text {
            id: labelField
            text: {
                if (propertyField.decimals > 0 && typeof propertyField.value === "number") {
                    return propertyField.value.toFixed(propertyField.decimals)
                } else if (propertyField.value !== undefined && propertyField.value !== null) {
                    return propertyField.value.toString()
                } else {
                    return ""
                }
            }
            color: SkinManager.currentSkin ? SkinManager.currentSkin.colors.text : "#D4D4D4"
            verticalAlignment: Text.AlignVCenter
            height: parent.height
            font: SkinManager.currentSkin ? SkinManager.currentSkin.fonts.normal : Qt.font({ pixelSize: 12 })

            // 文本颜色动画
            Behavior on color {
                ColorAnimation {
                    duration: 300
                    easing.type: Easing.InOutQuad
                }
            }
        }
    }

    // 按钮
    Component {
        id: buttonFieldComponent

        Button {
            id: actionButton
            text: {
                if (propertyField.decimals > 0 && typeof propertyField.value === "number") {
                    return propertyField.value.toFixed(propertyField.decimals)
                } else if (propertyField.value !== undefined && propertyField.value !== null) {
                    return propertyField.value.toString()
                } else {
                    return "点击"
                }
            }
            height: parent.height
            font: SkinManager.currentSkin ? SkinManager.currentSkin.fonts.normal : Qt.font({ pixelSize: 12 })

            background: Rectangle {
                id: buttonBg
                color: actionButton.hovered ?
                    (SkinManager.currentSkin ? Qt.lighter(SkinManager.currentSkin.colors.primary, 1.1) : Qt.lighter("#007ACC", 1.1)) :
                    (SkinManager.currentSkin ? SkinManager.currentSkin.colors.primary : "#007ACC")
                border.color: actionButton.hovered ?
                    (SkinManager.currentSkin ? Qt.lighter(SkinManager.currentSkin.colors.primary, 1.2) : Qt.lighter("#007ACC", 1.2)) :
                    (SkinManager.currentSkin ? Qt.darker(SkinManager.currentSkin.colors.primary, 1.2) : Qt.darker("#007ACC", 1.2))
                border.width: 1
                radius: SkinManager.currentSkin && SkinManager.currentSkin.sizes ? SkinManager.currentSkin.sizes.radius : 2

                // 背景颜色动画
                Behavior on color {
                    ColorAnimation {
                        duration: 200
                        easing.type: Easing.InOutQuad
                    }
                }

                // 边框颜色动画
                Behavior on border.color {
                    ColorAnimation {
                        duration: 200
                        easing.type: Easing.InOutQuad
                    }
                }

                // 按下效果
                Rectangle {
                    anchors.fill: parent
                    radius: parent.radius
                    color: "white"
                    opacity: actionButton.pressed ? 0.2 : 0

                    Behavior on opacity {
                        NumberAnimation { duration: 100 }
                    }
                }
            }

            contentItem: Text {
                text: actionButton.text
                color: "white"
                font: actionButton.font
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
            }

            onClicked: btnclicked()
        }
    }
}
