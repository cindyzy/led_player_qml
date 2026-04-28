// SkinConstants.js
// 皮肤常量
const SkinType = {
    DEFAULT: "Default",
    DARK: "Dark",
    BLUE: "Blue"
}

// 可用的皮肤列表
const AvailableSkins = [
    SkinType.DEFAULT,
    SkinType.DARK,
    SkinType.BLUE
]

// 皮肤颜色定义
const Colors = {
    [SkinType.DEFAULT]: {
        primary: "#2196F3",
        primaryDark: "#1976D2",
        secondary: "#FF9800",
        background: "#F5F5F5",
        backgroundSecondary: "#E0E0E0",
        text: "#212121",
        textSecondary: "#757575",
        border: "#BDBDBD",
        borderLight: "#E0E0E0",
        switchTrack: "#444444",
        switchThumb: "#FFFFFF",
        switchThumbBorder: "#CCCCCC"
    },
    [SkinType.DARK]: {
        primary: "#BB86FC",
        primaryDark: "#9C27B0",
        secondary: "#03DAC6",
        background: "#121212",
        backgroundSecondary: "#1E1E1E",
        text: "#FFFFFF",
        textSecondary: "#B0B0B0",
        border: "#424242",
        borderLight: "#616161",
        switchTrack: "#333333",
        switchThumb: "#FFFFFF",
        switchThumbBorder: "#CCCCCC"
    },
    [SkinType.BLUE]: {
        primary: "#1976D2",
        primaryDark: "#0D47A1",
        secondary: "#4CAF50",
        background: "#E3F2FD",
        backgroundSecondary: "#BBDEFB",
        text: "#0D47A1",
        textSecondary: "#1976D2",
        border: "#90CAF9",
        borderLight: "#BBDEFB",
        switchTrack: "#BBDEFB",
        switchThumb: "#FFFFFF",
        switchThumbBorder: "#90CAF9"
    }
}

// 字体定义
const Fonts = {
    small: Qt.font({ pixelSize: 10 }),
    normal: Qt.font({ pixelSize: 12 }),
    large: Qt.font({ pixelSize: 16 }),
    title: Qt.font({ pixelSize: 20, bold: true })
}

// 尺寸定义
const Sizes = {
    radius: 4,
    switchRadius: 10,
    switchThumbRadius: 8
}

// 导出
function getSkin(skinName) {
    return {
        name: skinName,
        colors: Colors[skinName] || Colors[SkinType.DEFAULT],
        fonts: Fonts,
        sizes: Sizes
    }
}