# src/CMakeLists.txt - Main Arculator executable

# Common source files for all platforms
set(ARCULATOR_SOURCES
    82c711.c
    82c711_fdc.c
    arm.c
    bmu.c
    cmos.c
    colourcard.c
    config.c
    cp15.c
    ddnoise.c
    debugger.c
    debugger_swis.c
    disc.c
    disc_adf.c
    disc_apd.c
    disc_fdi.c
    disc_hfe.c
    disc_jfd.c
    disc_mfm_common.c
    disc_scp.c
    ds2401.c
    eterna.c
    fdi2raw.c
    fpa.c
    g16.c
    g332.c
    hostfs.c
    ide.c
    ide_a3in.c
    ide_config.c
    ide_idea.c
    ide_riscdev.c
    ide_zidefs.c
    ide_zidefs_a3k.c
    input_sdl2.c
    ioc.c
    ioeb.c
    joystick.c
    keyboard.c
    lc.c
    main.c
    mem.c
    memc.c
    podules.c
    printer.c
    riscdev_hdfc.c
    romload.c
    sound.c
    sound_sdl2.c
    st506.c
    st506_akd52.c
    timer.c
    vidc.c
    video_sdl2.c
    wd1770.c
    wx-app.cc
    wx-config.cc
    wx-config_sel.cc
    wx-hd_conf.cc
    wx-console.cc
    wx-hd_new.cc
    wx-joystick-config.cc
    wx-main.cc
    wx-podule-config.cc
    wx-sdl2-joystick.c
)

# Platform-specific sources
if(OS_WINDOWS)
    list(APPEND ARCULATOR_SOURCES
        hostfs-win.c
        podules-win.c
        wx-win32.c
    )
elseif(OS_LINUX)
    list(APPEND ARCULATOR_SOURCES
        hostfs-unix.c
        podules-linux.c
        wx-sdl2.c
    )
elseif(OS_MACOSX)
    list(APPEND ARCULATOR_SOURCES
        hostfs-unix.c
        podules-macosx.c
        wx-sdl2.c
    )
else()
    # OS_OTHER - use Unix-like sources
    list(APPEND ARCULATOR_SOURCES
        hostfs-unix.c
        podules-linux.c
        wx-sdl2.c
    )
endif()

# Generate wx-resources.cc from arculator.xrc
set(WX_RESOURCES_OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/wx-resources.cc)

# Check if wxrc is available (handle both found program and generator expression)
if(wxWidgets_wxrc_EXECUTABLE AND NOT wxWidgets_wxrc_EXECUTABLE MATCHES "\\$<")
    # We have an actual path to wxrc
    if(EXISTS "${wxWidgets_wxrc_EXECUTABLE}")
        add_custom_command(
            OUTPUT ${WX_RESOURCES_OUTPUT}
            COMMAND ${wxWidgets_wxrc_EXECUTABLE} -c ${CMAKE_CURRENT_SOURCE_DIR}/arculator.xrc -o ${WX_RESOURCES_OUTPUT}
            DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/arculator.xrc
            COMMENT "Compiling arculator.xrc to C++ source"
            VERBATIM
        )
    else()
        message(WARNING "wxrc executable not found at ${wxWidgets_wxrc_EXECUTABLE}, generating placeholder")
        file(WRITE ${WX_RESOURCES_OUTPUT} "// Auto-generated placeholder - wxrc not found\n#include <wx/xrc/xmlres.h>\nvoid InitXmlResource() { wxXmlResource::Get()->InitAllHandlers(); }\n")
    endif()
elseif(wxWidgets_wxrc_EXECUTABLE MATCHES "\\$<")
    # Generator expression - used when building wxWidgets from source
    add_custom_command(
        OUTPUT ${WX_RESOURCES_OUTPUT}
        COMMAND ${wxWidgets_wxrc_EXECUTABLE} -c ${CMAKE_CURRENT_SOURCE_DIR}/arculator.xrc -o ${WX_RESOURCES_OUTPUT}
        DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/arculator.xrc wxrc
        COMMENT "Compiling arculator.xrc to C++ source"
        VERBATIM
    )
elseif(TARGET wxrc)
    # wxrc is a target we built
    add_custom_command(
        OUTPUT ${WX_RESOURCES_OUTPUT}
        COMMAND $<TARGET_FILE:wxrc> -c ${CMAKE_CURRENT_SOURCE_DIR}/arculator.xrc -o ${WX_RESOURCES_OUTPUT}
        DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/arculator.xrc wxrc
        COMMENT "Compiling arculator.xrc to C++ source"
        VERBATIM
    )
