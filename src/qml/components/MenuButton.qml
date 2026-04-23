// MenuButton.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
// import Qt.labs.platform
Button {
    id: menuButton
    property list<MenuItem> menuItems

    width: 60
    height: 28
    flat: true
    background: Rectangle {
        color: menuButton.hovered ? "#2A2D2E" : "transparent"
        border.color: menuButton.hovered ? "#3E3E3E" : "transparent"
    }

    contentItem: Text {
        text: menuButton.text
        color: menuButton.hovered ? "#FFFFFF" : "#CCCCCC"
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }

    onClicked: {
        if (menuItems.length > 0) {
            menuPopup.open()
        }
    }

    Menu {
        id: menuPopup
        y: menuButton.height

        Repeater {
            model: menuItems
            delegate: Loader {
                sourceComponent: {
                    if (modelData.hasOwnProperty("text")) {
                        return menuItemComponent
                    } else if (modelData.hasOwnProperty("separator")) {
                        return menuSeparatorComponent
                    }
                }

                Component {
                    id: menuItemComponent
                    MenuItem {
                        text: modelData.text
                        // Shortcut: modelData.shortcut || ""
                        onTriggered: modelData.triggered && modelData.triggered()
                    }
                }

                Component {
                    id: menuSeparatorComponent
                    MenuSeparator {}
                }
            }
        }
    }
}