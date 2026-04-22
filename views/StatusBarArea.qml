// StatusBarArea.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: statusBar
    color: "#007ACC"

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 8
        anchors.rightMargin: 8
        spacing: 20

        // 就绪状态
        Text {
            text: "就绪"
            color: "#FFFFFF"
            font.pixelSize: 12
        }

        // 项目信息
        Text {
            text: "项目: 新建项目1"
            color: "#FFFFFF"
            font.pixelSize: 12
        }

        // 分辨率
        Text {
            text: "分辨率: 192×144"
            color: "#FFFFFF"
            font.pixelSize: 12
        }

        // 帧率
        Text {
            text: "帧率: 20.0 fps"
            color: "#FFFFFF"
            font.pixelSize: 12
        }

        // 连接状态
        Text {
            text: "控制器: 已连接"
            color: "#FFFFFF"
            font.pixelSize: 12
        }

        // 内存使用
        Text {
            text: "内存: 128MB/2GB"
            color: "#FFFFFF"
            font.pixelSize: 12
        }

        Item { Layout.fillWidth: true }

        // 版本信息
        Text {
            text: "LED Player 3 v3.0.0"
            color: "#FFFFFF"
            font.pixelSize: 12
        }
    }
}