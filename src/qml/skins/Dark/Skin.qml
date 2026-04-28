// skins/Default/Skin.qml
import QtQuick 2.15
import "../../SkinConstants.js" as SkinConstants
import ".."
BaseSkin {
    name: SkinConstants.SkinType.DARK
    colors: SkinConstants.Colors[name]
    fonts: SkinConstants.Fonts[name]
    sizes: SkinConstants.Sizes[name]

    // 覆盖特定样式
    Component.onCompleted: {
        // 可以在这里加载特定皮肤的样式组件
        buttonStyle = Qt.createComponent("DarkButtonStyle.qml")
    }
}