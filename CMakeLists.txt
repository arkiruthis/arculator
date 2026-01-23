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

# Compiler flags based on CMAKE_BUILD_TYPE
if(CMAKE_BUILD_TYPE STREQUAL "Debug")
    add_compile_definitions(_DEBUG DEBUG_LOG)
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Wall -O0 -g")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wall -O0 -g")
else()
    # Release builds (Release, RelWithDebInfo, MinSizeRel)
    add_compile_definitions(RELEASE_BUILD)
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


# Platform detection
if(APPLE)
    set(OS_MACOSX TRUE)
    add_compile_definitions(OS_MACOSX)
    enable_language(OBJC)
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

# RPATH configuration for Linux/macOS so executables find shared libs in ./lib
if(OS_LINUX OR OS_MACOSX)
    # Use $ORIGIN (Linux) or @executable_path (macOS) to find libs relative to executable
    # Include both $ORIGIN/lib (for executable) and $ORIGIN (for libs in lib/ to find each other)
    set(CMAKE_INSTALL_RPATH "$ORIGIN/lib;$ORIGIN")
    if(OS_MACOSX)
        set(CMAKE_INSTALL_RPATH "@executable_path/lib;@loader_path")
    endif()
    # Don't use the build tree RPATH for installed binaries
    set(CMAKE_BUILD_WITH_INSTALL_RPATH OFF)
    set(CMAKE_INSTALL_RPATH_USE_LINK_PATH OFF)
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

# Include CPM for dependency management
include(cmake/get_cpm.cmake)

# Include dependencies (uses CPMAddPackage)
include(cmake/dependencies.cmake)

# Find system libraries
find_package(Threads REQUIRED)

if(OS_LINUX OR OS_OTHER)
    find_package(X11 REQUIRED)
endif()

if(OS_LINUX)
    find_package(ALSA)
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
message(STATUS "Platform: ${CMAKE_SYSTEM_NAME}")
message(STATUS "Compiler: ${CMAKE_C_COMPILER_ID} ${CMAKE_C_COMPILER_VERSION}")
message(STATUS "")

# Install data directories
install(DIRECTORY roms/
    DESTINATION roms
    PATTERN ".git" EXCLUDE
)

install(DIRECTORY hostfs/
    DESTINATION hostfs
    PATTERN ".git" EXCLUDE
)

install(DIRECTORY cmos/
    DESTINATION cmos
    PATTERN ".git" EXCLUDE
)

install(DIRECTORY ddnoise/
    DESTINATION ddnoise
    PATTERN ".git" EXCLUDE
)

install(DIRECTORY configs/
    DESTINATION configs
    PATTERN ".git" EXCLUDE
)
