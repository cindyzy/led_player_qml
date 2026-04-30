cmake_minimum_required(VERSION 3.16)

project(DMX512Demo VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Quick)

qt_standard_project_setup(REQUIRES 6.10)

qt_add_executable(appDMX512Demo
    Main.cpp
)


# 添加 QML 资源文件
qt_add_qml_module(appDMX512Demo
    URI DMX512Demo
    QML_FILES
        Main.qml
    SOURCES dmxcontroller.h dmxcontroller.cpp
    SOURCES UdpManager.h UdpManager.cpp
    QML_FILES main.qml
    RESOURCES qml.qrc
)

# qt_add_resources(appDMX512Demo "qml"
#     FILES qml.qrc
# )

# Qt for iOS sets MACOSX_BUNDLE_GUI_IDENTIFIER automatically since Qt 6.1.
# If you are developing for iOS or macOS you should consider setting an
# explicit, fixed bundle identifier manually though.
set_target_properties(appDMX512Demo PROPERTIES
#    MACOSX_BUNDLE_GUI_IDENTIFIER com.example.appDMX512Demo
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

target_link_libraries(appDMX512Demo
    PRIVATE Qt6::Quick
)

install(TARGETS appDMX512Demo
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
