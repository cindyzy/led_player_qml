// QuickWiringDialog.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts
import QtQuick.Shapes
import QtQuick.Window
import "../components"
Popup {
    id: wiringDialog
    signal quickWiringConfirmed(var config)
    width: 600
    height: 700
    modal: true
    closePolicy: Popup.CloseOnEscape
    focus: true

    // 位置属性
    property int dragX: 0
    property int dragY: 0

    // 暗色主题
    Material.theme: Material.Dark
    Material.accent: Material.Blue

    // 背景遮罩
    background: Rectangle {
        color: "#80000000"  // 半透明黑色背景
    }

    // 主内容容器
    Rectangle {
        id: popupContainer
        width: parent.width
        height: parent.height
        color: "#252526"
        border.color: "#3E3E3E"
        border.width: 2
        radius: 8

        // 阴影效果
        layer.enabled: true
        // layer.effect: DropShadow {
        //     verticalOffset: 4
        //     radius: 16
        //     samples: 16
        //     color: "#80000000"
        // }

        ColumnLayout {
            anchors.fill: parent
            spacing: 0

            // 标题栏（可拖动区域）
            Rectangle {
                id: titleBar
                Layout.fillWidth: true
                height: 40
                color: "#333333"
                radius: 8

                // 鼠标区域用于拖动
                MouseArea {
                    id: dragArea
                    anchors.fill: parent
                    property point startMousePos: Qt.point(0, 0)
                    property point startWindowPos: Qt.point(0, 0)

                    onPressed: {
                        startMousePos = Qt.point(mouse.x, mouse.y)
                        startWindowPos = Qt.point(wiringDialog.x, wiringDialog.y)
                    }

                    onPositionChanged: {
                        if (pressed) {
                            var deltaX = mouse.x - startMousePos.x
                            var deltaY = mouse.y - startMousePos.y
                            wiringDialog.x = startWindowPos.x + deltaX
                            wiringDialog.y = startWindowPos.y + deltaY
                        }
                    }
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 15
                    anchors.rightMargin: 10
                    spacing: 10

                    // 标题
                    Text {
                        text: "快速布线"
                        color: "#FFFFFF"
                        font.bold: true
                        font.pixelSize: 16
                        Layout.fillWidth: true
                    }

                    // 关闭按钮
                    Button {
                        id: closeButton
                        width: 30
                        height: 30
                        flat: true

                        background: Rectangle {
                            color: closeButton.hovered ? "#FF4444" : "transparent"
                            radius: 3
                        }

                        contentItem: Text {
                            text: "×"
                            color: "#FFFFFF"
                            font.pixelSize: 20
                            anchors.centerIn: parent
                        }

                        onClicked: wiringDialog.close()
                    }
                }
            }

            // 内容区域


            ColumnLayout {
                width: parent.width
                spacing: 15
                // padding: 20
                // leftMargin: 20
                Layout.leftMargin:20
                // 第一行：布线宽度和高度
                RowLayout {
                    spacing: 20
                    Layout.fillWidth: true

                    // 布线宽度
                    ColumnLayout {
                        spacing: 5
                        Layout.fillWidth: true

                        Text {
                            text: "布线宽度"
                            color: "#CCCCCC"
                            font.pixelSize: 12
                        }

                        TextField {
                            id: widthField
                            text: "16"
                            Layout.fillWidth: true

                            background: Rectangle {
                                color: "#333333"
                                border.color: "#555555"
                                border.width: 1
                                radius: 3
                            }

                            color: "#FFFFFF"
                            font.pixelSize: 14
                            horizontalAlignment: Text.AlignHCenter
                            validator: IntValidator { bottom: 1; top: 9999 }

                            onTextChanged: updateWiringPreview()
                        }
                    }

                    // 布线高度
                    ColumnLayout {
                        spacing: 5
                        Layout.fillWidth: true

                        Text {
                            text: "布线高度"
                            color: "#CCCCCC"
                            font.pixelSize: 12
                        }

                        TextField {
                            id: heightField
                            text: "8"
                            Layout.fillWidth: true

                            background: Rectangle {
                                color: "#333333"
                                border.color: "#555555"
                                border.width: 1
                                radius: 3
                            }

                            color: "#FFFFFF"
                            font.pixelSize: 14
                            horizontalAlignment: Text.AlignHCenter
                            validator: IntValidator { bottom: 1; top: 9999 }

                            onTextChanged: updateWiringPreview()
                        }
                    }
                }

                // 第二行：控制器型号和驱动点数
                RowLayout {
                    spacing: 20
                    Layout.fillWidth: true

                    // 控制器型号
                    ColumnLayout {
                        spacing: 5
                        Layout.fillWidth: true

                        Text {
                            text: "控制器型号"
                            color: "#CCCCCC"
                            font.pixelSize: 12
                        }

                        ComboBox {
                            id: controllerCombo
                            model: ["SY-418", "SY-416", "SY-412", "SY-408"]
                            currentIndex: 0
                            Layout.fillWidth: true

                            background: Rectangle {
                                color: "#333333"
                                border.color: "#555555"
                                border.width: 1
                                radius: 3
                            }

                            contentItem: Text {
                                text: controllerCombo.currentText
                                color: "#FFFFFF"
                                leftPadding: 8
                                verticalAlignment: Text.AlignVCenter
                                font.pixelSize: 14
                            }

                            popup.background: Rectangle {
                                color: "#333333"
                                border.color: "#555555"
                            }

                            onCurrentIndexChanged: updatePortCount()
                        }
                    }

                    // 驱动点数
                    ColumnLayout {
                        spacing: 5
                        Layout.fillWidth: true

                        Text {
                            text: "驱动点数"
                            color: "#CCCCCC"
                            font.pixelSize: 12
                        }

                        ComboBox {
                            id: drivePointsCombo
                            model: ["1024", "512", "256", "128", "64", "32"]
                            currentIndex: 0
                            Layout.fillWidth: true

                            background: Rectangle {
                                color: "#333333"
                                border.color: "#555555"
                                border.width: 1
                                radius: 3
                            }

                            contentItem: Text {
                                text: drivePointsCombo.currentText
                                color: "#FFFFFF"
                                leftPadding: 8
                                verticalAlignment: Text.AlignVCenter
                                font.pixelSize: 14
                            }

                            popup.background: Rectangle {
                                color: "#333333"
                                border.color: "#555555"
                            }
                        }
                    }
                }

                // 端口数显示
                Text {
                    id: portCountText
                    text: "端口数：8端口"
                    color: "#CCCCCC"
                    font.pixelSize: 12
                    Layout.topMargin: 5
                }

                // 中间区域：布线方向和比例调整
                RowLayout {
                    spacing: 20
                    Layout.fillWidth: true
                    Layout.preferredHeight: 200

                    // 左侧：布线方向
                    ColumnLayout {
                        spacing: 10
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        Text {
                            text: "布线方向"
                            color: "#CCCCCC"
                            font.bold: true
                            font.pixelSize: 14
                        }

                        // 布线方向网格
                        GridLayout {
                            id: directionGrid
                            columns: 8
                            rows: 2
                            columnSpacing: 5
                            rowSpacing: 5
                            Layout.alignment: Qt.AlignHCenter

                            // 第一行
                            ImgButton {
                                id: wiring_StartLeftBottom_EndRightTop_M_Horizontal_Arrow
                                Layout.row: 0
                                Layout.column: 0
                                text: "↖"
                                onClicked: setWiringDirection("wiring_StartLeftBottom_EndRightTop_M_Horizontal")
                            }

                            ImgButton {
                                id: wiring_StartLeftTop_EndRightBottom_M_Horizontal_Arrow
                                Layout.row: 0
                                Layout.column: 1
                                text: "↑"
                                onClicked: setWiringDirection("wiring_StartLeftTop_EndRightBottom_M_Horizontal")
                            }

                            ImgButton {
                                id: wiring_StartRightBottom_EndLeftTop_M_Horizontal_Arrow
                                Layout.row: 0
                                Layout.column: 2
                                width: 30
                                height: 30
                                text: "↗"
                                onClicked: setWiringDirection("wiring_StartRightBottom_EndLeftTop_M_Horizontal")
                            }


                            ImgButton {
                                id: wiring_StartRightTop_EndLeftBottom_M_Horizontal_Arrow
                                Layout.row: 0
                                Layout.column: 3
                                width: 30
                                height: 30
                                text: "←"
                                onClicked: setWiringDirection("wiring_StartRightTop_EndLeftBottom_M_Horizontal")
                            }

                            ImgButton {
                                id: wiring_StartLeftBottom_EndRightTop_M_Vertical_Button
                                Layout.row: 0
                                Layout.column: 4
                                width: 30
                                height: 30
                                text: "●"
                                onClicked: setWiringDirection("wiring_StartLeftBottom_EndRightTop_M_Vertical")
                            }

                            ImgButton {
                                id: wiring_StartLeftTop_EndRightBottom_M_Vertical_Arrow
                                Layout.row: 0
                                Layout.column: 5
                                width: 30
                                height: 30
                                text: "→"
                                onClicked: setWiringDirection("wiring_StartLeftTop_EndRightBottom_M_Vertical")
                            }

                            ImgButton {
                                id: wiring_StartRightBottom_EndLeftTop_M_Vertical_Arrow
                                Layout.row: 0
                                Layout.column: 6
                                width: 30
                                height: 30
                                text: "↙"
                                onClicked: setWiringDirection("wiring_StartRightBottom_EndLeftTop_M_Vertical")
                            }

                            ImgButton {
                                id: wiring_StartRightTop_EndLeftBottom_M_Vertical_Arrow
                                Layout.row: 0
                                Layout.column: 7
                                width: 30
                                height: 30
                                text: "↓"
                                onClicked: setWiringDirection("wiring_StartRightTop_EndLeftBottom_M_Vertical")
                            }

                            ImgButton {
                                id: wiring_StartLeftBottom_EndRightTop_N_Arrow
                                Layout.row: 1
                                Layout.column: 0
                                width: 30
                                height: 30
                                text: "↘"
                                onClicked: setWiringDirection("wiring_StartLeftBottom_EndRightTop_N")
                            }
                            ImgButton {
                                id: wiring_StartLeftTop_EndRightBottom_N_Arrow
                                Layout.row: 1
                                Layout.column: 1
                                width: 30
                                height: 30
                                text: "↘"
                                onClicked: setWiringDirection("wiring_StartLeftTop_EndRightBottom_N")
                            }
                            ImgButton {
                                id: wiring_StartRightBottom_EndLeftTop_N_Arrow
                                Layout.row: 1
                                Layout.column: 2
                                width: 30
                                height: 30
                                text: "↘"
                                onClicked: setWiringDirection("wiring_StartRightBottom_EndLeftTop_N")
                            }
                            ImgButton {
                                id: wiring_StartRightTop_EndLeftBottom_N_Arrow
                                Layout.row: 1
                                Layout.column: 3
                                width: 30
                                height: 30
                                text: "↘"
                                onClicked: setWiringDirection("wiring_StartRightTop_EndLeftBottom_N")
                            }
                            ImgButton {
                                id: wiring_StartLeftBottom_EndRightTop_Z_Arrow
                                Layout.row: 1
                                Layout.column: 4
                                width: 30
                                height: 30
                                text: "↘"
                                onClicked: setWiringDirection("wiring_StartLeftBottom_EndRightTop_Z")
                            }
                            ImgButton {
                                id: wiring_StartLeftTop_EndRightBottom_Z_Arrow
                                Layout.row: 1
                                Layout.column: 5
                                width: 30
                                height: 30
                                text: "↘"
                                onClicked: setWiringDirection("wiring_StartLeftTop_EndRightBottom_Z")
                            }
                            ImgButton {
                                id: wiring_StartRightBottom_EndLeftTop_Z_Arrow
                                Layout.row: 1
                                Layout.column: 6
                                width: 30
                                height: 30
                                text: "↘"
                                onClicked: setWiringDirection("wiring_StartRightBottom_EndLeftTop_Z")
                            }
                            ImgButton {
                                id: wiring_StartRightTop_EndLeftBottom_Z_Arrow
                                Layout.row: 1
                                Layout.column: 7
                                width: 30
                                height: 30
                                text: "↘"
                                onClicked: setWiringDirection("wiring_StartRightTop_EndLeftBottom_Z")
                            }

                        }
                        // 方向描述
                        Text {
                            id: directionText
                            text: "当前方向：右→左"
                            color: "#999999"
                            font.pixelSize: 12
                            Layout.alignment: Qt.AlignHCenter
                        }
                    }

                    // 右侧：比例调整
                    ColumnLayout {
                        spacing: 10
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        Text {
                            text: "比例调整"
                            color: "#CCCCCC"
                            font.bold: true
                            font.pixelSize: 14
                        }

                        // 水平点间距
                        ColumnLayout {
                            spacing: 5

                            Text {
                                text: "水平点间距"
                                color: "#CCCCCC"
                                font.pixelSize: 12
                            }

                            TextField {
                                id: horizontalSpacingField
                                text: "0"
                                Layout.fillWidth: true

                                background: Rectangle {
                                    color: "#333333"
                                    border.color: "#555555"
                                    border.width: 1
                                    radius: 3
                                }

                                color: "#FFFFFF"
                                font.pixelSize: 14
                                horizontalAlignment: Text.AlignHCenter
                                validator: IntValidator { bottom: 0; top: 9999 }

                                onTextChanged: updateWiringPreview()
                            }
                        }

                        // 垂直点间距
                        ColumnLayout {
                            spacing: 5

                            Text {
                                text: "垂直点间距"
                                color: "#CCCCCC"
                                font.pixelSize: 12
                            }

                            TextField {
                                id: verticalSpacingField
                                text: "0"
                                Layout.fillWidth: true

                                background: Rectangle {
                                    color: "#333333"
                                    border.color: "#555555"
                                    border.width: 1
                                    radius: 3
                                }

                                color: "#FFFFFF"
                                font.pixelSize: 14
                                horizontalAlignment: Text.AlignHCenter
                                validator: IntValidator { bottom: 0; top: 9999 }

                                onTextChanged: updateWiringPreview()
                            }
                        }
                    }
                }

                // 布线预览区域
                Rectangle {
                    id: previewContainer
                    Layout.fillWidth: true
                    Layout.preferredHeight: 200
                    color: "#1E1E1E"
                    border.color: "#444444"
                    border.width: 1
                    radius: 5

                    Text {
                        text: "布线示意图"
                        color: "#666666"
                        font.pixelSize: 12
                        anchors.top: parent.top
                        anchors.left: parent.left
                        anchors.margins: 5
                    }

                    // 布线预览（支持滚动）
                    Flickable {
                        id: previewFlick
                        anchors.top: parent.top
                        anchors.topMargin: 22
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        anchors.margins: 5
                        clip: true
                        boundsBehavior: Flickable.StopAtBounds
                        contentWidth: previewContent.width
                        contentHeight: previewContent.height
                        ScrollBar.horizontal: ScrollBar { policy: ScrollBar.AsNeeded }
                        ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }

                        Item {
                            id: previewContent
                            width: wiringCanvas.width
                            height: wiringCanvas.height

                            Canvas {
                                id: wiringCanvas
                                width: Math.max(previewFlick.width, (Math.max(1, (parseInt(widthField.text) || 16) * ((parseInt(horizontalSpacingField.text) || 0) + 1)) * ((previewFlick.width - 20) / Math.max(1, (parseInt(widthField.text) || 16))) + 20))
                                height: Math.max(previewFlick.height, (Math.max(1, (parseInt(heightField.text) || 8) * ((parseInt(verticalSpacingField.text) || 0) + 1)) * ((previewFlick.height - 20) / Math.max(1, (parseInt(heightField.text) || 8))) + 20))
                                property string direction: "wiring_StartLeftBottom_EndRightTop_M_Horizontal"
                                property var pixelPoints: []
                                onPaint: {
                                    var ctx = getContext("2d")
                                    ctx.clearRect(0, 0, width, height)

                                    var baseWidthVal = parseInt(widthField.text) || 16
                                    var baseHeightVal = parseInt(heightField.text) || 8
                                    var hSpacing = parseInt(horizontalSpacingField.text) || 0
                                    var vSpacing = parseInt(verticalSpacingField.text) || 0
                                    var hFactor = hSpacing + 1
                                    var vFactor = vSpacing + 1

                                    // 根据点间距扩展网格：左侧/顶部和每个网格间距都会插入额外网格
                                    var widthVal = Math.max(1, baseWidthVal * hFactor)
                                    var heightVal = Math.max(1, baseHeightVal * vFactor)

                                    // 网格大小保持不变：始终按基础网格计算单元尺寸
                                    var baseCellWidth = (previewFlick.width - 20) / Math.max(1, baseWidthVal)
                                    var baseCellHeight = (previewFlick.height - 20) / Math.max(1, baseHeightVal)
                                    var cellWidth = baseCellWidth
                                    var cellHeight = baseCellHeight
                                    var drawWidth = widthVal * cellWidth
                                    var drawHeight = heightVal * cellHeight
                                    // 圆圈大小固定：不随间距变化，避免出现整体缩放观感
                                    var routeCellWidth = baseCellWidth * hFactor
                                    var routeCellHeight = baseCellHeight * vFactor
                                    var pointRadius = Math.max(2, Math.min(baseCellWidth, baseCellHeight) * 0.25)
                                    pixelPoints = []

                                    // 绘制网格
                                    ctx.strokeStyle = "#333333"
                                    ctx.lineWidth = 1

                                    // 垂直线
                                    for (var i = 0; i <= widthVal; i++) {
                                        var x = i * cellWidth
                                        ctx.beginPath()
                                        ctx.moveTo(x, 0)
                                        ctx.lineTo(x, drawHeight)
                                        ctx.stroke()
                                    }

                                    // 水平线
                                    for (var j = 0; j <= heightVal; j++) {
                                        var y = j * cellHeight
                                        ctx.beginPath()
                                        ctx.moveTo(0, y)
                                        ctx.lineTo(drawWidth, y)
                                        ctx.stroke()
                                    }

                                    // 绘制像素点圆圈（在线条后面）
                                    ctx.strokeStyle = "#E0E0E0"
                                    ctx.lineWidth = 1
                                    for (j = 0; j < heightVal; j++) {
                                        for (i = 0; i < widthVal; i++) {
                                            var px = i * cellWidth + cellWidth / 2
                                            var py = j * cellHeight + cellHeight / 2
                                            pixelPoints.push({
                                                                 x: px,
                                                                 y: py,
                                                                 col: i + 1,
                                                                 row: j + 1
                                                             })
                                            ctx.beginPath()
                                            ctx.arc(px, py, pointRadius, 0, Math.PI * 2)
                                            ctx.stroke()
                                        }
                                    }

                                    // 绘制布线路径（红色）
                                    // 红线保持原始形状：按基础网格数量绘制，不随扩展网格数量改变折返次数
                                    widthVal = baseWidthVal
                                    heightVal = baseHeightVal
                                    cellWidth = routeCellWidth
                                    cellHeight = routeCellHeight
                                    // 当间距扩展为偶数倍时，红线补偿半个基础网格，确保线始终经过圆圈中心
                                    var routeOffsetX = (hFactor % 2 === 0) ? (baseCellWidth / 2) : 0
                                    var routeOffsetY = (vFactor % 2 === 0) ? (baseCellHeight / 2) : 0
                                    ctx.save()
                                    ctx.translate(routeOffsetX, routeOffsetY)
                                    ctx.strokeStyle = "#FF0000"
                                    ctx.lineWidth = 2
                                    ctx.beginPath()

                                    var line_x = 0
                                    var line_y = 0
                                    switch(direction) {
                                        // 标准M型（水平方向）
                                    case "wiring_StartLeftBottom_EndRightTop_M_Horizontal":
                                        // 从左下到右上的列蛇形布线（连续路径）
                                        var startX = cellWidth / 2
                                        var startY = (heightVal - 1) * cellHeight + cellHeight / 2
                                        ctx.moveTo(startX, startY)

                                        for (i = 0; i < widthVal; i++) {
                                            var colX = i * cellWidth + cellWidth / 2
                                            var topY = cellHeight / 2
                                            var bottomY = (heightVal - 1) * cellHeight + cellHeight / 2

                                            // 偶数列：下->上；奇数列：上->下
                                            if (i % 2 === 0) {
                                                ctx.lineTo(colX, topY)
                                            } else {
                                                ctx.lineTo(colX, bottomY)
                                            }

                                            // 连接到下一列，形成蛇形折返
                                            if (i < widthVal - 1) {
                                                var nextColX = (i + 1) * cellWidth + cellWidth / 2
                                                ctx.lineTo(nextColX, (i % 2 === 0) ? topY : bottomY)
                                            }
                                        }

                                        // 保证终点为右上（当列数为偶数时需要补一段上行）
                                        if (widthVal % 2 === 0) {
                                            var lastColX = (widthVal - 1) * cellWidth + cellWidth / 2
                                            ctx.lineTo(lastColX, cellHeight / 2)
                                        }
                                        break
                                    case "wiring_StartLeftTop_EndRightBottom_M_Horizontal":
                                        // 从左上到右下的列蛇形布线（连续路径）
                                        startX = cellWidth / 2
                                        startY = cellHeight / 2
                                        ctx.moveTo(startX, startY)

                                        for (i = 0; i < widthVal; i++) {
                                            colX = i * cellWidth + cellWidth / 2
                                            topY = cellHeight / 2
                                            bottomY = (heightVal - 1) * cellHeight + cellHeight / 2

                                            // 偶数列：上->下；奇数列：下->上
                                            if (i % 2 === 0) {
                                                ctx.lineTo(colX, bottomY)
                                            } else {
                                                ctx.lineTo(colX, topY)
                                            }

                                            // 连接到下一列，形成蛇形折返
                                            if (i < widthVal - 1) {
                                                nextColX = (i + 1) * cellWidth + cellWidth / 2
                                                ctx.lineTo(nextColX, (i % 2 === 0) ? bottomY : topY)
                                            }
                                        }

                                        // 保证终点为右下（当列数为偶数时需要补一段下行）
                                        if (widthVal % 2 === 0) {
                                            lastColX = (widthVal - 1) * cellWidth + cellWidth / 2
                                            ctx.lineTo(lastColX, (heightVal - 1) * cellHeight + cellHeight / 2)
                                        }
                                        break
                                    case "wiring_StartRightBottom_EndLeftTop_M_Horizontal":
                                        // 从右下到左上的列蛇形布线（连续路径）
                                        startX = (widthVal - 1) * cellWidth + cellWidth / 2
                                        startY = (heightVal - 1) * cellHeight + cellHeight / 2
                                        ctx.moveTo(startX, startY)

                                        for (i = widthVal - 1; i >= 0; i--) {
                                            colX = i * cellWidth + cellWidth / 2
                                            topY = cellHeight / 2
                                            bottomY = (heightVal - 1) * cellHeight + cellHeight / 2

                                            // 从右侧起，按列蛇形：奇数列下->上；偶数列上->下
                                            if (i % 2 === 1) {
                                                ctx.lineTo(colX, topY)
                                            } else {
                                                ctx.lineTo(colX, bottomY)
                                            }

                                            // 连接到左侧下一列，形成蛇形折返
                                            if (i > 0) {
                                                nextColX = (i - 1) * cellWidth + cellWidth / 2
                                                ctx.lineTo(nextColX, (i % 2 === 1) ? topY : bottomY)
                                            }
                                        }

                                        // 保证终点为左上（当列数为偶数时需要补一段上行）
                                        if (widthVal % 2 === 0) {
                                            lastColX = cellWidth / 2
                                            ctx.lineTo(lastColX, cellHeight / 2)
                                        }
                                        break
                                    case "wiring_StartRightTop_EndLeftBottom_M_Horizontal":
                                        // 从右上到左下的列蛇形布线（连续路径）
                                        startX = (widthVal - 1) * cellWidth + cellWidth / 2
                                        startY = cellHeight / 2
                                        ctx.moveTo(startX, startY)

                                        for (i = widthVal - 1; i >= 0; i--) {
                                            colX = i * cellWidth + cellWidth / 2
                                            topY = cellHeight / 2
                                            bottomY = (heightVal - 1) * cellHeight + cellHeight / 2

                                            // 从右侧起，按列蛇形：奇数列上->下；偶数列下->上
                                            if (i % 2 === 1) {
                                                ctx.lineTo(colX, bottomY)
                                            } else {
                                                ctx.lineTo(colX, topY)
                                            }

                                            // 连接到左侧下一列，形成蛇形折返
                                            if (i > 0) {
                                                nextColX = (i - 1) * cellWidth + cellWidth / 2
                                                ctx.lineTo(nextColX, (i % 2 === 1) ? bottomY : topY)
                                            }
                                        }

                                        // 保证终点为左下（当列数为偶数时需要补一段下行）
                                        if (widthVal % 2 === 0) {
                                            lastColX = cellWidth / 2
                                            ctx.lineTo(lastColX, (heightVal - 1) * cellHeight + cellHeight / 2)
                                        }
                                        break
                                        // 旋转90度的M型
                                    case "wiring_StartLeftBottom_EndRightTop_M_Vertical":
                                        // 从左下到右上的行蛇形布线（连续路径）
                                        startX = cellWidth / 2
                                        startY = (heightVal - 1) * cellHeight + cellHeight / 2
                                        ctx.moveTo(startX, startY)

                                        for (j = heightVal - 1; j >= 0; j--) {
                                            var rowY = j * cellHeight + cellHeight / 2
                                            var leftX = cellWidth / 2
                                            var rightX = (widthVal - 1) * cellWidth + cellWidth / 2

                                            // 从底部起按行蛇形：偶数行左->右；奇数行右->左
                                            if (j % 2 === 0) {
                                                ctx.lineTo(rightX, rowY)
                                            } else {
                                                ctx.lineTo(leftX, rowY)
                                            }

                                            // 连接到上一行，形成蛇形折返
                                            if (j > 0) {
                                                var nextRowY = (j - 1) * cellHeight + cellHeight / 2
                                                ctx.lineTo((j % 2 === 0) ? rightX : leftX, nextRowY)
                                            }
                                        }

                                        // 保证终点为右上（当行数为偶数时需要补一段到右侧）
                                        if (heightVal % 2 === 0) {
                                            var topYFinal = cellHeight / 2
                                            var rightXFinal = (widthVal - 1) * cellWidth + cellWidth / 2
                                            ctx.lineTo(rightXFinal, topYFinal)
                                        }
                                        break
                                    case "wiring_StartLeftTop_EndRightBottom_M_Vertical":
                                        // 从左上到右下的行蛇形布线（连续路径）
                                        startX = cellWidth / 2
                                        startY = cellHeight / 2
                                        ctx.moveTo(startX, startY)

                                        for (j = 0; j < heightVal; j++) {
                                            rowY = j * cellHeight + cellHeight / 2
                                            leftX = cellWidth / 2
                                            rightX = (widthVal - 1) * cellWidth + cellWidth / 2

                                            // 从顶部起按行蛇形：偶数行左->右；奇数行右->左
                                            if (j % 2 === 0) {
                                                ctx.lineTo(rightX, rowY)
                                            } else {
                                                ctx.lineTo(leftX, rowY)
                                            }

                                            // 连接到下一行，形成蛇形折返
                                            if (j < heightVal - 1) {
                                                nextRowY = (j + 1) * cellHeight + cellHeight / 2
                                                ctx.lineTo((j % 2 === 0) ? rightX : leftX, nextRowY)
                                            }
                                        }

                                        // 保证终点为右下（当行数为偶数时需要补一段到右侧）
                                        if (heightVal % 2 === 0) {
                                            var bottomYFinal = (heightVal - 1) * cellHeight + cellHeight / 2
                                            var rightXBottom = (widthVal - 1) * cellWidth + cellWidth / 2
                                            ctx.lineTo(rightXBottom, bottomYFinal)
                                        }
                                        break
                                    case "wiring_StartRightBottom_EndLeftTop_M_Vertical":
                                        // 从右下到左上的行蛇形布线（连续路径）
                                        startX = (widthVal - 1) * cellWidth + cellWidth / 2
                                        startY = (heightVal - 1) * cellHeight + cellHeight / 2
                                        ctx.moveTo(startX, startY)

                                        for (j = heightVal - 1; j >= 0; j--) {
                                            rowY = j * cellHeight + cellHeight / 2
                                            leftX = cellWidth / 2
                                            rightX = (widthVal - 1) * cellWidth + cellWidth / 2
                                            var stepFromBottom = (heightVal - 1) - j

                                            // 从底部起按行蛇形：偶数步右->左；奇数步左->右
                                            if (stepFromBottom % 2 === 0) {
                                                ctx.lineTo(leftX, rowY)
                                            } else {
                                                ctx.lineTo(rightX, rowY)
                                            }

                                            // 连接到上一行，形成蛇形折返
                                            if (j > 0) {
                                                nextRowY = (j - 1) * cellHeight + cellHeight / 2
                                                ctx.lineTo((stepFromBottom % 2 === 0) ? leftX : rightX, nextRowY)
                                            }
                                        }

                                        // 保证终点为左上（当行数为偶数时需要补一段到左侧）
                                        if (heightVal % 2 === 0) {
                                            var topYLeft = cellHeight / 2
                                            var leftXTop = cellWidth / 2
                                            ctx.lineTo(leftXTop, topYLeft)
                                        }
                                        break
                                    case "wiring_StartRightTop_EndLeftBottom_M_Vertical":
                                        // 从右上到左下的行蛇形布线（连续路径）
                                        startX = (widthVal - 1) * cellWidth + cellWidth / 2
                                        startY = cellHeight / 2
                                        ctx.moveTo(startX, startY)

                                        for (j = 0; j < heightVal; j++) {
                                            rowY = j * cellHeight + cellHeight / 2
                                            leftX = cellWidth / 2
                                            rightX = (widthVal - 1) * cellWidth + cellWidth / 2
                                            var stepFromTop = j

                                            // 从顶部起按行蛇形：偶数步右->左；奇数步左->右
                                            if (stepFromTop % 2 === 0) {
                                                ctx.lineTo(leftX, rowY)
                                            } else {
                                                ctx.lineTo(rightX, rowY)
                                            }

                                            // 连接到下一行，形成蛇形折返
                                            if (j < heightVal - 1) {
                                                nextRowY = (j + 1) * cellHeight + cellHeight / 2
                                                ctx.lineTo((stepFromTop % 2 === 0) ? leftX : rightX, nextRowY)
                                            }
                                        }

                                        // 保证终点为左下（当行数为偶数时需要补一段到左侧）
                                        if (heightVal % 2 === 0) {
                                            var bottomYLeft = (heightVal - 1) * cellHeight + cellHeight / 2
                                            var leftXBottom = cellWidth / 2
                                            ctx.lineTo(leftXBottom, bottomYLeft)
                                        }
                                        break
                                        // 标准n型
                                    case "wiring_StartLeftBottom_EndRightTop_N":
                                        // 从左下到右上的N型列走线（连续路径）
                                        startX = cellWidth / 2
                                        startY = (heightVal - 1) * cellHeight + cellHeight / 2
                                        ctx.moveTo(startX, startY)

                                        topY = cellHeight / 2
                                        bottomY = (heightVal - 1) * cellHeight + cellHeight / 2

                                        for (i = 0; i < widthVal; i++) {
                                            colX = i * cellWidth + cellWidth / 2
                                            ctx.lineTo(colX, topY)

                                            // N型跨列：顶部斜连到下一列底部
                                            if (i < widthVal - 1) {
                                                nextColX = (i + 1) * cellWidth + cellWidth / 2
                                                ctx.lineTo(nextColX, bottomY)
                                            }
                                        }
                                        break
                                    case "wiring_StartLeftTop_EndRightBottom_N":
                                        // 从左上到右下的N型列走线（连续路径）
                                        startX = cellWidth / 2
                                        startY = cellHeight / 2
                                        ctx.moveTo(startX, startY)

                                        topY = cellHeight / 2
                                        bottomY = (heightVal - 1) * cellHeight + cellHeight / 2

                                        for (i = 0; i < widthVal; i++) {
                                            colX = i * cellWidth + cellWidth / 2
                                            ctx.lineTo(colX, bottomY)

                                            // N型跨列：底部斜连到下一列顶部
                                            if (i < widthVal - 1) {
                                                nextColX = (i + 1) * cellWidth + cellWidth / 2
                                                ctx.lineTo(nextColX, topY)
                                            }
                                        }
                                        break
                                    case "wiring_StartRightBottom_EndLeftTop_N":
                                        // 从右下到左上的N型列走线（连续路径）
                                        startX = (widthVal - 1) * cellWidth + cellWidth / 2
                                        startY = (heightVal - 1) * cellHeight + cellHeight / 2
                                        ctx.moveTo(startX, startY)

                                        topY = cellHeight / 2
                                        bottomY = (heightVal - 1) * cellHeight + cellHeight / 2

                                        for (i = widthVal - 1; i >= 0; i--) {
                                            colX = i * cellWidth + cellWidth / 2
                                            ctx.lineTo(colX, topY)

                                            // N型跨列：顶部斜连到左侧下一列底部
                                            if (i > 0) {
                                                nextColX = (i - 1) * cellWidth + cellWidth / 2
                                                ctx.lineTo(nextColX, bottomY)
                                            }
                                        }
                                        break
                                    case "wiring_StartRightTop_EndLeftBottom_N":
                                        // 从右上到左下的N型列走线（连续路径）
                                        startX = (widthVal - 1) * cellWidth + cellWidth / 2
                                        startY = cellHeight / 2
                                        ctx.moveTo(startX, startY)

                                        topY = cellHeight / 2
                                        bottomY = (heightVal - 1) * cellHeight + cellHeight / 2

                                        for (i = widthVal - 1; i >= 0; i--) {
                                            colX = i * cellWidth + cellWidth / 2
                                            ctx.lineTo(colX, bottomY)

                                            // N型跨列：底部斜连到左侧下一列顶部
                                            if (i > 0) {
                                                nextColX = (i - 1) * cellWidth + cellWidth / 2
                                                ctx.lineTo(nextColX, topY)
                                            }
                                        }
                                        break
                                        // 标准Z型
                                    case "wiring_StartLeftBottom_EndRightTop_Z":
                                        // 从左下到右上的Z型行走线（连续路径）
                                        startX = cellWidth / 2
                                        startY = (heightVal - 1) * cellHeight + cellHeight / 2
                                        ctx.moveTo(startX, startY)

                                        leftX = cellWidth / 2
                                        rightX = (widthVal - 1) * cellWidth + cellWidth / 2

                                        for (j = heightVal - 1; j >= 0; j--) {
                                            rowY = j * cellHeight + cellHeight / 2
                                            var step = (heightVal - 1) - j

                                            // Z型每行保持同方向水平走线
                                            if (step % 2 === 0) {
                                                ctx.lineTo(rightX, rowY)
                                            } else {
                                                ctx.lineTo(leftX, rowY)
                                            }

                                            // 斜连到上一行另一侧，形成连续Z形
                                            if (j > 0) {
                                                nextRowY = (j - 1) * cellHeight + cellHeight / 2
                                                ctx.lineTo((step % 2 === 0) ? leftX : rightX, nextRowY)
                                            }
                                        }

                                        // 保证终点为右上
                                        if (heightVal % 2 === 0) {
                                            ctx.lineTo(rightX, cellHeight / 2)
                                        }
                                        break
                                    case "wiring_StartLeftTop_EndRightBottom_Z":
                                        // 从左上到右下的Z型行走线（连续路径）
                                        startX = cellWidth / 2
                                        startY = cellHeight / 2
                                        ctx.moveTo(startX, startY)

                                        leftX = cellWidth / 2
                                        rightX = (widthVal - 1) * cellWidth + cellWidth / 2

                                        for (j = 0; j < heightVal; j++) {
                                            rowY = j * cellHeight + cellHeight / 2
                                            step = j

                                            if (step % 2 === 0) {
                                                ctx.lineTo(rightX, rowY)
                                            } else {
                                                ctx.lineTo(leftX, rowY)
                                            }

                                            if (j < heightVal - 1) {
                                                nextRowY = (j + 1) * cellHeight + cellHeight / 2
                                                ctx.lineTo((step % 2 === 0) ? leftX : rightX, nextRowY)
                                            }
                                        }

                                        // 保证终点为右下
                                        if (heightVal % 2 === 0) {
                                            ctx.lineTo(rightX, (heightVal - 1) * cellHeight + cellHeight / 2)
                                        }
                                        break
                                    case "wiring_StartRightBottom_EndLeftTop_Z":
                                        // 从右下到左上的Z型行走线（连续路径）
                                        startX = (widthVal - 1) * cellWidth + cellWidth / 2
                                        startY = (heightVal - 1) * cellHeight + cellHeight / 2
                                        ctx.moveTo(startX, startY)

                                        leftX = cellWidth / 2
                                        rightX = (widthVal - 1) * cellWidth + cellWidth / 2

                                        for (j = heightVal - 1; j >= 0; j--) {
                                            rowY = j * cellHeight + cellHeight / 2
                                            step = (heightVal - 1) - j

                                            if (step % 2 === 0) {
                                                ctx.lineTo(leftX, rowY)
                                            } else {
                                                ctx.lineTo(rightX, rowY)
                                            }

                                            if (j > 0) {
                                                nextRowY = (j - 1) * cellHeight + cellHeight / 2
                                                ctx.lineTo((step % 2 === 0) ? rightX : leftX, nextRowY)
                                            }
                                        }

                                        // 保证终点为左上
                                        if (heightVal % 2 === 0) {
                                            ctx.lineTo(leftX, cellHeight / 2)
                                        }
                                        break
                                    case "wiring_StartRightTop_EndLeftBottom_Z":
                                        // 从右上到左下的Z型行走线（连续路径）
                                        startX = (widthVal - 1) * cellWidth + cellWidth / 2
                                        startY = cellHeight / 2
                                        ctx.moveTo(startX, startY)

                                        leftX = cellWidth / 2
                                        rightX = (widthVal - 1) * cellWidth + cellWidth / 2

                                        for (j = 0; j < heightVal; j++) {
                                            rowY = j * cellHeight + cellHeight / 2
                                            step = j

                                            if (step % 2 === 0) {
                                                ctx.lineTo(leftX, rowY)
                                            } else {
                                                ctx.lineTo(rightX, rowY)
                                            }

                                            if (j < heightVal - 1) {
                                                nextRowY = (j + 1) * cellHeight + cellHeight / 2
                                                ctx.lineTo((step % 2 === 0) ? rightX : leftX, nextRowY)
                                            }
                                        }

                                        // 保证终点为左下
                                        if (heightVal % 2 === 0) {
                                            ctx.lineTo(leftX, (heightVal - 1) * cellHeight + cellHeight / 2)
                                        }
                                        break
                                    }


                                    ctx.stroke()
                                    ctx.restore()
                                }
                            }

                            Rectangle {
                                id: pointTooltip
                                visible: false
                                color: "#222222"
                                border.color: "#777777"
                                border.width: 1
                                radius: 3
                                z: 20
                                width: tooltipText.implicitWidth + 10
                                height: tooltipText.implicitHeight + 6

                                Text {
                                    id: tooltipText
                                    anchors.centerIn: parent
                                    color: "#FFFFFF"
                                    font.pixelSize: 11
                                    text: ""
                                }
                            }

                            MouseArea {
                                anchors.fill: wiringCanvas
                                hoverEnabled: true
                                acceptedButtons: Qt.NoButton

                                function hideTooltip() {
                                    pointTooltip.visible = false
                                }

                                function showTooltip(px, py, txt) {
                                    tooltipText.text = txt
                                    pointTooltip.x = Math.min(px + 10, wiringCanvas.width - pointTooltip.width)
                                    pointTooltip.y = Math.max(0, py - pointTooltip.height - 8)
                                    pointTooltip.visible = true
                                }

                                onPositionChanged: function(mouse) {
                                    var points = wiringCanvas.pixelPoints
                                    if (!points || points.length === 0) {
                                        hideTooltip()
                                        return
                                    }

                                    var hitRadius = 6
                                    var nearest = null
                                    var nearestDist2 = hitRadius * hitRadius

                                    for (var idx = 0; idx < points.length; idx++) {
                                        var dx = mouse.x - points[idx].x
                                        var dy = mouse.y - points[idx].y
                                        var dist2 = dx * dx + dy * dy
                                        if (dist2 <= nearestDist2) {
                                            nearestDist2 = dist2
                                            nearest = points[idx]
                                        }
                                    }

                                    if (nearest) {
                                        showTooltip(mouse.x, mouse.y, "X: " + nearest.col + ", Y: " + nearest.row)
                                    } else {
                                        hideTooltip()
                                    }
                                }

                                onExited: hideTooltip()
                            }
                        }
                    }

                }
                // 底部按钮和提示
                ColumnLayout {
                    spacing: 10
                    Layout.fillWidth: true

                    // 主控台数提示
                    Text {
                        id: controllerCountText
                        text: "本方案需要的主控台数为：1"
                        color: "#CCCCCC"
                        font.pixelSize: 12
                        Layout.alignment: Qt.AlignHCenter
                    }

                    // 按钮
                    RowLayout {
                        spacing: 20
                        Layout.alignment: Qt.AlignHCenter

                        Button {
                            id: confirmButton
                            text: "确定"
                            Layout.preferredWidth: 80
                            Layout.preferredHeight: 30

                            background: Rectangle {
                                color: parent.pressed ? "#0066CC" : "#007ACC"
                                border.color: "#0066CC"
                                border.width: 1
                                radius: 3
                            }

                            contentItem: Text {
                                text: parent.text
                                color: "#FFFFFF"
                                font.pixelSize: 12
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }

                            onClicked: {

                                    quickWiringConfirmed({
                                        width: parseInt(widthField.text) || 16,
                                        height: parseInt(heightField.text) || 8,
                                        hSpacing: parseInt(horizontalSpacingField.text) || 0,
                                        vSpacing: parseInt(verticalSpacingField.text) || 0,
                                        direction: currentDirection
                                    })
                                wiringDialog.close()
                                playListModel.addPlayList(0,"",0,0)
                            }
                        }

                        Button {
                            id: cancelButton
                            text: "关闭"
                            Layout.preferredWidth: 80
                            Layout.preferredHeight: 30

                            background: Rectangle {
                                color: parent.pressed ? "#666666" : "#444444"
                                border.color: "#555555"
                                border.width: 1
                                radius: 3
                            }

                            contentItem: Text {
                                text: parent.text
                                color: "#CCCCCC"
                                font.pixelSize: 12
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }

                            onClicked: wiringPopup.close()
                        }
                    }
                }

            }
        }

    }

    // 属性
    property string currentDirection: "right"

    // 函数：更新端口数
    function updatePortCount() {
        var controller = controllerCombo.currentText
        var portCount = 8  // 默认8端口

        // 根据控制器型号设置端口数
        switch(controller) {
        case "SY-418": portCount = 8; break
        case "SY-416": portCount = 6; break
        case "SY-412": portCount = 4; break
        case "SY-408": portCount = 2; break
        }

        portCountText.text = "端口数：" + portCount + "端口"
    }

    // 函数：设置布线方向
    function setWiringDirection(direction) {
        currentDirection = direction

        var normalColor = "#333333"
        var selectedColor = "#007ACC"

        var allButtons = [
                    wiring_StartLeftBottom_EndRightTop_M_Horizontal_Arrow,
                    wiring_StartLeftTop_EndRightBottom_M_Horizontal_Arrow,
                    wiring_StartRightBottom_EndLeftTop_M_Horizontal_Arrow,
                    wiring_StartRightTop_EndLeftBottom_M_Horizontal_Arrow,
                    wiring_StartLeftBottom_EndRightTop_M_Vertical_Button,
                    wiring_StartLeftTop_EndRightBottom_M_Vertical_Arrow,
                    wiring_StartRightBottom_EndLeftTop_M_Vertical_Arrow,
                    wiring_StartRightTop_EndLeftBottom_M_Vertical_Arrow,
                    wiring_StartLeftBottom_EndRightTop_N_Arrow,
                    wiring_StartLeftTop_EndRightBottom_N_Arrow,
                    wiring_StartRightBottom_EndLeftTop_N_Arrow,
                    wiring_StartRightTop_EndLeftBottom_N_Arrow,
                    wiring_StartLeftBottom_EndRightTop_Z_Arrow,
                    wiring_StartLeftTop_EndRightBottom_Z_Arrow,
                    wiring_StartRightBottom_EndLeftTop_Z_Arrow,
                    wiring_StartRightTop_EndLeftBottom_Z_Arrow
                ]

        // 重置所有按钮样式
        for (var i = 0; i < allButtons.length; i++) {
            allButtons[i].background.color = normalColor
        }

        var directionButtonMap = {
            "wiring_StartLeftBottom_EndRightTop_M_Horizontal": wiring_StartLeftBottom_EndRightTop_M_Horizontal_Arrow,
            "wiring_StartLeftTop_EndRightBottom_M_Horizontal": wiring_StartLeftTop_EndRightBottom_M_Horizontal_Arrow,
            "wiring_StartRightBottom_EndLeftTop_M_Horizontal": wiring_StartRightBottom_EndLeftTop_M_Horizontal_Arrow,
            "wiring_StartRightTop_EndLeftBottom_M_Horizontal": wiring_StartRightTop_EndLeftBottom_M_Horizontal_Arrow,
            "wiring_StartLeftBottom_EndRightTop_M_Vertical": wiring_StartLeftBottom_EndRightTop_M_Vertical_Button,
            "wiring_StartLeftTop_EndRightBottom_M_Vertical": wiring_StartLeftTop_EndRightBottom_M_Vertical_Arrow,
            "wiring_StartRightBottom_EndLeftTop_M_Vertical": wiring_StartRightBottom_EndLeftTop_M_Vertical_Arrow,
            "wiring_StartRightTop_EndLeftBottom_M_Vertical": wiring_StartRightTop_EndLeftBottom_M_Vertical_Arrow,
            "wiring_StartLeftBottom_EndRightTop_N": wiring_StartLeftBottom_EndRightTop_N_Arrow,
            "wiring_StartLeftTop_EndRightBottom_N": wiring_StartLeftTop_EndRightBottom_N_Arrow,
            "wiring_StartRightBottom_EndLeftTop_N": wiring_StartRightBottom_EndLeftTop_N_Arrow,
            "wiring_StartRightTop_EndLeftBottom_N": wiring_StartRightTop_EndLeftBottom_N_Arrow,
            "wiring_StartLeftBottom_EndRightTop_Z": wiring_StartLeftBottom_EndRightTop_Z_Arrow,
            "wiring_StartLeftTop_EndRightBottom_Z": wiring_StartLeftTop_EndRightBottom_Z_Arrow,
            "wiring_StartRightBottom_EndLeftTop_Z": wiring_StartRightBottom_EndLeftTop_Z_Arrow,
            "wiring_StartRightTop_EndLeftBottom_Z": wiring_StartRightTop_EndLeftBottom_Z_Arrow
        }

        var directionDescMap = {
            "wiring_StartLeftBottom_EndRightTop_M_Horizontal": "当前方向：左下→右上（M-水平）",
            "wiring_StartLeftTop_EndRightBottom_M_Horizontal": "当前方向：左上→右下（M-水平）",
            "wiring_StartRightBottom_EndLeftTop_M_Horizontal": "当前方向：右下→左上（M-水平）",
            "wiring_StartRightTop_EndLeftBottom_M_Horizontal": "当前方向：右上→左下（M-水平）",
            "wiring_StartLeftBottom_EndRightTop_M_Vertical": "当前方向：左下→右上（M-垂直）",
            "wiring_StartLeftTop_EndRightBottom_M_Vertical": "当前方向：左上→右下（M-垂直）",
            "wiring_StartRightBottom_EndLeftTop_M_Vertical": "当前方向：右下→左上（M-垂直）",
            "wiring_StartRightTop_EndLeftBottom_M_Vertical": "当前方向：右上→左下（M-垂直）",
            "wiring_StartLeftBottom_EndRightTop_N": "当前方向：左下→右上（N型）",
            "wiring_StartLeftTop_EndRightBottom_N": "当前方向：左上→右下（N型）",
            "wiring_StartRightBottom_EndLeftTop_N": "当前方向：右下→左上（N型）",
            "wiring_StartRightTop_EndLeftBottom_N": "当前方向：右上→左下（N型）",
            "wiring_StartLeftBottom_EndRightTop_Z": "当前方向：左下→右上（Z型）",
            "wiring_StartLeftTop_EndRightBottom_Z": "当前方向：左上→右下（Z型）",
            "wiring_StartRightBottom_EndLeftTop_Z": "当前方向：右下→左上（Z型）",
            "wiring_StartRightTop_EndLeftBottom_Z": "当前方向：右上→左下（Z型）"
        }

        // 设置选中按钮样式
        if (directionButtonMap[direction]) {
            directionButtonMap[direction].background.color = selectedColor
        }

        if (directionDescMap[direction]) {
            directionText.text = directionDescMap[direction]
        } else {
            directionText.text = "当前方向：未定义"
        }

        updateWiringPreview(direction)
    }

    // 函数：更新布线预览
    function updateWiringPreview(direction ) {
        if (direction !== undefined && direction !== null && direction !== "") {
            wiringCanvas.direction = direction
        }
        wiringCanvas.requestPaint()

        // 计算所需主控台数
        var widthVal = parseInt(widthField.text) || 0
        var heightVal = parseInt(heightField.text) || 0
        var totalPixels = widthVal * heightVal
        var controllerCount = 1

        if (totalPixels > 1024) {
            controllerCount = Math.ceil(totalPixels / 1024)
        }

        controllerCountText.text = "本方案需要的主控台数为：" + controllerCount
    }

    // 初始化
    Component.onCompleted: {
        updatePortCount()
        setWiringDirection("wiring_StartLeftBottom_EndRightTop_M_Horizontal")
    }

    // 显示时居中显示
    onVisibleChanged: {
        if (visible) {
            // 在父窗口居中显示
            var parentWindow = wiringDialog.parent
            if (parentWindow) {
                wiringDialog.x = (parentWindow.width - width) / 2
                wiringDialog.y = (parentWindow.height - height) / 2
            }
        }
    }
}