else()
    # Fallback: try to find wxrc in PATH
    find_program(WXRC_PROGRAM wxrc)
    if(WXRC_PROGRAM)
        add_custom_command(
            OUTPUT ${WX_RESOURCES_OUTPUT}
            COMMAND ${WXRC_PROGRAM} -c ${CMAKE_CURRENT_SOURCE_DIR}/arculator.xrc -o ${WX_RESOURCES_OUTPUT}
            DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/arculator.xrc
            COMMENT "Compiling arculator.xrc to C++ source"
            VERBATIM
        )
    else()
        message(WARNING "wxrc not available, generating placeholder wx-resources.cc")
        file(WRITE ${WX_RESOURCES_OUTPUT} "// Auto-generated placeholder - wxrc not found\n#include <wx/xrc/xmlres.h>\nvoid InitXmlResource() { wxXmlResource::Get()->InitAllHandlers(); }\n")
    endif()
endif()

list(APPEND ARCULATOR_SOURCES ${WX_RESOURCES_OUTPUT})

# Create the executable
add_executable(arculator ${ARCULATOR_SOURCES})

# Include directories
target_include_directories(arculator PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${SDL2_INCLUDE_DIRS}
    ${wxWidgets_INCLUDE_DIRS}
    ${ZLIB_INCLUDE_DIRS}
)

# Link libraries
target_link_libraries(arculator PRIVATE
    ${wxWidgets_LIBRARIES}
    ${SDL2_LIBRARIES}
    ZLIB::ZLIB
    Threads::Threads
)

# Platform-specific linking
if(OS_WINDOWS)
    # Windows-specific libraries
    target_link_libraries(arculator PRIVATE
        ws2_32
        iphlpapi
    )
elseif(OS_LINUX)
    target_link_libraries(arculator PRIVATE
        ${CMAKE_DL_LIBS}
        ${X11_LIBRARIES}
    )
    target_include_directories(arculator PRIVATE ${X11_INCLUDE_DIR})
elseif(OS_MACOSX)
    if(X11_FOUND)
        target_link_libraries(arculator PRIVATE ${X11_LIBRARIES})
        target_include_directories(arculator PRIVATE ${X11_INCLUDE_DIRS})
    endif()
endif()

# wxWidgets compile definitions and flags
if(wxWidgets_FOUND AND wxWidgets_DEFINITIONS)
    target_compile_definitions(arculator PRIVATE ${wxWidgets_DEFINITIONS})
endif()

# Handle wxWidgets CXX flags
if(wxWidgets_CXX_FLAGS)
    separate_arguments(WX_CXX_FLAGS_LIST UNIX_COMMAND "${wxWidgets_CXX_FLAGS}")
    target_compile_options(arculator PRIVATE $<$<COMPILE_LANGUAGE:CXX>:${WX_CXX_FLAGS_LIST}>)
endif()

# Set executable properties
set_target_properties(arculator PROPERTIES
    OUTPUT_NAME arculator
    RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin
)

# On macOS, create app bundle structure if needed
if(OS_MACOSX)
    set_target_properties(arculator PROPERTIES
        MACOSX_BUNDLE FALSE
    )
endif()

# Install target
install(TARGETS arculator
    RUNTIME DESTINATION .
)

# Install runtime dependencies (DLLs) on Windows
if(OS_WINDOWS)
    # Install GCC runtime DLLs on Windows when using GCC/MinGW
    if(CMAKE_C_COMPILER_ID STREQUAL "GNU")
        # Get the compiler bin directory
        get_filename_component(COMPILER_DIR "${CMAKE_C_COMPILER}" DIRECTORY)
        
        # List of common GCC runtime DLLs
        set(GCC_RUNTIME_DLLS
            "libgcc_s_seh-1.dll"
            "libgcc_s_dw2-1.dll"
            "libstdc++-6.dll"
            "libwinpthread-1.dll"
        )
        
        # Find and install each DLL if it exists
        foreach(DLL_NAME ${GCC_RUNTIME_DLLS})
            if(EXISTS "${COMPILER_DIR}/${DLL_NAME}")
                install(FILES "${COMPILER_DIR}/${DLL_NAME}"
                    DESTINATION .
                )
            endif()
        endforeach()
    endif()
endif()


