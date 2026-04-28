// SkinSwitcher.qml - 皮肤选择下拉框
import QtQuick 2.15
import QtQuick.Controls 2.15
import ".."

ComboBox {
    id: control

    model: SkinManager.availableSkins.map(skin => skin.name)
    currentIndex: {
        var currentSkinName = SkinManager.currentSkin ? SkinManager.currentSkin.name : ""
        return model.indexOf(currentSkinName)
    }

    onActivated: {
        SkinManager.switchSkin(model[index])
    }

    delegate: ItemDelegate {
        width: control.width
        text: modelData
        highlighted: control.highlightedIndex === index

        contentItem: Text {
            text: modelData
            color: SkinManager.currentSkin.colors.text
            font: SkinManager.currentSkin.fonts.normal
            elide: Text.ElideRight
            verticalAlignment: Text.AlignVCenter
        }

        background: Rectangle {
            color: highlighted ?
                SkinManager.currentSkin.colors.primary :
                SkinManager.currentSkin.colors.background
        }
    }

    contentItem: Text {
        leftPadding: 10
        rightPadding: control.indicator.width + 10
        text: control.displayText
        color: SkinManager.currentSkin.colors.text
        font: SkinManager.currentSkin.fonts.normal
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }
}