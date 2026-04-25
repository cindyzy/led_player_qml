// ThemeManager.qml - 主题管理，统一全项目控件样式
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

QtObject {
    // 主色调
    readonly property color primaryColor: "#1a56db"       // 主蓝色
    readonly property color secondaryColor: "#0e9f6e"     // 绿色（同步按钮）
    
    // 背景色
    readonly property color backgroundColor: "#1e1e2e"     // 主背景
    readonly property color surfaceColor: "#252535"       // 卡片/面板背景
    readonly property color hoverColor: "#2a2d2e"         // 悬停背景
    readonly property color selectedColor: "#094771"       // 选中背景
    
    // 文本色
    readonly property color textColor: "#D4D4D4"           // 主文本
    readonly property color textSecondaryColor: "#999999"  // 次要文本
    readonly property color textDisabledColor: "#666666"   // 禁用文本
    
    // 边框色
    readonly property color borderColor: "#3E3E3E"         // 边框
    readonly property color separatorColor: "#333333"      // 分隔线
    
    // 状态色
    readonly property color errorColor: "#e02424"           // 错误
    readonly property color warningColor: "#ff5a1f"        // 警告
    readonly property color successColor: "#0e9f6e"        // 成功
    
    // 字体
    readonly property int fontSizeSmall: 10
    readonly property int fontSizeNormal: 12
    readonly property int fontSizeLarge: 14
    
    // 间距
    readonly property int paddingSmall: 4
    readonly property int paddingNormal: 8
    readonly property int paddingLarge: 12
    
    // 圆角
    readonly property int borderRadius: 4
    
    // 创建主按钮
    function createPrimaryButton(text, onClicked) {
        return Qt.createQmlObject('''
            Button {
                text: "'''+text+'''"
                background: Rectangle {
                    color: control.hovered ? Qt.darker("'''+primaryColor+'''", 1.1) : "'''+primaryColor+'''"
                    border.color: Qt.darker("'''+primaryColor+'''", 1.2)
                    border.width: 1
                    radius: '''+borderRadius+'''
                }
                contentItem: Text {
                    text: control.text
                    color: "white"
                    font.pixelSize: '''+fontSizeNormal+'''
                    font.weight: Font.Medium
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                padding: '''+paddingNormal+'''
                onClicked: '''+onClicked+'''
            }
        ''', null, "PrimaryButton")
    }
    
    // 创建绿色按钮（同步按钮）
    function createGreenButton(text, onClicked) {
        return Qt.createQmlObject('''
            Button {
                text: "'''+text+'''"
                background: Rectangle {
                    color: control.hovered ? Qt.darker("'''+secondaryColor+'''", 1.1) : "'''+secondaryColor+'''"
                    border.color: Qt.darker("'''+secondaryColor+'''", 1.2)
                    border.width: 1
                    radius: '''+borderRadius+'''
                }
                contentItem: Text {
                    text: control.text
                    color: "white"
                    font.pixelSize: '''+fontSizeNormal+'''
                    font.weight: Font.Medium
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                padding: '''+paddingNormal+'''
                onClicked: '''+onClicked+'''
            }
        ''', null, "GreenButton")
    }
    
    // 创建文本输入框
    function createTextField(placeholderText, text, onTextChanged) {
        return Qt.createQmlObject('''
            TextField {
                placeholderText: "'''+placeholderText+'''"
                text: "'''+text+'''"
                background: Rectangle {
                    color: "'''+surfaceColor+'''"
                    border.color: "'''+borderColor+'''"
                    border.width: 1
                    radius: '''+borderRadius+'''
                }
                contentItem: TextInput {
                    color: "'''+textColor+'''"
                    font.pixelSize: '''+fontSizeNormal+'''
                    padding: '''+paddingNormal+'''
                }
                onTextChanged: '''+onTextChanged+'''
            }
        ''', null, "TextField")
    }
    
    // 创建下拉菜单
    function createComboBox(model, currentIndex, onCurrentIndexChanged) {
        return Qt.createQmlObject('''
            ComboBox {
                model: ['''+model+''']
                currentIndex: '''+currentIndex+'''
                background: Rectangle {
                    color: "'''+surfaceColor+'''"
                    border.color: "'''+borderColor+'''"
                    border.width: 1
                    radius: '''+borderRadius+'''
                }
                contentItem: Text {
                    color: "'''+textColor+'''"
                    font.pixelSize: '''+fontSizeNormal+'''
                    padding: '''+paddingNormal+'''
                }
                indicator: Rectangle {
                    color: "'''+textSecondaryColor+'''"
                    width: 20
                    height: 20
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    Text {
                        text: "▼"
                        color: "'''+textColor+'''"
                        font.pixelSize: '''+fontSizeSmall+'''
                        anchors.centerIn: parent
                    }
                }
                onCurrentIndexChanged: '''+onCurrentIndexChanged+'''
            }
        ''', null, "ComboBox")
    }
    
    // 创建标签
    function createLabel(text, fontSize, fontWeight) {
        return Qt.createQmlObject('''
            Label {
                text: "'''+text+'''"
                color: "'''+textColor+'''"
                font.pixelSize: '''+fontSize+'''
                font.weight: '''+fontWeight+'''
            }
        ''', null, "Label")
    }
    
    // 创建面板
    function createPanel() {
        return Qt.createQmlObject('''
            Rectangle {
                color: "'''+surfaceColor+'''"
                border.color: "'''+borderColor+'''"
                border.width: 1
                radius: '''+borderRadius+'''
            }
        ''', null, "Panel")
    }
    
    // 创建选项卡栏
    function createTabBar(tabs, currentIndex, onCurrentIndexChanged) {
        return Qt.createQmlObject('''
            TabBar {
                currentIndex: '''+currentIndex+'''
                background: Rectangle {
                    color: "'''+surfaceColor+'''"
                    border.bottom.color: "'''+borderColor+'''"
                    border.bottom.width: 1
                }
                TabButton {
                    text: "'''+tabs[0]+'''"
                    background: Rectangle {
                        color: control.active ? "'''+primaryColor+'''" : "transparent"
                        border.bottom: 2
                        border.bottomColor: control.active ? "'''+primaryColor+'''" : "transparent"
                    }
                    contentItem: Text {
                        color: control.active ? "white" : "'''+textColor+'''"
                        font.pixelSize: '''+fontSizeNormal+'''
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }
                '''+tabs.slice(1).map(tab => '''
                TabButton {
                    text: "'''+tab+'''"
                    background: Rectangle {
                        color: control.active ? "'''+primaryColor+'''" : "transparent"
                        border.bottom: 2
                        border.bottomColor: control.active ? "'''+primaryColor+'''" : "transparent"
                    }
                    contentItem: Text {
                        color: control.active ? "white" : "'''+textColor+'''"
                        font.pixelSize: '''+fontSizeNormal+'''
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }
                ''').join('')+'''
                onCurrentIndexChanged: '''+onCurrentIndexChanged+'''
            }
        ''', null, "TabBar")
    }
    
    // 应用主题到全局
    function applyTheme() {
        // 设置全局样式
        ApplicationWindow {
            color: backgroundColor
        }
        
        // 设置全局字体
        FontLoader {
            name: "Roboto"
            source: "qrc:/fonts/Roboto-Regular.ttf"
        }
        
        console.log("Theme applied")
    }
}