import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window
import "."
import "views"
import "dialogs"
import "utils"
import "components"

ApplicationWindow {
    id: mainWindow
    width:  200
    height:  100
    visible: true
    title: "LED Player 3"
    minimumWidth: 200
    minimumHeight: 100

    // 暗色主题
    palette.window: "#1E1E1E"
    palette.base: "#252526"
    palette.alternateBase: "#2D2D2D"
    palette.text: "#D4D4D4"
    palette.windowText: "#D4D4D4"

    // ---------- 页面栈 ----------
    StackView {
        id: stackView
        anchors.fill: parent
        initialItem: loginPageComponent
    }

    // ---------- 登录页面组件 ----------
    Component {
        id: loginPageComponent
        LoginPage {
            width: 200
            height: 100
            onLoginSuccess: {
                stackView.replace(mainLayoutComponent)
                mainWindow.width=1400
                mainWindow.height=900
                // mainLayout.width=1400
                // mainLayout.height=800
            }
        }
    }

    // ---------- 主界面组件 ----------
    Component {
        id: mainLayoutComponent
        MainLayout {
            id: mainLayout
            width: 1400
            height: 870
        }
    }

    // ---------- 对话框 ----------
    NewProjectDialog { id: newProjectDialog }
    HardwareSettingsDialog { id: hardwareSettingsDialog }
    NewWiringDialog { id: newWiringDialog }
    QuickWiringDialog { id: quickWiringDialog }
    AnimationEditorDialog {
        id: animationEditorDialog
        visible: false
    }
    MessageDialog { id: messageDialog }

    // ---------- 信号连接 ----------
    Connections {
        target: quickWiringDialog
        function onQuickWiringConfirmed(config) {
            if (stackView.currentItem && stackView.currentItem.applyQuickWiringPreview)
                stackView.currentItem.applyQuickWiringPreview(config)
        }
    }

    Connections {
        target: animationEditorDialog
        function onMaterialReady(materialData) {
            if (stackView.currentItem && stackView.currentItem.handleMaterialReady)
                stackView.currentItem.handleMaterialReady(materialData)
        }
    }

    // ---------- 快捷键 ----------
    Shortcut {
        sequence: "Ctrl+O"
        onActivated: {
            if (stackView.currentItem && stackView.currentItem.openProject)
                stackView.currentItem.openProject()
            else
                console.log("打开项目")
        }
    }

    Shortcut {
        sequence: "Ctrl+S"
        onActivated: {
            if (stackView.currentItem && stackView.currentItem.saveProject)
                stackView.currentItem.saveProject()
            else
                console.log("保存项目")
        }
    }

    Shortcut {
        sequence: "Space"
        onActivated: {
            if (stackView.currentItem && stackView.currentItem.togglePlayPause)
                stackView.currentItem.togglePlayPause()
            else
                console.log("播放/暂停")
        }
    }

    // 登出事件监听
    Connections {
        target: businessController
        function onLogout() {
            stackView.replace(loginPageComponent)
        }
    }
}