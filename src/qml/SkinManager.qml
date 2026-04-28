// SkinManager.qml - 皮肤管理器
pragma Singleton
import QtQuick 2.15
import Qt.labs.settings 1.1

QtObject {
    id: skinManager

    readonly property string default_skin: "Default"
    readonly property string dark_skin: "Dark"
    readonly property string blue_skin: "Blue"

    // 当前皮肤
    property var currentSkin: null

    // 可用皮肤列表
    property var availableSkins: []

    // 皮肤变更信号
    signal skinChanged(string skinName)

    // 设置存储 —— 以属性的方式声明
    property Settings skinSettings: Settings {
        id: settingsObj
        category: "Skin"
        property string currentSkinName: "Default"
    }

    // 初始化
    Component.onCompleted: {
        loadAvailableSkins()
        var skinName = skinSettings.currentSkinName || default_skin
        loadSkin(skinName)
    }

    // 加载可用皮肤
    function loadAvailableSkins() {
        var components = [
            { name: "Default", path: "skins/Default/Skin.qml" },
            { name: "Dark",    path: "skins/Dark/Skin.qml" },
            { name: "Blue",    path: "skins/Blue/Skin.qml" }
        ]
        // components.forEach(function(c) {
        //     var comp = Qt.createComponent(c.path)
        //     if (comp.status === Component.completed()) {
        //         finishLoad(comp, c.name)
        //     } else if (comp.status === Component.Loading) {
        //         comp.statusChanged.connect(function() {
        //             if (comp.status === Component.Ready)
        //                 finishLoad(comp, c.name)
        //             else if (comp.status === Component.Error)
        //                 console.error("Failed to load", c.path, comp.errorString())
        //         })
        //     } else {
        //         console.error("Failed to load", c.path, comp.errorString())
        //     }
        // })
    }

    function finishLoad(comp, name) {
        var skinObj = comp.createObject(skinManager)
        skinObj.name = name   // 确保 name 属性存在
        availableSkins.push(skinObj)
    }
    // 切换皮肤
    function switchSkin(skinName) {
        var skinComponent = null

  for (var i = 0; i < availableSkins.length; i++) {
            if (availableSkins[i].name === skinName) {
                skinComponent = availableSkins[i]
                break
            }
        }

        if (!skinComponent) {
            console.warn("Skin not found:", skinName)
            return false
        }

        currentSkin = skinComponent
        skinSettings.currentSkinName = skinName   // 修改此处：settings -> skinSettings
        skinChanged(skinName)
        return true
    }

    // 加载皮肤
    function loadSkin(skinName) {
        if (!switchSkin(skinName)) {
            console.warn("Failed to load skin, using default")
            switchSkin(default_skin)
        }
    }

    // 获取皮肤颜色
    function getColor(colorName) {
        if (currentSkin && currentSkin.colors && currentSkin.colors[colorName]) {
            return currentSkin.colors[colorName]
        }
        return "#000000"
    }

    // 获取字体
    function getFont(fontName) {
        if (currentSkin && currentSkin.fonts && currentSkin.fonts[fontName]) {
            return currentSkin.fonts[fontName]
        }
        return Qt.font({ pixelSize: 12 })
    }

    // 获取尺寸
    function getSize(sizeName) {
        if (currentSkin && currentSkin.sizes && currentSkin.sizes[sizeName]) {
            return currentSkin.sizes[sizeName]
        }
        return 0
    }
}