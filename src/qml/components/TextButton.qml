// TextButton.qml - 文本按钮组件，使用ThemeManager样式
import QtQuick
import QtQuick.Controls
import "ThemeManager.qml" as Theme

Button {
    id: textButton
    
    // 自定义属性
    property bool useSecondaryColor: false
    property int buttonFontSize: Theme.ThemeManager.fontSizeNormal
    
    // 背景样式
    background: Rectangle {
        color: {
            if (useSecondaryColor) {
                return textButton.hovered ? Qt.darker(Theme.ThemeManager.secondaryColor, 1.1) : Theme.ThemeManager.secondaryColor
            } else {
                return textButton.hovered ? Qt.darker(Theme.ThemeManager.primaryColor, 1.1) : Theme.ThemeManager.primaryColor
            }
        }
        border.color: {
            if (useSecondaryColor) {
                return Qt.darker(Theme.ThemeManager.secondaryColor, 1.2)
            } else {
                return Qt.darker(Theme.ThemeManager.primaryColor, 1.2)
            }
        }
        border.width: 1
        radius: Theme.ThemeManager.borderRadius
    }
    
    // 文本样式
    contentItem: Text {
        text: textButton.text
        color: "white"
        font.pixelSize: buttonFontSize
        font.weight: Font.Medium
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }
    
    // 内边距
    padding: Theme.ThemeManager.paddingNormal
    
    // 禁用状态
    onEnabledChanged: {
        if (!enabled) {
            background.color = Theme.ThemeManager.textDisabledColor
            background.border.color = Theme.ThemeManager.textDisabledColor
            contentItem.color = Theme.ThemeManager.textDisabledColor
        }
    }
}