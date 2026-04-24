// MainLayout.qml - 主布局结构
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "views"
Rectangle {
    id: mainWindow
    width: 1280
    height: 800
    visible: true
    // title: "LED Player 3"

    // 主内容区域（已移除占位符，使用实际布局）
    // 暗色主题
    // palette.window: "#1E1E1E"
    // palette.base: "#252526"
    // palette.alternateBase: "#2D2D2D"
    // palette.text: "#D4D4D4"
    // palette.windowText: "#D4D4D4"

    // 布局结构
    function applyQuickWiringPreview(config) {
        previewArea.applyQuickWiringPreview(config)
    }
    function handleMaterialReady(materialData)
    {
        playlistPanel.handleMaterialReady(materialData)
    }
    
    function saveProject()
    {
        playlistPanel.saveProject()
    }
    ColumnLayout {
        id:mainWindowColumnLayout
        anchors.fill: parent
        spacing: 0

        // 1. 菜单栏
        MenuBarArea {
            Layout.fillWidth: true
            Layout.preferredHeight: 30
        }

        // 2. 主内容区域
        SplitView {
            id:mainWindowArea
            Layout.fillWidth: true
            Layout.fillHeight: true
            orientation: Qt.Horizontal

            // 左侧：播放列表面板
            PlaylistPanel {
                id: playlistPanel

                SplitView.minimumWidth: 280
                SplitView.preferredWidth: 320
            }

            // 中间：预览和控制区域
            VideoPreviewArea {
                id: previewArea
                SplitView.fillWidth: true
                SplitView.minimumWidth: 500
            }

            // 右侧：属性设置面板
            PropertyPanel {
                id: propertyPanel
                SplitView.minimumWidth: 300
                SplitView.preferredWidth: 320
            }
        }

        // 3. 状态栏
        StatusBarArea {
            Layout.fillWidth: true
            Layout.preferredHeight: 24
        }
    }
}