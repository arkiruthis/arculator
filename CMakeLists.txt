# CMakeLists.txt for Arculator
# Acorn Archimedes Emulator

cmake_minimum_required(VERSION 3.20)
project(arculator VERSION 2.2 LANGUAGES C CXX)

set(CMAKE_C_STANDARD 11)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Export compile commands for IDE support
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

# Set default build type
if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE Release CACHE STRING "Build type" FORCE)
endif()

# Options
option(ARCULATOR_BUILD_PODULES "Build podule plugins" ON)
option(ARCULATOR_ENABLE_DEBUG "Enable debug build" OFF)
option(ARCULATOR_RELEASE_BUILD "Build for release" OFF)

# Compiler flags based on options
if(ARCULATOR_ENABLE_DEBUG)
    add_compile_definitions(_DEBUG DEBUG_LOG)
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Wall -O0 -g")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wall -O0 -g")
else()
    set(CMAKE_C_FLAGS_RELEASE "${CMAKE_C_FLAGS_RELEASE} -O3")
    set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} -O3")
endif()

# Disable treating warnings as errors (matches original automake behavior)
# Modern Clang versions treat some warnings as errors by default
if(CMAKE_C_COMPILER_ID MATCHES "Clang|GNU")
    add_compile_options(
        $<$<COMPILE_LANGUAGE:C>:-Wno-error>
        $<$<COMPILE_LANGUAGE:C>:-Wno-deprecated-non-prototype>
        $<$<COMPILE_LANGUAGE:C>:-Wno-incompatible-pointer-types>
        $<$<COMPILE_LANGUAGE:C>:-Wno-knr-promoted-parameter>
        $<$<COMPILE_LANGUAGE:C>:-Wno-tautological-constant-out-of-range-compare>
        $<$<COMPILE_LANGUAGE:C>:-Wno-int-conversion>
        $<$<COMPILE_LANGUAGE:C>:-Wno-implicit-function-declaration>
        $<$<COMPILE_LANGUAGE:C>:-Wno-implicit-int>
    )
endif()

if(CMAKE_CXX_COMPILER_ID MATCHES "Clang|GNU")
    add_compile_options($<$<COMPILE_LANGUAGE:CXX>:-Wno-error>)
endif()

# MSVC specific flags
if(MSVC)
    add_compile_options(/W3 /WX-)
endif()

if(ARCULATOR_RELEASE_BUILD)
    add_compile_definitions(RELEASE_BUILD)
endif()

# Platform detection
if(APPLE)
    set(OS_MACOSX TRUE)
    add_compile_definitions(OS_MACOSX)
elseif(WIN32)
    set(OS_WINDOWS TRUE)
    add_compile_definitions(OS_WINDOWS)
elseif(UNIX)
    set(OS_LINUX TRUE)
    add_compile_definitions(OS_LINUX)
else()
    set(OS_OTHER TRUE)
    add_compile_definitions(OS_OTHER)
endif()

# Set output directories
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)

# Multi-config output directories
foreach(CONFIG_TYPE ${CMAKE_CONFIGURATION_TYPES})
    string(TOUPPER ${CONFIG_TYPE} CONFIG_TYPE_UPPER)
    set(CMAKE_RUNTIME_OUTPUT_DIRECTORY_${CONFIG_TYPE_UPPER} ${CMAKE_BINARY_DIR}/bin)
    set(CMAKE_LIBRARY_OUTPUT_DIRECTORY_${CONFIG_TYPE_UPPER} ${CMAKE_BINARY_DIR}/lib)
    set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY_${CONFIG_TYPE_UPPER} ${CMAKE_BINARY_DIR}/lib)
endforeach()

# Include FetchContent for dependency management
include(FetchContent)
set(FETCHCONTENT_QUIET OFF)

# Include dependency modules
include(deps/zlib.cmake)
include(deps/sdl2.cmake)
include(deps/wxwidgets.cmake)

# Find system libraries
find_package(Threads REQUIRED)

if(OS_LINUX)
    find_package(ALSA)
    find_package(X11 REQUIRED)
endif()

if(OS_MACOSX)
    find_package(X11)
    if(NOT X11_FOUND)
        # Try XQuartz location
        find_path(X11_INCLUDE_DIR X11/Xlib.h
            PATHS /opt/X11/include
        )
        find_library(X11_LIBRARY X11
            PATHS /opt/X11/lib
        )
        if(X11_INCLUDE_DIR AND X11_LIBRARY)
            set(X11_FOUND TRUE)
            set(X11_LIBRARIES ${X11_LIBRARY})
            set(X11_INCLUDE_DIRS ${X11_INCLUDE_DIR})
        endif()
    endif()
endif()

# Add subdirectories
add_subdirectory(src)

if(ARCULATOR_BUILD_PODULES)
    add_subdirectory(podules)
endif()

# Print configuration summary
message(STATUS "")
message(STATUS "=== Arculator Build Configuration ===")
message(STATUS "Version: ${PROJECT_VERSION}")
message(STATUS "Build type: ${CMAKE_BUILD_TYPE}")
message(STATUS "Build podules: ${ARCULATOR_BUILD_PODULES}")
message(STATUS "Debug mode: ${ARCULATOR_ENABLE_DEBUG}")
message(STATUS "Release build: ${ARCULATOR_RELEASE_BUILD}")
message(STATUS "Platform: ${CMAKE_SYSTEM_NAME}")
message(STATUS "Compiler: ${CMAKE_C_COMPILER_ID} ${CMAKE_C_COMPILER_VERSION}")
message(STATUS "")

