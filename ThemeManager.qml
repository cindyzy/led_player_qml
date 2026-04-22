// ThemeManager.qml
pragma Singleton
import QtQuick
import QtQuick.Controls

QtObject {
    // 颜色定义
    readonly property color windowBackground: "#1E1E1E"
    readonly property color panelBackground: "#252526"
    readonly property color borderColor: "#3E3E3E"
    readonly property color textColor: "#D4D4D4"
    readonly property color textSecondary: "#999999"
    readonly property color accentColor: "#007ACC"
    readonly property color hoverColor: "#2A2D2E"
    readonly property color selectionColor: "#094771"

    // 字体
    readonly property font defaultFont: Qt.font({
        family: "Microsoft YaHei",
        pixelSize: 12
    })

    readonly property font titleFont: Qt.font({
        family: "Microsoft YaHei",
        pixelSize: 16,
        bold: true
    })

    // 按钮样式
    function buttonStyle(isFlat = false) {
        return `
            background: Rectangle {
                color: pressed ? ${accentColor} : ${isFlat ? "transparent" : "#333333"}
                border.color: "${borderColor}"
                border.width: ${isFlat ? 0 : 1}
                radius: 2
            }

            contentItem: Text {
                text: control.text
                color: "${textColor}"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        `
    }

    // 输入框样式
    function textFieldStyle() {
        return `
            background: Rectangle {
                color: "#333333"
                border.color: "${borderColor}"
                border.width: 1
                radius: 2
            }
        `
    }
}