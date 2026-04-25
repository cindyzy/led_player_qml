// MenuBarArea.qml
import QtQuick
import QtQuick.Controls
// import QtQuick.Layouts
import QtQuick.Controls.Material
import QtQuick.Dialogs
MenuBar {
    id: menuBar

    background: Rectangle {
        color: "#252526"
    }

    delegate: MenuBarItem {
        id: menuBarItem
        implicitWidth: 60
        implicitHeight: 30

        contentItem: Text {
            text: menuBarItem.text
            color: menuBarItem.highlighted ? "#FFFFFF" : "#CCCCCC"
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            font.pixelSize: 12
        }

        background: Rectangle {
            color: menuBarItem.highlighted ? "#094771" : "transparent"
            border.color: menuBarItem.highlighted ? "#3E3E3E" : "transparent"
        }
    }

    // 1. 项目菜单
    Menu {
        title: qsTr("项目")

        Action {
            text: qsTr("新建项目")
            shortcut: "Ctrl+N"
            onTriggered:


            {

                newProjectDialog.show()

            }
        }
        Action {
            text: qsTr("保存项目")
            shortcut: "Ctrl+S"
            onTriggered:

            {
                console.log("保存项目")
                if (parent && parent.parent && parent.parent.saveProject) {
                    parent.parent.saveProject()
                } else {
                    console.error("无法访问saveProject函数")
                }
            }
        }
        Menu {
            title: qsTr("打开项目")

            Action {
                text: qsTr("项目文件(.sproj)")
                onTriggered:
                {
                    // 打开文件选择对话框
                    fileOpenDialog.open()
                }
            }

            Action {
                text: qsTr("项目文件夹")
                onTriggered: console.log("导入项目文件夹")
            }
        }

        Menu {
            title: qsTr("最近打开")
            // 这里可以动态添加最近打开的项目
            Action { text: qsTr("示例项目1"); onTriggered: console.log("打开示例项目1") }
            Action { text: qsTr("示例项目2"); onTriggered: console.log("打开示例项目2") }
        }

        MenuSeparator {}

        Action {
            text: qsTr("打开项目所在文件夹")
            onTriggered: console.log("打开项目所在文件夹")
        }

        MenuSeparator {}

        Action {
            text: qsTr("项目设置")
            onTriggered: console.log("项目设置")
        }

        MenuSeparator {}

        Action {
            text: qsTr("退出")
            shortcut: "Alt+F4"
            onTriggered: Qt.quit()
        }
    }

    // 2. 素材菜单
    Menu {
        title: qsTr("素材")

        Action { text: "送样效果" }
        Action { text: "测试效果" }
        Menu {
            id: innerEffectSubmenu
            title: "内置效果"

            Action { text: "内置效果1" }
            Action { text: "内置效果2" }
            Action { text: "四通道内置效果1 (W)" }
            Action { text: "四通道内置效果2 (RGBW)" }
            Action { text: "横向轮廓效果1" }
            Action { text: "横向轮廓效果2" }
            Action { text: "竖向轮廓效果" }
        }
        Action { text: "高级特效" }
        Action { text: "屏幕录制" }
        Action { text: "炫彩文字" }
        Action { text: "图片展示" }
        Action { text: "Flash录制" }
        Action { text: "视频文件" }
        Menu { title: "音控"
            Action { text: "动感音柱" }
            Action { text: "动感图案" }
            Action { text: "内置频谱" }
        }
        Action { text: "旋转文字" }
        Action { text: "实时时钟" }
    }

    // 3. 布线菜单
    Menu {
        title: qsTr("布线")

        Action {
            text: qsTr("新建布线图")
            onTriggered: console.log("新建布线图")
        }

        Action {
            text: qsTr("快速布线")
            onTriggered: quickWiringDialog.open()
        }

        MenuSeparator {}

        Action {
            text: qsTr("导入布线图")
            onTriggered: console.log("导入布线图")
        }

        Action {
            text: qsTr("导入DXF")
            onTriggered: console.log("导入DXF")
        }

        Action {
            text: qsTr("导入表格（POS）")
            onTriggered: console.log("导入表格（POS）")
        }

        MenuSeparator {}
        Action {
            text: qsTr("编辑布线图")
            onTriggered: console.log("编辑布线图")
        }

    }

    // 4. 设置菜单
    Menu {
        title: qsTr("设置")

        // 硬件设置
        Action {
            text: qsTr("硬件设置")
        }

        // 软件设置
        Action {
            text: qsTr("软件设置")
        }
        Action { text: qsTr("控制器高级设置"); }
        Action { text: qsTr("单路/单点调整参数");  }
        Action { text: qsTr("芯片参数设置");  }



        // 启动播放子菜单
        Menu {
            title: qsTr("启动播放")
            Action { text: qsTr("启动Windows时自动"); onTriggered: console.log("启动Windows时自动") }
            Action { text: qsTr("播放器状态检测"); onTriggered: console.log("播放器状态检测") }
            Action { text: qsTr("启动最小化窗口"); onTriggered: console.log("启动最小化窗口") }
            Action { text: qsTr("U盘换文件"); onTriggered: console.log("U盘换文件") }
            Action { text: qsTr("正常启动"); onTriggered: console.log("正常启动") }
            Action { text: qsTr("自动播放"); onTriggered: console.log("自动播放") }
            Action { text: qsTr("实时桌面播放"); onTriggered: console.log("实时桌面播放") }
        }
        Action { text: qsTr("启动播放");}
        Action { text: qsTr("同步设置");  }
        Action { text: qsTr("节目颜色调整");  }
        Action { text: qsTr("整体颜色调整");  }
        Action { text: qsTr("视频采集");  }
        Action { text: qsTr("实时亮度设置");  }
        Action { text: qsTr("项目加密");  }
        Menu { title: qsTr("语言")
            Action { text: qsTr("简体中文"); onTriggered: console.log("正常启动") }
            Action { text: qsTr("繁体中文"); onTriggered: console.log("自动播放") }
            Action { text: qsTr("英文"); onTriggered: console.log("实时桌面播放") }


        }

    }

    // 5. 输出菜单
    Menu {
        title: qsTr("输出")



        Action {
            text: qsTr("SD文件")
            onTriggered: console.log("输出到SD文件")
        }

        Action {
            text: qsTr("MP文件")
            onTriggered: console.log("输出到MP文件")
        }

        Action {
            text: qsTr("视频文件")
            onTriggered: console.log("输出到视频文件")
        }

        Action {
            text: qsTr("拷卡")
            onTriggered: console.log("拷卡")
        }

        Action {
            text: qsTr("布线图")
            onTriggered: console.log("输出布线图")
        }

        Action {
            text: qsTr("布灯图")
            onTriggered: console.log("输出布灯图")
        }
    }

    // 6. 调试菜单
    Menu {
        title: qsTr("调试")

        Action {
            text: qsTr("一键写码")
            onTriggered: console.log("输出到SD文件")
        }

        Action {
            text: qsTr("状态检测")
            onTriggered: console.log("输出到MP文件")
        }
    }

    // 7. 外部控制菜单
    Menu {
        title: qsTr("外部控制")

        Action {
            text: qsTr("DMX控制")
            onTriggered: console.log("DMX512控制")
        }

        Action {
            text: qsTr("UDP控制")
            onTriggered: console.log("ArtNet控制")
        }

        Action {
            text: qsTr("云控")
            onTriggered: console.log("网络控制")
        }
    }

    // 8. RDM菜单
    Menu {
        title: qsTr("RDM")

        Action {
            text: qsTr("RDM")
            onTriggered: console.log("设备发现")
        }


    }

    // 9. 工具菜单
    Menu {
        title: qsTr("工具")

        // 尺寸转换
        Action {
            text: qsTr("尺寸转换")
        }

        // 格式转换
        Action {
            text: qsTr("格式转换")
        }

        // 颜色转换
        Action {
            text: qsTr("颜色转换")
        }

        // 视频转换
        Action {
            text: qsTr("视频转换")
        }

        // 节目转换
        Action {
            text: qsTr("节目转换")
        }

        MenuSeparator {}

        Action {
            text: qsTr("计算器")
            onTriggered: { // 跨平台调用系统计算器
                if (Qt.platform.os === "windows") {
                    // Windows系统
                    Qt.openUrlExternally("calc.exe");
                } else if (Qt.platform.os === "osx") {
                    // macOS系统
                    Qt.openUrlExternally("open -a Calculator");
                } else if (Qt.platform.os === "linux") {
                    // Linux系统 - 尝试多种计算器应用
                    if (launchCommand("gnome-calculator --version")) {
                        launchCommand("gnome-calculator");
                    } else if (launchCommand("kcalc --version")) {
                        launchCommand("kcalc");
                    } else if (launchCommand("xcalc -version")) {
                        launchCommand("xcalc");
                    } else {
                        console.log("未找到可用的计算器应用程序");
                    }
                } else {
                    console.log("未知操作系统，无法调用计算器");
                }
            }
        }

        Action {
            text: qsTr("记事本")
            onTriggered: {
                console.log("正在打开系统记事本...");

                // 跨平台调用系统记事本
                if (Qt.platform.os === "windows") {
                    // Windows系统
                    Qt.openUrlExternally("notepad.exe");
                } else if (Qt.platform.os === "osx") {
                    // macOS系统
                    Qt.openUrlExternally("TextEdit");
                } else if (Qt.platform.os === "linux") {
                    // Linux系统
                    Qt.openUrlExternally("gedit");
                } else {
                    console.log("未知操作系统，无法调用记事本");
                }
            }
        }

        Action {
            text: qsTr("画图")
            onTriggered: {
                console.log("正在打开系统画图工具...");

                // 跨平台调用系统画图工具
                if (Qt.platform.os === "windows") {
                    // Windows系统
                    Qt.openUrlExternally("mspaint.exe");
                } else if (Qt.platform.os === "osx") {
                    // macOS系统
                    Qt.openUrlExternally("Preview");
                } else if (Qt.platform.os === "linux") {
                    // Linux系统
                    Qt.openUrlExternally("gimp");
                } else {
                    console.log("未知操作系统，无法调用画图工具");
                }
            }
        }

        MenuSeparator {}
        Action {
            text: qsTr("分控固件升级")
            onTriggered: console.log("RDM工具")
        }
        Action {
            text: qsTr("BL参数配置")
            onTriggered: console.log("RDM工具")
        }
        Action {
            text: qsTr("Artnet工具")
            onTriggered: console.log("Artnet工具")
        }
    }

    // 10. 帮助菜单
    Menu {
        title: qsTr("帮助")

        Action {
            text: qsTr("用户手册")
            shortcut: "F1"
            onTriggered: console.log("用户手册")
        }

        Action {
            text: qsTr("在线教程")
            onTriggered: console.log("在线教程")
        }

        Action {
            text: qsTr("关于 LED Player")
            onTriggered: console.log("关于 LED Player")
        }

        MenuSeparator {}

        Action {
            text: qsTr("软件许可")
            onTriggered: console.log("软件许可")
        }

        Action {
            text: qsTr("软件升级")
            onTriggered: console.log("软件升级")
        }

        Action {
            text: qsTr("帮助文件")
            onTriggered: console.log("帮助文件")
        }

        Action {
            text: qsTr("恢复默认界面")
            onTriggered: console.log("恢复默认界面")
        }

        MenuSeparator {}

        Action {
            id: professionalEdition
            text: qsTr("专业版")
            checkable: true
            checked: true
            onTriggered: console.log("专业版: " + checked)
        }

        Action {
            id: standardEdition
            text: qsTr("标准版")
            checkable: true
            checked: false
            onTriggered: console.log("标准版: " + checked)
        }
    }
    
    // 文件打开对话框
    FileDialog {
        id: fileOpenDialog
        title: "打开项目文件"
        nameFilters: ["项目文件 (*.sproj)", "所有文件 (*.*)"]
        currentFolder: Qt.application.dataPath + "/projects/"
        onAccepted: {
            // 直接使用 selectedFile，它返回字符串路径（可能是 file:// 格式或本地路径）
            var rawPath = fileOpenDialog.selectedFile
            console.log("原始路径:", rawPath)

            // 转换为可靠的本地文件路径（去掉 file:// 前缀，如果有）
            var localPath = rawPath.toString()
            if (localPath.startsWith("file://")) {
                localPath = localPath.substring(7)  // 去掉 "file://"
                // Windows 下路径可能形如 /C:/...，需要去掉开头的斜杠
                if (localPath.match(/^\/[A-Za-z]:/)) {
                    localPath = localPath.substring(1)
                }
            }
            console.log("本地路径:", localPath)

            // var filePath = fileOpenDialog.selectedFile
            // console.log("选择的项目文件:", filePath)
            // 调用MainLayout的loadProject函数
            // parent是MenuBar, parent.parent是MainLayout
            if (parent && parent.parent && parent.parent.loadProject) {
                parent.parent.loadProject(localPath)
            } else {
                console.error("无法访问loadProject函数, parent:", parent, "parent.parent:", parent.parent)
            }
        }
        onRejected: {
            console.log("取消打开项目文件")
        }
    }
}
