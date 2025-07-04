#----------------------------------------------------------------------------------#
#//////////////////////////////////////////////////////////////////////////////////#
#----------------------------------------------------------------------------------#
#
#  Copyright (C) 2017, StepToSky
#  All rights reserved.
#
#  Redistribution and use in source and binary forms, with or without
#  modification, are permitted provided that the following conditions are met:
#
#  1.Redistributions of source code must retain the above copyright notice, this
#    list of conditions and the following disclaimer.
#  2.Redistributions in binary form must reproduce the above copyright notice,
#    this list of conditions and the following disclaimer in the documentation
#    and / or other materials provided with the distribution.
#  3.Neither the name of StepToSky nor the names of its
#    contributors may be used to endorse or promote products derived from
#    this software without specific prior written permission.
#
#  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
#  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
#  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
#  DISCLAIMED.IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
#  ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
#  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
#  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
#  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
#  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
#  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
#  Contacts: www.steptosky.com
#
#----------------------------------------------------------------------------------#
#//////////////////////////////////////////////////////////////////////////////////#
#----------------------------------------------------------------------------------#
# init

message(STATUS "==============================================")
cmake_minimum_required (VERSION 3.15.0)
list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")

#----------------------------------------------------------------------------------#
#//////////////////////////////////////////////////////////////////////////////////#
#----------------------------------------------------------------------------------#
# Solution

project("3DsMax-XplnObj" LANGUAGES "CXX")

# Set C++ standard
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

#----------------------------------------------------------------------------------#
# Find required dependencies

