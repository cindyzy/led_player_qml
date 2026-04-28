// Base/Skin.qml
pragma Singleton
import QtQuick 2.15
import "../SkinConstants.js" as SkinConstants

QtObject {
    id: skin

    // 必须实现的属性
    required property string name
    required property var colors

    // 字体配置
    property var fonts: {
        "small": Qt.font({ pixelSize: 10 }),
        "normal": Qt.font({ pixelSize: 12 }),
        "large": Qt.font({ pixelSize: 16 }),
        "title": Qt.font({ pixelSize: 20, bold: true })
    }

    property var sizes: {
        "radius": 4,
        "switchRadius": 10,
        "switchThumbRadius": 8
    }

    // 图标配置
    property var icons: ({
        home: "qrc:/icons/home.svg",
        settings: "qrc:/icons/settings.svg",
        user: "qrc:/icons/user.svg"
    })

    // 组件样式
    property Component buttonStyle: Qt.createComponent("ButtonStyle.qml")
    property Component textFieldStyle: Qt.createComponent("TextFieldStyle.qml")
    // 添加更多组件样式...
}