cmake_minimum_required(VERSION 3.16)
project(LedPlayer VERSION 1.0.0 LANGUAGES CXX)

# 设置C++标准
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# 设置Qt相关自动处理
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

# 查找Qt6组件
find_package(Qt6 REQUIRED COMPONENTS Core Quick QuickControls2)

# 设置输出目录
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)

# 添加可执行目标
add_executable(LedPlayer
    src/utils/charbitmapgenerator.h
    src/utils/charbitmapgenerator.cpp
    src/utils/FileHandler.h)

# 设置目标属性
set_target_properties(LedPlayer PROPERTIES
    WIN32_EXECUTABLE TRUE
    MACOSX_BUNDLE TRUE
)

# 设置目标源文件
target_sources(LedPlayer PRIVATE
    src/app/main.cpp
    src/qml/qml.qrc

)

# 链接Qt库
target_link_libraries(LedPlayer PRIVATE
    Qt6::Core
    Qt6::Quick
    Qt6::QuickControls2
)

# 设置安装目标
install(TARGETS LedPlayer
    RUNTIME DESTINATION bin
    BUNDLE DESTINATION .
    LIBRARY DESTINATION lib
)
# add_subdirectory(examples/DMX512Demo)