# Function to find all available 3ds Max SDK installations with enhanced robustness
function(find_all_max_sdks)
    set(MAX_SDK_PATHS "")
    set(MAX_SDK_VERSIONS "")

    # Extended list of 3ds Max versions to search for (in order of preference - newest first)
    set(MAX_VERSIONS "2026" "2025" "2024" "2023" "2022" "2021" "2020" "2019" "2018" "2017" "2016" "2015" "2014" "2013" "2012" "2011" "2010" "2009" "2008")

    # Enhanced search patterns for environment variables - more comprehensive coverage
    set(ENV_PATTERNS
        "ADSK_3DSMAX_SDK_"          # Direct SDK environment variables
        "3DSMAX_SDK_"               # Alternative SDK environment variables
        "MAX_SDK_"                  # Generic SDK environment variables
        "MAXSDK_"                   # Short SDK environment variables
        "ADSK_3DSMAX_x64_"          # Installation paths (need to append SDK subpath)
        "ADSK_3DSMAX_"              # Installation paths without x64
        "3DSMAX_"                   # Installation paths
        "MAX_"                      # Generic 3ds Max installation paths
        "AUTODESK_3DSMAX_"          # Autodesk specific paths
        "AUTODESK_MAX_"             # Autodesk Max paths
    )

    # Get all available drive letters and create comprehensive search paths
    set(DRIVE_LETTERS "C" "D" "E" "F" "G" "H" "I" "J" "K" "L" "M" "N" "O" "P" "Q" "R" "S" "T" "U" "V" "W" "X" "Y" "Z")
    set(COMMON_INSTALL_DIRS "")

    foreach(DRIVE ${DRIVE_LETTERS})
        # Standard Autodesk installation paths
        list(APPEND COMMON_INSTALL_DIRS
            "${DRIVE}:/Program Files/Autodesk"
            "${DRIVE}:/Program Files (x86)/Autodesk"
            "${DRIVE}:/Autodesk"
            "${DRIVE}:/Apps/Autodesk"
            "${DRIVE}:/Software/Autodesk"
            "${DRIVE}:/Development/Autodesk"
            "${DRIVE}:/Dev/Autodesk"
            "${DRIVE}:/Tools/Autodesk"
            "${DRIVE}:/3dsMax"
            "${DRIVE}:/MaxSDK"
            "${DRIVE}:/SDK/3dsMax"
            "${DRIVE}:/SDK/Autodesk"
        )
    endforeach()

    # Add environment-based paths if they exist
    if(DEFINED ENV{ProgramFiles})
        list(APPEND COMMON_INSTALL_DIRS
            "$ENV{ProgramFiles}/Autodesk"
            "$ENV{ProgramFiles}/3dsMax"
            "$ENV{ProgramFiles}/MaxSDK"
        )
    endif()
    if(DEFINED ENV{ProgramW6432})
        list(APPEND COMMON_INSTALL_DIRS
            "$ENV{ProgramW6432}/Autodesk"
            "$ENV{ProgramW6432}/3dsMax"
            "$ENV{ProgramW6432}/MaxSDK"
        )
    endif()
    if(DEFINED ENV{ProgramFiles\(x86\)})
        list(APPEND COMMON_INSTALL_DIRS
            "$ENV{ProgramFiles\(x86\)}/Autodesk"
            "$ENV{ProgramFiles\(x86\)}/3dsMax"
            "$ENV{ProgramFiles\(x86\)}/MaxSDK"
        )
    endif()

    # Add user profile paths
    if(DEFINED ENV{USERPROFILE})
        list(APPEND COMMON_INSTALL_DIRS
            "$ENV{USERPROFILE}/Documents/Autodesk"
            "$ENV{USERPROFILE}/AppData/Local/Autodesk"
            "$ENV{USERPROFILE}/AppData/Roaming/Autodesk"
        )
    endif()

    # Search through environment variables first with debug output
    message(STATUS "Searching for 3ds Max SDK through environment variables...")
    foreach(VERSION ${MAX_VERSIONS})
        foreach(PATTERN ${ENV_PATTERNS})
            set(ENV_VAR_NAME "${PATTERN}${VERSION}")
            if(DEFINED ENV{${ENV_VAR_NAME}})
                set(ENV_PATH "$ENV{${ENV_VAR_NAME}}")
                message(STATUS "  Checking environment variable: ${ENV_VAR_NAME} = ${ENV_PATH}")

                # Enhanced list of possible SDK subdirectories
                set(POSSIBLE_SDK_PATHS
                    "${ENV_PATH}"                           # Direct SDK path
                    "${ENV_PATH}/maxsdk"                    # Standard maxsdk subdirectory
                    "${ENV_PATH}/SDK/maxsdk"                # Alternative SDK subdirectory
                    "${ENV_PATH}/sdk/maxsdk"                # Lowercase sdk
                    "${ENV_PATH}/../3ds Max ${VERSION} SDK/maxsdk"  # Adjacent SDK installation
                    "${ENV_PATH}/../SDK/maxsdk"             # Generic adjacent SDK
                    "${ENV_PATH}/../sdk/maxsdk"             # Generic adjacent SDK lowercase
                    "${ENV_PATH}/include"                   # Some SDKs have direct include
                    "${ENV_PATH}/MaxSDK"                    # Alternative naming
                    "${ENV_PATH}/3dsMaxSDK"                 # Alternative naming
                )

                foreach(SDK_PATH ${POSSIBLE_SDK_PATHS})
                    if(EXISTS "${SDK_PATH}/include/max.h")
                        message(STATUS "  Found 3ds Max ${VERSION} SDK via ${ENV_VAR_NAME}: ${SDK_PATH}")
                        # Check if we already found this path to avoid duplicates
                        list(FIND MAX_SDK_PATHS "${SDK_PATH}" PATH_INDEX)
                        if(PATH_INDEX EQUAL -1)
                            list(APPEND MAX_SDK_PATHS "${SDK_PATH}")
                            list(APPEND MAX_SDK_VERSIONS "${VERSION}")
                        endif()
                        break()
                    endif()
                endforeach()
            endif()
        endforeach()
    endforeach()

    # Search through common installation directories with enhanced patterns
    message(STATUS "Searching for 3ds Max SDK in common installation directories...")
    foreach(BASE_DIR ${COMMON_INSTALL_DIRS})
        if(EXISTS "${BASE_DIR}")
            message(STATUS "  Searching in: ${BASE_DIR}")
            foreach(VERSION ${MAX_VERSIONS})
                # Comprehensive list of possible SDK installation patterns
                set(POSSIBLE_PATHS
                    "${BASE_DIR}/3ds Max ${VERSION} SDK/maxsdk"
                    "${BASE_DIR}/3dsMax${VERSION}SDK/maxsdk"
                    "${BASE_DIR}/3ds Max ${VERSION}/SDK/maxsdk"
                    "${BASE_DIR}/3ds Max ${VERSION}/maxsdk"
                    "${BASE_DIR}/3ds Max ${VERSION}/sdk/maxsdk"
                    "${BASE_DIR}/Autodesk 3ds Max ${VERSION} SDK/maxsdk"
                    "${BASE_DIR}/Autodesk 3ds Max ${VERSION}/maxsdk"
                    "${BASE_DIR}/Max${VERSION}SDK/maxsdk"
                    "${BASE_DIR}/Max${VERSION}/SDK/maxsdk"
                    "${BASE_DIR}/Max${VERSION}/maxsdk"
                    "${BASE_DIR}/3dsmax${VERSION}/SDK/maxsdk"
                    "${BASE_DIR}/3dsmax${VERSION}/maxsdk"
                    "${BASE_DIR}/3dsmax${VERSION}/sdk/maxsdk"
                    "${BASE_DIR}/3DsMax${VERSION}/SDK/maxsdk"
                    "${BASE_DIR}/3DsMax${VERSION}/maxsdk"
                    "${BASE_DIR}/SDK/3dsMax${VERSION}/maxsdk"
                    "${BASE_DIR}/SDK/Max${VERSION}/maxsdk"
                    "${BASE_DIR}/MaxSDK${VERSION}/maxsdk"
                    "${BASE_DIR}/3dsMaxSDK${VERSION}/maxsdk"
                    "${BASE_DIR}/3dsMax_SDK_${VERSION}/maxsdk"
                    "${BASE_DIR}/Max_SDK_${VERSION}/maxsdk"
                    # Alternative directory structures
                    "${BASE_DIR}/3ds Max ${VERSION} SDK"
                    "${BASE_DIR}/3dsMax${VERSION}SDK"
                    "${BASE_DIR}/Max${VERSION}SDK"
                    "${BASE_DIR}/MaxSDK${VERSION}"
                    "${BASE_DIR}/3dsMaxSDK${VERSION}"
                )

                foreach(SEARCH_PATH ${POSSIBLE_PATHS})
                    # Check for max.h in both maxsdk/include and direct include
                    set(HEADER_PATHS
                        "${SEARCH_PATH}/include/max.h"
                        "${SEARCH_PATH}/maxsdk/include/max.h"
                    )

                    foreach(HEADER_PATH ${HEADER_PATHS})
                        if(EXISTS "${HEADER_PATH}")
                            get_filename_component(FINAL_SDK_PATH "${HEADER_PATH}" DIRECTORY)
                            get_filename_component(FINAL_SDK_PATH "${FINAL_SDK_PATH}" DIRECTORY)

                            # Check if we already found this version
                            list(FIND MAX_SDK_VERSIONS "${VERSION}" VERSION_INDEX)
                            if(VERSION_INDEX EQUAL -1)
                                message(STATUS "    Found 3ds Max ${VERSION} SDK in: ${FINAL_SDK_PATH}")
                                list(APPEND MAX_SDK_PATHS "${FINAL_SDK_PATH}")
                                list(APPEND MAX_SDK_VERSIONS "${VERSION}")
                                break()
                            endif()
                        endif()
                    endforeach()

                    # If we found this version, break out of the paths loop
                    list(FIND MAX_SDK_VERSIONS "${VERSION}" VERSION_INDEX)
                    if(NOT VERSION_INDEX EQUAL -1)
                        break()
                    endif()
                endforeach()
            endforeach()
        endif()
    endforeach()

    # Additional search: scan for any directory that contains max.h
    message(STATUS "Performing comprehensive filesystem scan for remaining SDKs...")
    foreach(DRIVE ${DRIVE_LETTERS})
        if(EXISTS "${DRIVE}:/")
            file(GLOB_RECURSE MAX_HEADERS
                LIST_DIRECTORIES false
                "${DRIVE}:/*/include/max.h"
                "${DRIVE}:/*/maxsdk/include/max.h"
                "${DRIVE}:/*/*/include/max.h"
                "${DRIVE}:/*/*/maxsdk/include/max.h"
                "${DRIVE}:/*/*/*/include/max.h"
                "${DRIVE}:/*/*/*/maxsdk/include/max.h"
            )

            foreach(HEADER_FILE ${MAX_HEADERS})
                get_filename_component(POTENTIAL_SDK_PATH "${HEADER_FILE}" DIRECTORY)
                get_filename_component(POTENTIAL_SDK_PATH "${POTENTIAL_SDK_PATH}" DIRECTORY)

                # Try to extract version from path
                string(REGEX MATCH "20[0-9][0-9]|[12][0-9]" POTENTIAL_VERSION "${POTENTIAL_SDK_PATH}")
                if(POTENTIAL_VERSION)
                    # Check if this is a new find
                    list(FIND MAX_SDK_PATHS "${POTENTIAL_SDK_PATH}" PATH_INDEX)
                    if(PATH_INDEX EQUAL -1)
                        message(STATUS "    Discovered additional 3ds Max ${POTENTIAL_VERSION} SDK: ${POTENTIAL_SDK_PATH}")
                        list(APPEND MAX_SDK_PATHS "${POTENTIAL_SDK_PATH}")
                        list(APPEND MAX_SDK_VERSIONS "${POTENTIAL_VERSION}")
                    endif()
                endif()
            endforeach()
        endif()
    endforeach()

    # Sort results by version (newest first)
    if(MAX_SDK_VERSIONS)
        list(LENGTH MAX_SDK_VERSIONS LIST_LENGTH)
        math(EXPR LAST_INDEX "${LIST_LENGTH} - 1")

        # Simple bubble sort by version number
        foreach(I RANGE 0 ${LAST_INDEX})
            math(EXPR INNER_LAST "${LAST_INDEX} - ${I}")
            foreach(J RANGE 0 ${INNER_LAST})
                math(EXPR NEXT_J "${J} + 1")
                if(NEXT_J LESS_EQUAL ${LAST_INDEX})
                    list(GET MAX_SDK_VERSIONS ${J} VER_A)
                    list(GET MAX_SDK_VERSIONS ${NEXT_J} VER_B)

                    if(VER_A LESS VER_B)
                        # Swap versions
                        list(GET MAX_SDK_PATHS ${J} PATH_A)
                        list(GET MAX_SDK_PATHS ${NEXT_J} PATH_B)

                        list(REMOVE_AT MAX_SDK_VERSIONS ${J} ${NEXT_J})
                        list(REMOVE_AT MAX_SDK_PATHS ${J} ${NEXT_J})

                        list(INSERT MAX_SDK_VERSIONS ${J} ${VER_B})
                        list(INSERT MAX_SDK_VERSIONS ${NEXT_J} ${VER_A})
                        list(INSERT MAX_SDK_PATHS ${J} ${PATH_B})
                        list(INSERT MAX_SDK_PATHS ${NEXT_J} ${PATH_A})
                    endif()
                endif()
            endforeach()
        endforeach()
    endif()

    # Set results in parent scope
    set(MAX_SDK_PATHS "${MAX_SDK_PATHS}" PARENT_SCOPE)
    set(MAX_SDK_VERSIONS "${MAX_SDK_VERSIONS}" PARENT_SCOPE)
