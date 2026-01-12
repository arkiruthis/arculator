# AKA10 podule

set(AKA10_SOURCES
    aka10.c
    ${CMAKE_SOURCE_DIR}/podules/common/uart/6850.c
    ${CMAKE_SOURCE_DIR}/podules/common/joystick/joystick_sdl2.c
    ${CMAKE_SOURCE_DIR}/podules/common/adc/d7002c.c
    ${CMAKE_SOURCE_DIR}/podules/common/misc/6522.c
    ${MIDI_SOURCE}
)

add_podule(aka10
    SOURCES ${AKA10_SOURCES}
    INCLUDE_DIRS
        ${CMAKE_SOURCE_DIR}/podules/common/adc
        ${CMAKE_SOURCE_DIR}/podules/common/joystick
        ${CMAKE_SOURCE_DIR}/podules/common/midi
        ${CMAKE_SOURCE_DIR}/podules/common/misc
        ${CMAKE_SOURCE_DIR}/podules/common/uart
    LINK_LIBS
        ${SDL2_LIBRARIES}
)

if(OS_WINDOWS)
    target_link_libraries(aka10 PRIVATE winmm)
endif()

