cmake_minimum_required(VERSION 3.16)
project(TestQt VERSION 1.0.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

find_package(Qt6 REQUIRED COMPONENTS Core Quick QuickControls2)

add_executable(TestQt ../test_simple.cpp)

target_link_libraries(TestQt PRIVATE
    Qt6::Core
    Qt6::Quick
    Qt6::QuickControls2
)

set_target_properties(TestQt PROPERTIES
    WIN32_EXECUTABLE TRUE
)