endfunction()

# Find all available 3ds Max SDKs
find_all_max_sdks()

# Select the best SDK to use
if(MAX_SDK_PATHS)
    list(LENGTH MAX_SDK_PATHS NUM_SDKS)
    message(STATUS "Found ${NUM_SDKS} 3ds Max SDK installation(s)")

    # Use the first (newest) SDK found
    list(GET MAX_SDK_PATHS 0 MAX_SDK_PATH)
    list(GET MAX_SDK_VERSIONS 0 MAX_SDK_VERSION)

    message(STATUS "Using 3ds Max ${MAX_SDK_VERSION} SDK: ${MAX_SDK_PATH}")

    # Allow user to override SDK selection
    set(MAX_SDK_PATH "${MAX_SDK_PATH}" CACHE PATH "Path to 3ds Max SDK")
    set(MAX_SDK_VERSION "${MAX_SDK_VERSION}" CACHE STRING "3ds Max SDK Version")

    # Display all found SDKs for user information
    if(NUM_SDKS GREATER 1)
        message(STATUS "Other available SDKs:")
        math(EXPR LAST_INDEX "${NUM_SDKS} - 1")
        foreach(INDEX RANGE 1 ${LAST_INDEX})
            list(GET MAX_SDK_PATHS ${INDEX} OTHER_PATH)
            list(GET MAX_SDK_VERSIONS ${INDEX} OTHER_VERSION)
            message(STATUS "  - 3ds Max ${OTHER_VERSION}: ${OTHER_PATH}")
        endforeach()
        message(STATUS "To use a different SDK, set MAX_SDK_PATH manually or set the appropriate environment variable")
    endif()
