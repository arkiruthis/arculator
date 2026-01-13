# deps/wxwidgets.cmake - Fetch and configure wxWidgets

# First try to find system wxWidgets
find_package(wxWidgets QUIET COMPONENTS core base adv xrc xml)

if(NOT wxWidgets_FOUND)
    message(STATUS "System wxWidgets not found, fetching...")
    
    FetchContent_Declare(
        wxWidgets
        GIT_REPOSITORY https://github.com/wxWidgets/wxWidgets.git
        GIT_TAG        v3.2.6
        GIT_SHALLOW    TRUE
    )
    
    # wxWidgets build options
    set(wxBUILD_SHARED OFF CACHE BOOL "" FORCE)
    set(wxBUILD_SAMPLES OFF CACHE BOOL "" FORCE)
    set(wxBUILD_TESTS OFF CACHE BOOL "" FORCE)
    set(wxBUILD_DEMOS OFF CACHE BOOL "" FORCE)
    set(wxBUILD_BENCHMARKS OFF CACHE BOOL "" FORCE)
    set(wxBUILD_INSTALL OFF CACHE BOOL "" FORCE)
    
    # Ensure we get the components we need
    set(wxUSE_STL ON CACHE BOOL "" FORCE)
    set(wxUSE_UNICODE ON CACHE BOOL "" FORCE)
    # Use UTF-8 for wxString internal storage (allows implicit const char* conversion)
    set(wxUSE_UNICODE_UTF8 ON CACHE BOOL "" FORCE)
    set(wxUSE_UNSAFE_WXSTRING_CONV ON CACHE BOOL "" FORCE)
    
    FetchContent_MakeAvailable(wxWidgets)
    
    # Set variables for downstream use
    set(wxWidgets_INCLUDE_DIRS 
        ${wxWidgets_SOURCE_DIR}/include
        ${wxWidgets_BINARY_DIR}/lib/wx/include
    )
    set(wxWidgets_LIBRARIES wx::core wx::base wx::adv wx::xrc wx::xml)
    set(wxWidgets_FOUND TRUE)
    
    # For wxrc tool
    set(wxWidgets_wxrc_EXECUTABLE $<TARGET_FILE:wxrc>)
else()
    message(STATUS "Found system wxWidgets: ${wxWidgets_VERSION_STRING}")
    include(${wxWidgets_USE_FILE})
    
    # Find wxrc
    find_program(wxWidgets_wxrc_EXECUTABLE wxrc)
endif()

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

