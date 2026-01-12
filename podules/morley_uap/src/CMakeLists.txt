# Morley A3000 User and Analogue Port podule

set(MORLEY_UAP_SOURCES
    morley_uap.c
    ${CMAKE_SOURCE_DIR}/podules/common/joystick/joystick_sdl2.c
    ${CMAKE_SOURCE_DIR}/podules/common/adc/d7002c.c
    ${CMAKE_SOURCE_DIR}/podules/common/misc/6522.c
)

add_podule(morley_uap
    SOURCES ${MORLEY_UAP_SOURCES}
    INCLUDE_DIRS
        ${CMAKE_SOURCE_DIR}/podules/common/adc
        ${CMAKE_SOURCE_DIR}/podules/common/joystick
        ${CMAKE_SOURCE_DIR}/podules/common/misc
    LINK_LIBS
        ${SDL2_LIBRARIES}
)

