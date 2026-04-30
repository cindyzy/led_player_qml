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
    width: 1400
    height: 900
    visible: true
    title: "LED Player 3"
    minimumWidth: 1024
    minimumHeight: 768

    // ---------- 新增：页面栈 ----------
    StackView {
        id: stackView
        anchors.fill: parent
        initialItem: loginPageComponent
    }

    // ---------- 登录页面组件 ----------
    Component {
        id: loginPageComponent
        LoginPage {
            // 登录成功的回调（由 LoginPage 内部触发）
            onLoginSuccess: {
                // 登录成功后，替换为主界面
                stackView.replace(mainLayoutComponent)
            }
        }
    }

    // ---------- 主界面组件 ----------
    Component {
        id: mainLayoutComponent
        MainLayout {
            // 可选：从 BusinessController 获取当前登录用户信息
            // 通过绑定 businessController.currentUserName 等
        }
    }

    // ---------- 对话框（保持不变）----------
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
            // 注意：此时主界面可能尚未加载，需确保 MainLayout 已存在
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

    // ---------- 快捷键（根据当前活动页面决定是否响应）----------
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

    // 可选：监听登出事件，返回到登录页
    Connections {
        target: businessController   // 需确保已在 main.cpp 中注册
        function onLogout() {
            stackView.replace(loginPageComponent)
        }
    }
}