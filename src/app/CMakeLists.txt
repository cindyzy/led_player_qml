# 创建可执行目标
add_executable(${PROJECT_NAME})

# 添加源代码
target_sources(${PROJECT_NAME} PRIVATE main.cpp)

# 链接Qt6库
target_link_libraries(${PROJECT_NAME} PRIVATE
    Qt6::Core
    Qt6::Quick
    Qt6::QuickControls2
)

# 将构建目录添加到QML导入路径，以便运行时能找到我们的QML模块
set_target_properties(${PROJECT_NAME} PROPERTIES
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)