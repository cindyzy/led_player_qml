# 将QML文件添加为资源
qt_add_qml_module(qml
    URI QmlModule
    VERSION 1.0
    RESOURCE_PREFIX "/QmlModule"
    QML_FILES
        Main.qml
    DEPENDENCIES
        Qt6::Quick
        Qt6::QuickControls2
)

# 将生成的QML模块链接到主可执行文件
target_link_libraries(ledplayer PRIVATE qml)