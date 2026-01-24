# cmake/dependencies.cmake - Dependency management using CPM
#
# All dependencies are fetched and built from source via CPM for reproducible builds.
# This ensures consistent versions across all build environments.
#
# Library build configuration:
#   - zlib: SHARED (consistency across platforms, avoids PIC issues on Linux)
#   - SDL2: SHARED (better compatibility, easier updates)
#   - wxWidgets: SHARED (reduces executable size, standard practice)

# --- zlib (shared) ---
message(STATUS "Adding zlib via CPM (shared)...")
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
    add_library(ZLIB::ZLIB ALIAS zlib)
endif()

set(ZLIB_INCLUDE_DIRS ${zlib_SOURCE_DIR} ${zlib_BINARY_DIR})
set(ZLIB_LIBRARIES zlib)

# Install zlib shared library
if(OS_WINDOWS AND TARGET zlib)
    install(TARGETS zlib RUNTIME DESTINATION .)
endif()
if((OS_LINUX OR OS_MACOSX) AND TARGET zlib)
    install(TARGETS zlib LIBRARY DESTINATION lib)
endif()

# --- SDL2 (shared) ---
message(STATUS "Adding SDL2 via CPM (shared)...")
CPMAddPackage(
    NAME SDL2
    GITHUB_REPOSITORY libsdl-org/SDL
    GIT_TAG release-2.30.10
    OPTIONS
        "SDL_SHARED ON"
        "SDL_STATIC OFF"
        "SDL_TEST OFF"
        "SDL2_DISABLE_INSTALL ON"
)

set(SDL2_INCLUDE_DIRS ${SDL2_SOURCE_DIR}/include)
# SDL2main must come before SDL2 - it depends on SDL2 symbols and linker resolves left-to-right
set(SDL2_LIBRARIES SDL2main SDL2)

# Create alias if not exists
if(NOT TARGET SDL2::SDL2)
    add_library(SDL2::SDL2 ALIAS SDL2)
endif()
if(NOT TARGET SDL2::SDL2main)
    add_library(SDL2::SDL2main ALIAS SDL2main)
endif()

# Install SDL2 DLL on Windows
if(OS_WINDOWS AND TARGET SDL2)
    install(TARGETS SDL2 RUNTIME DESTINATION .)
endif()

# --- wxWidgets (shared) ---
message(STATUS "Adding wxWidgets via CPM (shared)...")
CPMAddPackage(
    NAME wxWidgets
    GITHUB_REPOSITORY wxWidgets/wxWidgets
    GIT_TAG v3.2.8
    OPTIONS
        "wxBUILD_SHARED ON"
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
# Note: xrc depends on html, so we include it
set(wxWidgets_LIBRARIES wx::core wx::base wx::adv wx::xrc wx::xml wx::html)

# Install wxWidgets DLLs on Windows
# Note: wx:: targets are aliases, so we use generator expressions to get the actual DLL paths
if(OS_WINDOWS)
    # wxWidgets shared libraries - install the DLLs needed by our application
    # Include html (dependency of xrc) and qa (optional, for quality assurance dialogs)
    set(WX_DLL_TARGETS wx::base wx::core wx::adv wx::xrc wx::xml wx::html)
    foreach(WX_TARGET ${WX_DLL_TARGETS})
        if(TARGET ${WX_TARGET})
            install(FILES $<TARGET_FILE:${WX_TARGET}> DESTINATION . OPTIONAL)
        endif()
    endforeach()
endif()

# Install shared libraries on Linux/macOS
if(OS_LINUX OR OS_MACOSX)
    # SDL2 shared library
    if(TARGET SDL2)
        install(TARGETS SDL2 LIBRARY DESTINATION lib)
    endif()
    
    # wxWidgets shared libraries - use install(TARGETS) to get proper SONAME symlinks
    # wxWidgets uses "wx" prefix for target names (wxbase, wxcore, etc.)
    set(WX_LIB_TARGETS wxbase wxcore wxadv wxxrc wxxml wxhtml)
    foreach(WX_LIB ${WX_LIB_TARGETS})
        if(TARGET ${WX_LIB})
            install(TARGETS ${WX_LIB} LIBRARY DESTINATION lib)
        endif()
    endforeach()
endif()

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
