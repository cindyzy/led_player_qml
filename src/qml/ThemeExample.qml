// ThemeExample.qml - 主题使用示例
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "components/TextButton.qml"
import "ThemeManager.qml" as Theme

Rectangle {
    width: 800
    height: 600
    color: Theme.ThemeManager.backgroundColor
    
    ColumnLayout {
        anchors.centerIn: parent
        spacing: 20
        
        // 标题
        Label {
            text: "Theme Manager 示例"
            color: Theme.ThemeManager.textColor
            font.pixelSize: Theme.ThemeManager.fontSizeLarge
            font.weight: Font.Bold
        }
        
        // 主按钮
        TextButton {
            text: "主按钮"
            onClicked: console.log("主按钮被点击")
        }
        
        // 绿色按钮（同步按钮）
        TextButton {
            text: "同步到设备"
            useSecondaryColor: true
            onClicked: console.log("同步按钮被点击")
        }
        
        // 禁用按钮
        TextButton {
            text: "禁用按钮"
            enabled: false
        }
        
        // 文本输入框
        TextField {
            width: 300
            placeholderText: "输入文本..."
            background: Rectangle {
                color: Theme.ThemeManager.surfaceColor
                border.color: Theme.ThemeManager.borderColor
                border.width: 1
                radius: Theme.ThemeManager.borderRadius
            }
            contentItem: TextInput {
                color: Theme.ThemeManager.textColor
                font.pixelSize: Theme.ThemeManager.fontSizeNormal
                padding: Theme.ThemeManager.paddingNormal
            }
        }
        
        // 下拉菜单
        ComboBox {
            width: 300
            model: ["选项1", "选项2", "选项3"]
            background: Rectangle {
                color: Theme.ThemeManager.surfaceColor
                border.color: Theme.ThemeManager.borderColor
                border.width: 1
                radius: Theme.ThemeManager.borderRadius
            }
            contentItem: Text {
                color: Theme.ThemeManager.textColor
                font.pixelSize: Theme.ThemeManager.fontSizeNormal
                padding: Theme.ThemeManager.paddingNormal
            }
            indicator: Rectangle {
                color: Theme.ThemeManager.textSecondaryColor
                width: 20
                height: 20
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                Text {
                    text: "▼"
                    color: Theme.ThemeManager.textColor
                    font.pixelSize: Theme.ThemeManager.fontSizeSmall
                    anchors.centerIn: parent
                }
            }
        }
        
        // 面板
        Rectangle {
            width: 400
            height: 100
            color: Theme.ThemeManager.surfaceColor
            border.color: Theme.ThemeManager.borderColor
            border.width: 1
            radius: Theme.ThemeManager.borderRadius
            
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: Theme.ThemeManager.paddingNormal
                spacing: Theme.ThemeManager.paddingSmall
                
                Label {
                    text: "面板示例"
                    color: Theme.ThemeManager.textColor
                    font.pixelSize: Theme.ThemeManager.fontSizeNormal
                    font.weight: Font.Bold
                }
                
                Label {
                    text: "这是一个使用主题的面板"
                    color: Theme.ThemeManager.textSecondaryColor
                    font.pixelSize: Theme.ThemeManager.fontSizeNormal
                }
            }
        }
    }
    
    // 应用主题
    Component.onCompleted: {
        Theme.ThemeManager.applyTheme()
        console.log("Theme applied in example")
    }
}