else()
    message(STATUS "No 3ds Max SDK found automatically")
endif()

# Final fallback using find_path with all discovered hints
set(ALL_SDK_HINTS ${MAX_SDK_PATHS})
find_path(MAX_SDK_PATH "include/max.h"
    HINTS ${ALL_SDK_HINTS}
    DOC "3ds Max SDK path"
)

if(NOT MAX_SDK_PATH)
    message(FATAL_ERROR "3ds Max SDK not found. Please set your 3ds Max SDK environment variable or install 3ds Max SDK")
endif()

message(STATUS "Found 3ds Max SDK at: ${MAX_SDK_PATH}")

# Function to setup XplnObj library automatically
function(setup_xplnobj_library)
    set(XPLNOBJ_REPO_URL "https://github.com/Coalition-of-Freeware-Developers/XplnObj.git")
    set(XPLNOBJ_LOCAL_PATH "${CMAKE_SOURCE_DIR}/third_party/XplnObj")

    # Check if XplnObj is already available in common locations
    set(XPLNOBJ_SEARCH_PATHS
        $ENV{XPLNOBJ_PATH}
        ${CMAKE_SOURCE_DIR}/third_party/XplnObj
        ${CMAKE_SOURCE_DIR}/external/XplnObj
        ${CMAKE_SOURCE_DIR}/../XplnObj
    )

    foreach(SEARCH_PATH ${XPLNOBJ_SEARCH_PATHS})
        if(EXISTS "${SEARCH_PATH}/include/xpln/obj/ObjMain.h")
            message(STATUS "Found existing XplnObj installation at: ${SEARCH_PATH}")
            set(XPLNOBJ_ROOT_PATH "${SEARCH_PATH}" PARENT_SCOPE)
            return()
        endif()
    endforeach()

    # Check if we should automatically download and build XplnObj
    if(NOT DEFINED AUTO_FETCH_XPLNOBJ)
        message(STATUS "===============================================")
        message(STATUS "XplnObj library not found!")
        message(STATUS "This library is required to build the project.")
        message(STATUS "")
        message(STATUS "Options:")
        message(STATUS "1. Set XPLNOBJ_PATH environment variable to existing installation")
        message(STATUS "2. Allow CMake to automatically download and build XplnObj")
        message(STATUS "   Repository: ${XPLNOBJ_REPO_URL}")
        message(STATUS "   Local path: ${XPLNOBJ_LOCAL_PATH}")
        message(STATUS "")
        message(STATUS "To automatically download and build, run:")
        message(STATUS "  cmake . -DAUTO_FETCH_XPLNOBJ=ON")
        message(STATUS "")
        message(STATUS "To skip auto-fetch and handle manually, run:")
        message(STATUS "  cmake . -DAUTO_FETCH_XPLNOBJ=OFF")
        message(STATUS "===============================================")
        message(FATAL_ERROR "XplnObj library setup required. Please choose an option above.")
    endif()

    if(NOT AUTO_FETCH_XPLNOBJ)
        message(FATAL_ERROR "XplnObj library not found and AUTO_FETCH_XPLNOBJ is disabled. Please set XPLNOBJ_PATH environment variable or enable auto-fetch.")
    endif()

    # Auto-fetch and build XplnObj
    message(STATUS "Automatically setting up XplnObj library...")

    # Check if git is available
    find_package(Git QUIET)
    if(NOT GIT_FOUND)
        message(FATAL_ERROR "Git is required to download XplnObj library. Please install Git or manually download the library.")
    endif()

    # Clone repository if it doesn't exist
    if(NOT EXISTS "${XPLNOBJ_LOCAL_PATH}")
        message(STATUS "Cloning XplnObj repository...")
        execute_process(
            COMMAND ${GIT_EXECUTABLE} clone ${XPLNOBJ_REPO_URL} ${XPLNOBJ_LOCAL_PATH}
            RESULT_VARIABLE GIT_RESULT
            OUTPUT_VARIABLE GIT_OUTPUT
            ERROR_VARIABLE GIT_ERROR
        )

        if(NOT GIT_RESULT EQUAL 0)
            message(FATAL_ERROR "Failed to clone XplnObj repository: ${GIT_ERROR}")
        endif()

        message(STATUS "Successfully cloned XplnObj repository")
    else()
        message(STATUS "XplnObj repository already exists, updating...")
        execute_process(
            COMMAND ${GIT_EXECUTABLE} pull
            WORKING_DIRECTORY ${XPLNOBJ_LOCAL_PATH}
            RESULT_VARIABLE GIT_RESULT
            OUTPUT_VARIABLE GIT_OUTPUT
            ERROR_VARIABLE GIT_ERROR
        )

        if(NOT GIT_RESULT EQUAL 0)
            message(WARNING "Failed to update XplnObj repository: ${GIT_ERROR}")
        endif()
    endif()

    # Check if the cloned repository has the expected structure
    if(NOT EXISTS "${XPLNOBJ_LOCAL_PATH}/include/xpln/obj/ObjMain.h")
        message(FATAL_ERROR "XplnObj repository does not have expected structure. Please check the repository.")
    endif()

    # Build XplnObj if needed
    set(XPLNOBJ_BUILD_DIR "${XPLNOBJ_LOCAL_PATH}/build")
    set(XPLNOBJ_INSTALL_DIR "${XPLNOBJ_LOCAL_PATH}/install")

    if(NOT EXISTS "${XPLNOBJ_INSTALL_DIR}/lib")
        message(STATUS "Building XplnObj library...")

        # Create build directory
        file(MAKE_DIRECTORY ${XPLNOBJ_BUILD_DIR})

        # Try to configure XplnObj with modern CMake and disable Conan
        # First, try to patch the CMakeLists.txt to skip Conan
        set(XPLNOBJ_CMAKE_PATCH "${XPLNOBJ_LOCAL_PATH}/CMakeLists_original.txt")
        if(NOT EXISTS "${XPLNOBJ_CMAKE_PATCH}")
            # Backup original CMakeLists.txt
            file(COPY "${XPLNOBJ_LOCAL_PATH}/CMakeLists.txt" DESTINATION "${XPLNOBJ_LOCAL_PATH}/CMakeLists_original.txt")

            # Read and modify the CMakeLists.txt to skip Conan
            file(READ "${XPLNOBJ_LOCAL_PATH}/CMakeLists.txt" XPLNOBJ_CMAKE_CONTENT)

            # Replace the Conan section with a simple comment
            string(REPLACE
                "include(StsConan)\nconan_cmake_run(CONANFILE conanfile.py\n                BASIC_SETUP CMAKE_TARGETS KEEP_RPATHS\n                BUILD missing)"
                "# Conan dependency management disabled for compatibility\n# All dependencies are assumed to be header-only or not required"
                XPLNOBJ_CMAKE_CONTENT "${XPLNOBJ_CMAKE_CONTENT}")

            # Update minimum CMake version to avoid deprecation warnings
            string(REPLACE
                "cmake_minimum_required (VERSION 3.7.0)"
                "cmake_minimum_required (VERSION 3.15.0)"
                XPLNOBJ_CMAKE_CONTENT "${XPLNOBJ_CMAKE_CONTENT}")

            # Write the modified CMakeLists.txt
            file(WRITE "${XPLNOBJ_LOCAL_PATH}/CMakeLists.txt" "${XPLNOBJ_CMAKE_CONTENT}")
        endif()

        # Configure XplnObj with testing disabled
        execute_process(
            COMMAND ${CMAKE_COMMAND}
                -S ${XPLNOBJ_LOCAL_PATH}
                -B ${XPLNOBJ_BUILD_DIR}
                -DCMAKE_INSTALL_PREFIX=${XPLNOBJ_INSTALL_DIR}
                -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
                -DBUILD_TESTING=OFF
                -DBUILD_SHARED_LIBS=OFF
            RESULT_VARIABLE CMAKE_RESULT
            OUTPUT_VARIABLE CMAKE_OUTPUT
            ERROR_VARIABLE CMAKE_ERROR
        )

        if(NOT CMAKE_RESULT EQUAL 0)
            message(STATUS "First attempt failed, trying fallback approach...")
            message(STATUS "CMake Output: ${CMAKE_OUTPUT}")
            message(STATUS "CMake Error: ${CMAKE_ERROR}")

            # Fallback: Try to build just the library part manually
            message(STATUS "Attempting manual library build...")

            # Create a minimal CMakeLists.txt for just the library
            set(MINIMAL_CMAKE_CONTENT "
cmake_minimum_required(VERSION 3.15.0)
project(XplnObj VERSION 1.0.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Collect all source files
file(GLOB_RECURSE SRC_FILES
    \"src/*.cpp\"
    \"src/*.h\"
)

# Remove stdafx files if they exist (they can cause issues)
list(FILTER SRC_FILES EXCLUDE REGEX \".*stdafx.*\")

# Create the library
add_library(XplnObj STATIC \${SRC_FILES})

# Set include directories
target_include_directories(XplnObj PUBLIC
    \$<BUILD_INTERFACE:\${CMAKE_CURRENT_SOURCE_DIR}/include>
    \$<INSTALL_INTERFACE:include>
)

# Install the library
install(TARGETS XplnObj
    EXPORT XplnObjTargets
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
    RUNTIME DESTINATION bin
)

# Install headers
install(DIRECTORY include/ DESTINATION include)

# Install export
install(EXPORT XplnObjTargets
    FILE XplnObjTargets.cmake
    DESTINATION lib/cmake/XplnObj
)
")

            file(WRITE "${XPLNOBJ_BUILD_DIR}/CMakeLists.txt" "${MINIMAL_CMAKE_CONTENT}")

            # Try configuring with minimal CMakeLists.txt
            execute_process(
                COMMAND ${CMAKE_COMMAND}
                    -S ${XPLNOBJ_BUILD_DIR}
                    -B ${XPLNOBJ_BUILD_DIR}/build
                    -DCMAKE_INSTALL_PREFIX=${XPLNOBJ_INSTALL_DIR}
                    -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
                WORKING_DIRECTORY ${XPLNOBJ_LOCAL_PATH}
                RESULT_VARIABLE CMAKE_RESULT2
                OUTPUT_VARIABLE CMAKE_OUTPUT2
                ERROR_VARIABLE CMAKE_ERROR2
            )

            if(NOT CMAKE_RESULT2 EQUAL 0)
                message(FATAL_ERROR "Failed to configure XplnObj with fallback method: ${CMAKE_ERROR2}")
            endif()

            set(BUILD_DIR_TO_USE "${XPLNOBJ_BUILD_DIR}/build")
        else()
            set(BUILD_DIR_TO_USE "${XPLNOBJ_BUILD_DIR}")
        endif()

        # Determine build configuration
        if(CMAKE_BUILD_TYPE)
            set(BUILD_CONFIG ${CMAKE_BUILD_TYPE})
        else()
            set(BUILD_CONFIG "Release")
        endif()

        # Build XplnObj
        execute_process(
            COMMAND ${CMAKE_COMMAND} --build ${BUILD_DIR_TO_USE} --config ${BUILD_CONFIG}
            RESULT_VARIABLE BUILD_RESULT
            OUTPUT_VARIABLE BUILD_OUTPUT
            ERROR_VARIABLE BUILD_ERROR
        )

        if(NOT BUILD_RESULT EQUAL 0)
            message(FATAL_ERROR "Failed to build XplnObj: ${BUILD_ERROR}")
        endif()

        # Install XplnObj
        execute_process(
            COMMAND ${CMAKE_COMMAND} --install ${BUILD_DIR_TO_USE} --config ${BUILD_CONFIG}
            RESULT_VARIABLE INSTALL_RESULT
            OUTPUT_VARIABLE INSTALL_OUTPUT
            ERROR_VARIABLE INSTALL_ERROR
        )

        if(NOT INSTALL_RESULT EQUAL 0)
            message(FATAL_ERROR "Failed to install XplnObj: ${INSTALL_ERROR}")
        endif()

        message(STATUS "Successfully built and installed XplnObj library")
    endif()

    # Set the root path for finding the library
    set(XPLNOBJ_ROOT_PATH "${XPLNOBJ_INSTALL_DIR}" PARENT_SCOPE)

    # Suggest setting environment variable for future builds
    message(STATUS "===============================================")
    message(STATUS "XplnObj library has been successfully set up!")
    message(STATUS "For future builds, consider setting the environment variable:")
    if(WIN32)
        message(STATUS "  setx XPLNOBJ_PATH \"${XPLNOBJ_INSTALL_DIR}\"")
    else()
        message(STATUS "  export XPLNOBJ_PATH=\"${XPLNOBJ_INSTALL_DIR}\"")
    endif()
    message(STATUS "===============================================")
endfunction()

# Setup XplnObj library
setup_xplnobj_library()

# Now find XplnObj library using the determined root path
if(XPLNOBJ_ROOT_PATH)
    set(XPLNOBJ_SEARCH_HINTS
        ${XPLNOBJ_ROOT_PATH}/install/include
        ${XPLNOBJ_ROOT_PATH}/include
        ${XPLNOBJ_ROOT_PATH}
    )
    set(XPLNOBJ_LIB_SEARCH_HINTS
        ${XPLNOBJ_ROOT_PATH}/install/lib
        ${XPLNOBJ_ROOT_PATH}/install/Release
        ${XPLNOBJ_ROOT_PATH}/install/Debug
        ${XPLNOBJ_ROOT_PATH}/lib
        ${XPLNOBJ_ROOT_PATH}/Release
        ${XPLNOBJ_ROOT_PATH}/Debug
        ${XPLNOBJ_ROOT_PATH}
    )
else()
    set(XPLNOBJ_SEARCH_HINTS
        $ENV{XPLNOBJ_PATH}/include
        ${CMAKE_SOURCE_DIR}/third_party/XplnObj/include
        ${CMAKE_SOURCE_DIR}/external/XplnObj/include
    )
    set(XPLNOBJ_LIB_SEARCH_HINTS
        $ENV{XPLNOBJ_PATH}/lib
        $ENV{XPLNOBJ_PATH}/Release
        $ENV{XPLNOBJ_PATH}/Debug
        ${CMAKE_SOURCE_DIR}/third_party/XplnObj/lib
        ${CMAKE_SOURCE_DIR}/third_party/XplnObj/install/lib
        ${CMAKE_SOURCE_DIR}/third_party/XplnObj/install/Release
        ${CMAKE_SOURCE_DIR}/third_party/XplnObj/install/Debug
        ${CMAKE_SOURCE_DIR}/third_party/XplnObj/build/Release
        ${CMAKE_SOURCE_DIR}/third_party/XplnObj/build/Debug
        ${CMAKE_SOURCE_DIR}/external/XplnObj/lib
        ${CMAKE_SOURCE_DIR}/external/XplnObj/install/lib
        ${CMAKE_SOURCE_DIR}/external/XplnObj/install/Release
        ${CMAKE_SOURCE_DIR}/external/XplnObj/install/Debug
    )
endif()

find_path(XPLNOBJ_INCLUDE_DIR "xpln/obj/ObjMain.h"
    HINTS ${XPLNOBJ_SEARCH_HINTS}
    DOC "XplnObj library include directory"
)

find_library(XPLNOBJ_LIBRARY
    NAMES XplnObj xplnobj
    HINTS ${XPLNOBJ_LIB_SEARCH_HINTS}
    DOC "XplnObj library"
)

if(NOT XPLNOBJ_INCLUDE_DIR OR NOT XPLNOBJ_LIBRARY)
    message(FATAL_ERROR "XplnObj library still not found after setup attempt. Please check the installation manually.")
else()
    message(STATUS "Found XplnObj library:")
    message(STATUS "  Include dir: ${XPLNOBJ_INCLUDE_DIR}")
    message(STATUS "  Library: ${XPLNOBJ_LIBRARY}")
endif()

#----------------------------------------------------------------------------------#
# Info file

include(StsProjectDesc)
include(StsInfoFilesGenerator)
genInfoFile(StsProjectDesc "${CMAKE_SOURCE_DIR}/src/Info.h")

#----------------------------------------------------------------------------------#
#//////////////////////////////////////////////////////////////////////////////////#
#----------------------------------------------------------------------------------#
# options

if (NOT CMAKE_BUILD_TYPE)
	set (CMAKE_BUILD_TYPE Release)
endif()

if (NOT TEST_REPORT_DIR)
	set(TEST_REPORT_DIR ${CMAKE_SOURCE_DIR}/reports/tests)
endif()

if (NOT BUILD_SHARED_LIBS)
	set (BUILD_SHARED_LIBS OFF)
endif()

option(BUILD_TESTS "Build all of it's own tests." OFF)

message(STATUS "==============================================")
message(STATUS "Build type = ${CMAKE_BUILD_TYPE}")
message(STATUS "Build tests = ${BUILD_TESTS}")
message(STATUS "Shared lib = ${BUILD_SHARED_LIBS}")
message(STATUS "Test report dir = ${TEST_REPORT_DIR}")
message(STATUS "Installation prefix = ${CMAKE_INSTALL_PREFIX}")
message(STATUS "==============================================")

#----------------------------------------------------------------------------------#
#//////////////////////////////////////////////////////////////////////////////////#
#----------------------------------------------------------------------------------#
# help targets

add_custom_target("Clean-Install-Dir"
	COMMAND cmake -E remove_directory ${CMAKE_INSTALL_PREFIX}
)

#add_custom_target("CLEAR-TESTS-REPORT"
#	COMMAND cmake -E remove_directory ${TESTS_REPORTS_DIR}
#)

#----------------------------------------------------------------------------------#
#//////////////////////////////////////////////////////////////////////////////////#
#----------------------------------------------------------------------------------#
# Projects

include(Sts3dmaxTarget)

# Build targets for detected SDK versions
if(MAX_SDK_PATHS)
    # Build for all detected SDK versions, but avoid duplicates
    list(LENGTH MAX_SDK_PATHS NUM_DETECTED_SDKS)
    set(PROCESSED_VERSIONS "")
    foreach(INDEX RANGE 0 ${NUM_DETECTED_SDKS})
        if(INDEX LESS ${NUM_DETECTED_SDKS})
            list(GET MAX_SDK_PATHS ${INDEX} CURRENT_SDK_PATH)
            list(GET MAX_SDK_VERSIONS ${INDEX} CURRENT_SDK_VERSION)

            # Check if we've already processed this version
            list(FIND PROCESSED_VERSIONS "${CURRENT_SDK_VERSION}" VERSION_ALREADY_PROCESSED)
            if(VERSION_ALREADY_PROCESSED EQUAL -1)
                # Mark this version as processed
                list(APPEND PROCESSED_VERSIONS "${CURRENT_SDK_VERSION}")

                # Temporarily set the SDK path for this version
                set(MAX_SDK_PATH_BACKUP ${MAX_SDK_PATH})
                set(MAX_SDK_PATH ${CURRENT_SDK_PATH})

                message(STATUS "Setting up target for 3ds Max ${CURRENT_SDK_VERSION} SDK")
                SETUP_MAX_TARGET(SDK_TARGET "3DsMaxSdk${CURRENT_SDK_VERSION}" 3DMAX_VERSION "${CURRENT_SDK_VERSION}")

                # Restore the primary SDK path
                set(MAX_SDK_PATH ${MAX_SDK_PATH_BACKUP})
            endif()
        endif()
    endforeach()
else()
    # Fallback if no SDK was found automatically
    if(MAX_SDK_PATH)
        # Try to detect version from path
        string(REGEX MATCH "20[0-9][0-9]" MAX_VERSION_YEAR "${MAX_SDK_PATH}")
        if(MAX_VERSION_YEAR)
            message(STATUS "Detected 3ds Max ${MAX_VERSION_YEAR} SDK from manually set path")
            SETUP_MAX_TARGET(SDK_TARGET "3DsMaxSdk${MAX_VERSION_YEAR}" 3DMAX_VERSION "${MAX_VERSION_YEAR}")
        else()
            # Fallback - try multiple common versions
            message(STATUS "Could not detect 3ds Max version from path, trying fallback targets...")
            if(EXISTS "${MAX_SDK_PATH}")
                SETUP_MAX_TARGET(SDK_TARGET "3DsMaxSdk2025" 3DMAX_VERSION "2025")
                SETUP_MAX_TARGET(SDK_TARGET "3DsMaxSdk2024" 3DMAX_VERSION "2024")
                SETUP_MAX_TARGET(SDK_TARGET "3DsMaxSdk2023" 3DMAX_VERSION "2023")
                SETUP_MAX_TARGET(SDK_TARGET "3DsMaxSdk2022" 3DMAX_VERSION "2022")
            endif()
        endif()
    endif()
endif()

if (BUILD_TESTS)
	enable_testing()
	add_subdirectory(test)
endif ()

message(STATUS "==============================================")
#-----------------------------------------------------------------------#
# //////////////////////////////////////////////////////////////////////#
#-----------------------------------------------------------------------#
