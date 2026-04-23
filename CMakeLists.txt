cmake_minimum_required(VERSION 3.16)

project(untitled VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Quick)

qt_standard_project_setup(REQUIRES 6.10)

qt_add_executable(appuntitled
    main.cpp
)

qt_add_qml_module(appuntitled
    URI untitled
    QML_FILES
        Main.qml
        QML_FILES Main.qml
        QML_FILES ThemeManager.qml
        QML_FILES MainLayout.qml
        QML_FILES ThemeManager.qml
        QML_FILES components/MenuButton.qml components/PropertyField.qml components/PropertyGroup.qml components/SettingGroup.qml components/TreeItem.qml components/WiringButton.qml dialogs/HardwareSettingsDialog.qml dialogs/NewProjectDialog.qml dialogs/NewWiringDialog.qml views/MenuBarArea.qml views/PlaybackControlBar.qml views/PlaylistPanel.qml views/PropertyPanel.qml views/StatusBarArea.qml views/VideoPreviewArea.qml
        QML_FILES dialogs/QuickWiringDialog.qml
        QML_FILES components/ImgButton.qml
        QML_FILES dialogs/AnimationEditorDialog.qml
        QML_FILES components/ColorSwatch.qml
        QML_FILES components/ColorSwatch.qml
        QML_FILES components/GradientSwatch.qml
        QML_FILES components/TimeLineControl.qml
)

# Qt for iOS sets MACOSX_BUNDLE_GUI_IDENTIFIER automatically since Qt 6.1.
# If you are developing for iOS or macOS you should consider setting an
# explicit, fixed bundle identifier manually though.
set_target_properties(appuntitled PROPERTIES
#    MACOSX_BUNDLE_GUI_IDENTIFIER com.example.appuntitled
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

target_link_libraries(appuntitled
    PRIVATE Qt6::Quick
)
target_compile_definitions(appuntitled PRIVATE QT_QML_DEBUG)
install(TARGETS appuntitled
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
