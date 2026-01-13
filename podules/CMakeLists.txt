# podules/CMakeLists.txt - Build all podule plugins

# Common include directories for all podules
set(PODULE_COMMON_INCLUDE_DIRS
    ${CMAKE_SOURCE_DIR}/src
    ${SDL2_INCLUDE_DIRS}
)

# Common sources for networking podules (slirp library)
set(SLIRP_SOURCES
    ${CMAKE_CURRENT_SOURCE_DIR}/common/net/net.c
    ${CMAKE_CURRENT_SOURCE_DIR}/common/net/net_slirp.c
    ${CMAKE_CURRENT_SOURCE_DIR}/common/net/slirp/bootp.c
    ${CMAKE_CURRENT_SOURCE_DIR}/common/net/slirp/cksum.c
    ${CMAKE_CURRENT_SOURCE_DIR}/common/net/slirp/debug.c
    ${CMAKE_CURRENT_SOURCE_DIR}/common/net/slirp/if.c
    ${CMAKE_CURRENT_SOURCE_DIR}/common/net/slirp/ip_icmp.c
    ${CMAKE_CURRENT_SOURCE_DIR}/common/net/slirp/ip_input.c
    ${CMAKE_CURRENT_SOURCE_DIR}/common/net/slirp/ip_output.c
    ${CMAKE_CURRENT_SOURCE_DIR}/common/net/slirp/mbuf.c
    ${CMAKE_CURRENT_SOURCE_DIR}/common/net/slirp/misc.c
    ${CMAKE_CURRENT_SOURCE_DIR}/common/net/slirp/queue.c
    ${CMAKE_CURRENT_SOURCE_DIR}/common/net/slirp/sbuf.c
    ${CMAKE_CURRENT_SOURCE_DIR}/common/net/slirp/slirp.c
    ${CMAKE_CURRENT_SOURCE_DIR}/common/net/slirp/socket.c
    ${CMAKE_CURRENT_SOURCE_DIR}/common/net/slirp/tcp_input.c
    ${CMAKE_CURRENT_SOURCE_DIR}/common/net/slirp/tcp_output.c
    ${CMAKE_CURRENT_SOURCE_DIR}/common/net/slirp/tcp_subr.c
    ${CMAKE_CURRENT_SOURCE_DIR}/common/net/slirp/tcp_timer.c
    ${CMAKE_CURRENT_SOURCE_DIR}/common/net/slirp/tftp.c
    ${CMAKE_CURRENT_SOURCE_DIR}/common/net/slirp/udp.c
)

# Common sources for SCSI podules
set(SCSI_COMMON_SOURCES
    ${CMAKE_CURRENT_SOURCE_DIR}/common/scsi/hdd_file.c
    ${CMAKE_CURRENT_SOURCE_DIR}/common/scsi/scsi.c
    ${CMAKE_CURRENT_SOURCE_DIR}/common/scsi/scsi_cd.c
    ${CMAKE_CURRENT_SOURCE_DIR}/common/scsi/scsi_config.c
    ${CMAKE_CURRENT_SOURCE_DIR}/common/scsi/scsi_hd.c
)

# Platform-specific CDROM source
if(OS_WINDOWS)
    set(CDROM_SOURCE ${CMAKE_CURRENT_SOURCE_DIR}/common/cdrom/cdrom-windows-ioctl.c)
elseif(OS_LINUX)
    set(CDROM_SOURCE ${CMAKE_CURRENT_SOURCE_DIR}/common/cdrom/cdrom-linux-ioctl.c)
elseif(OS_MACOSX)
    set(CDROM_SOURCE ${CMAKE_CURRENT_SOURCE_DIR}/common/cdrom/cdrom-osx-ioctl.c)
else()
    set(CDROM_SOURCE ${CMAKE_CURRENT_SOURCE_DIR}/common/cdrom/cdrom-linux-ioctl.c)
endif()

# Platform-specific MIDI source
if(OS_WINDOWS)
    set(MIDI_SOURCE ${CMAKE_CURRENT_SOURCE_DIR}/common/midi/midi_win.c)
elseif(OS_LINUX)
    set(MIDI_SOURCE ${CMAKE_CURRENT_SOURCE_DIR}/common/midi/midi_alsa.c)
elseif(OS_MACOSX)
    set(MIDI_SOURCE ${CMAKE_CURRENT_SOURCE_DIR}/common/midi/midi_null.c)
else()
    set(MIDI_SOURCE ${CMAKE_CURRENT_SOURCE_DIR}/common/midi/midi_null.c)
endif()

# Platform-specific sound input source
if(OS_WINDOWS)
    set(SOUND_IN_SOURCE ${CMAKE_CURRENT_SOURCE_DIR}/common/sound/sound_wavein.c)
elseif(OS_LINUX)
    set(SOUND_IN_SOURCE ${CMAKE_CURRENT_SOURCE_DIR}/common/sound/sound_alsain.c)
else()
    set(SOUND_IN_SOURCE ${CMAKE_CURRENT_SOURCE_DIR}/common/sound/sound_in_null.c)
endif()

# Helper function to create a podule shared library
function(add_podule NAME)
    cmake_parse_arguments(PODULE "" "" "SOURCES;INCLUDE_DIRS;LINK_LIBS" ${ARGN})
    
    add_library(${NAME} MODULE ${PODULE_SOURCES})
    
    target_include_directories(${NAME} PRIVATE
        ${PODULE_COMMON_INCLUDE_DIRS}
        ${PODULE_INCLUDE_DIRS}
    )
    
    target_link_libraries(${NAME} PRIVATE
        ${PODULE_LINK_LIBS}
    )
    
    # Set output name and properties
    set_target_properties(${NAME} PROPERTIES
        PREFIX ""
        LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib/podules/${NAME}
    )
    
    # Platform-specific library extension
    if(OS_WINDOWS)
        set_target_properties(${NAME} PROPERTIES SUFFIX ".dll")
    elseif(OS_MACOSX)
        set_target_properties(${NAME} PROPERTIES SUFFIX ".dylib")
    else()
        set_target_properties(${NAME} PROPERTIES SUFFIX ".so")
    endif()
    
    # Install to podules/NAME/ subdirectory
    install(TARGETS ${NAME}
        LIBRARY DESTINATION podules/${NAME}
    )
endfunction()

# Add all podule subdirectories
add_subdirectory(aeh50/src)
add_subdirectory(aeh54/src)
add_subdirectory(aka05/src)
add_subdirectory(aka10/src)
add_subdirectory(aka12/src)
add_subdirectory(aka16/src)
add_subdirectory(aka31/src)
add_subdirectory(designit_e200/src)
add_subdirectory(lark/src)
add_subdirectory(midimax/src)
add_subdirectory(morley_uap/src)
add_subdirectory(oak_scsi/src)
add_subdirectory(pccard/src)
add_subdirectory(ultimatecdrom/src)

