import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window
import "."
import "views"
import "dialogs"
import "utils"

ApplicationWindow {
    id: mainWindow
    width: 1400
    height: 900
    visible: true
    title: "LED Player 3"
    minimumWidth: 1024
    minimumHeight: 768
    menuBar: MenuBarArea{
    }


    // 应用图标
    // icon.source: "qrc:/icons/app-icon.png"

    // 应用数据
    // property alias projectModel: projectData
    // property alias playlistModel: playlistData

    // ProjectModel { id: projectData }
    // PlaylistModel { id: playlistData }

    // 主界面
    MainLayout {
        id: mainLayout
        // anchors.fill: parent
    }
    // 新建项目对话框
    NewProjectDialog {
        id: newProjectDialog
    }
    HardwareSettingsDialog{
        id:hardwareSettingsDialog
    }
    NewWiringDialog{
        id:newWiringDialog
    }
    QuickWiringDialog{
    id:quickWiringDialog
    }
    AnimationEditorDialog
    {
        id:animationEditorDialog
    }
    // CharBitmapGenerator
    // {
    //     id:charBitmapGenerator

    // }
    property var charGenerator: charBitmapGenerator
    Connections {
        target: quickWiringDialog
        function onQuickWiringConfirmed(config) {
            mainLayout.applyQuickWiringPreview(config)
        }
    }
    // 快捷键
    Shortcut {
        sequence: "Ctrl+O"
        onActivated: console.log("打开项目")
    }

    Shortcut {
        sequence: "Ctrl+S"
        onActivated: console.log("保存项目")
    }

    Shortcut {
        sequence: "Space"
        onActivated: console.log("播放/暂停")
    }
}
