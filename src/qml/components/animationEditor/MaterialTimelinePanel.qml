import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts
import QtQuick.Dialogs
import QtQuick.Shapes

import "../"
//素材时间轴面板
TimeLineControl {
    id: timeline
    Layout.fillWidth: true
    Layout.preferredHeight: 100
    title: "动画时间轴"
    totalFrames: 120
    totalDurationMs: 6000
    currentFrame: 1
    tickInterval: 10
    tickCount: 12
    playheadColor: "#FF5722"
    // signal frameChanged(int frame)
    // signal playheadMoved(real position)
    onFrameChanged: function(frame) {
        console.log("当前帧:", frame)
        // 在这里更新预览或其他逻辑
        // frameChanged(frame)
    }

    onPlayheadMoved: function(position) {
        console.log("播放头位置:", position)
        // playheadMoved(position)
    }

}