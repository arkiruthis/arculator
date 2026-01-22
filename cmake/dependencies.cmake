# cmake/dependencies.cmake - Dependency management using CPM
#
# All dependencies are fetched and built from source via CPM for reproducible builds.
# This ensures consistent versions across all build environments.

# --- zlib ---
message(STATUS "Adding zlib via CPM...")
CPMAddPackage(
    NAME zlib
    GITHUB_REPOSITORY madler/zlib
    GIT_TAG v1.3.1
    OPTIONS
        "ZLIB_BUILD_EXAMPLES OFF"
        "SKIP_INSTALL_ALL ON"
)

# Create alias target for consistency
if(NOT TARGET ZLIB::ZLIB)
    add_library(ZLIB::ZLIB ALIAS zlibstatic)
endif()

set(ZLIB_INCLUDE_DIRS ${zlib_SOURCE_DIR} ${zlib_BINARY_DIR})
set(ZLIB_LIBRARIES zlibstatic)

# Install zlib DLL if it was built as a shared library (Windows)
if(TARGET zlib AND OS_WINDOWS)
    install(TARGETS zlib RUNTIME DESTINATION .)
endif()

# --- SDL2 ---
message(STATUS "Adding SDL2 via CPM...")
CPMAddPackage(
    NAME SDL2
    GITHUB_REPOSITORY libsdl-org/SDL
    GIT_TAG release-2.30.10
    OPTIONS
        "SDL_SHARED OFF"
        "SDL_STATIC ON"
        "SDL_STATIC_PIC ON"
        "SDL_TEST OFF"
        "SDL2_DISABLE_INSTALL ON"
)

set(SDL2_INCLUDE_DIRS ${SDL2_SOURCE_DIR}/include)
set(SDL2_LIBRARIES SDL2-static SDL2main)

# Create alias if not exists
if(NOT TARGET SDL2::SDL2)
    add_library(SDL2::SDL2 ALIAS SDL2-static)
endif()
if(NOT TARGET SDL2::SDL2main)
    add_library(SDL2::SDL2main ALIAS SDL2main)
endif()

# --- wxWidgets ---
message(STATUS "Adding wxWidgets via CPM...")
CPMAddPackage(
    NAME wxWidgets
    GITHUB_REPOSITORY wxWidgets/wxWidgets
    GIT_TAG v3.2.8
    OPTIONS
        "wxBUILD_SHARED OFF"
        "wxBUILD_SAMPLES OFF"
        "wxBUILD_TESTS OFF"
        "wxBUILD_DEMOS OFF"
        "wxBUILD_BENCHMARKS OFF"
        "wxBUILD_INSTALL OFF"
        "wxUSE_STL ON"
        "wxUSE_UNICODE ON"
        "wxUSE_UNICODE_UTF8 ON"
        "wxUSE_UNSAFE_WXSTRING_CONV ON"
        "wxUSE_LIBSDL OFF"
)

set(wxWidgets_INCLUDE_DIRS 
    ${wxWidgets_SOURCE_DIR}/include
    ${wxWidgets_BINARY_DIR}/lib/wx/include
)
set(wxWidgets_LIBRARIES wx::core wx::base wx::adv wx::xrc wx::xml)

# For wxrc tool
set(wxWidgets_wxrc_EXECUTABLE $<TARGET_FILE:wxrc>)

# Store XRC compilation command for later use
function(arculator_compile_xrc INPUT_FILE OUTPUT_FILE)
    add_custom_command(
        OUTPUT ${OUTPUT_FILE}
        COMMAND ${wxWidgets_wxrc_EXECUTABLE} -c ${INPUT_FILE} -o ${OUTPUT_FILE}
        DEPENDS ${INPUT_FILE}
        COMMENT "Compiling ${INPUT_FILE} to C++ source"
        VERBATIM
    )
endfunction()
