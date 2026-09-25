# Copyright <2022> Amazon.com, Inc. or its affiliates. All Rights Reserved.
# 
# Licensed under the Apache License, Version 2.0 (the "License").
# You may not use this file except in compliance with the License.
# A copy of the License is located at
# 
#    http://www.apache.org/licenses/LICENSE-2.0
# 
# or in the "license" file accompanying this file. This file is distributed
# on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
# express or implied. See the License for the specific language governing
# permissions and limitations under the License.

cmake_minimum_required(VERSION 3.20)

# Update version number in ODBC_DRIVER_VERSION.txt file.
file(STRINGS "${CMAKE_CURRENT_SOURCE_DIR}/ODBC_DRIVER_VERSION.txt" ODBC_DRIVER_VERSION)
string(STRIP ${ODBC_DRIVER_VERSION} ODBC_DRIVER_VERSION)
project(Timestream-ODBC VERSION ${ODBC_DRIVER_VERSION})

# Mac
if (UNIX AND APPLE)
    # AWS SDK headers are provided by find_package (via CMAKE_PREFIX_PATH), so no
    # explicit vcpkg include dir is needed here.

    # Locate the libiodbc headers via the Homebrew prefix so the build works on
    # both Apple Silicon (/opt/homebrew) and Intel (/usr/local) hosts. Fall back
    # to the legacy /usr/local/iODBC path if brew is unavailable.
    find_program(BREW_EXECUTABLE brew)
    if (BREW_EXECUTABLE)
        execute_process(
            COMMAND ${BREW_EXECUTABLE} --prefix libiodbc
            OUTPUT_VARIABLE LIBIODBC_PREFIX
            OUTPUT_STRIP_TRAILING_WHITESPACE
            ERROR_QUIET)
    endif()
    if (LIBIODBC_PREFIX)
        include_directories(${LIBIODBC_PREFIX}/include)
        link_directories(${LIBIODBC_PREFIX}/lib)
    else()
        include_directories(/usr/local/iODBC/include)
    endif()
endif()

# Linux 
if (UNIX AND NOT APPLE)
    if (${BITNESS} EQUAL 64)
        set(OPENSSL_ROOT_DIR ${CMAKE_SOURCE_DIR}/vcpkg_installed/x64-linux)
        include_directories(${CMAKE_SOURCE_DIR}/vcpkg_installed/x64-linux/include)
    else()
        set(OPENSSL_ROOT_DIR ${CMAKE_SOURCE_DIR}/vcpkg_installed/x86-linux)
        include_directories(${CMAKE_SOURCE_DIR}/vcpkg_installed/x86-linux/include)
    endif()
endif()

# Windows
if (WIN32)
    if (CMAKE_SIZEOF_VOID_P EQUAL 8)
      set(VCPKG_TRIPLET_DIR ${CMAKE_SOURCE_DIR}/vcpkg_installed/x64-windows)
    else()
      set(VCPKG_TRIPLET_DIR ${CMAKE_SOURCE_DIR}/vcpkg_installed/x86-windows)
    endif()
    # vcpkg installs debug binaries under a separate debug/ subdirectory. A Debug
    # build must load the debug SDK DLLs (matching /MDd and _ITERATOR_DEBUG_LEVEL=2);
    # loading the release DLLs into a debug driver causes CRT/STL ABI mismatches and
    # access violations at runtime.
    if (CMAKE_BUILD_TYPE STREQUAL "Debug")
      set(AWS_CMAKE_DIR ${VCPKG_TRIPLET_DIR}/debug/lib)
      set(AWS_DLL_DIR ${VCPKG_TRIPLET_DIR}/debug/bin)
      set(AWS_LIB_DIR ${VCPKG_TRIPLET_DIR}/debug/lib)
    else()
      set(AWS_CMAKE_DIR ${VCPKG_TRIPLET_DIR}/lib)
      set(AWS_DLL_DIR ${VCPKG_TRIPLET_DIR}/bin)
      set(AWS_LIB_DIR ${VCPKG_TRIPLET_DIR}/lib)
    endif()
    set(CMAKE_BUILD_DIR ${CMAKE_BINARY_DIR}/${CMAKE_BUILD_TYPE})

    # Copy AWS DLL to ${CMAKE_BUILD_DIR} as they are needed for Windows building and test running.
    configure_file(${AWS_DLL_DIR}/aws-cpp-sdk-core.dll ${CMAKE_BUILD_DIR}/aws-cpp-sdk-core.dll COPYONLY)
    configure_file(${AWS_DLL_DIR}/aws-cpp-sdk-timestream-query.dll ${CMAKE_BUILD_DIR}/aws-cpp-sdk-timestream-query.dll COPYONLY)
    # Timestream-write dll is needed for data writer tool.
    configure_file(${AWS_DLL_DIR}/aws-cpp-sdk-timestream-write.dll ${CMAKE_BUILD_DIR}/aws-cpp-sdk-timestream-write.dll COPYONLY)
    configure_file(${AWS_DLL_DIR}/aws-cpp-sdk-sts.dll ${CMAKE_BUILD_DIR}/aws-cpp-sdk-sts.dll COPYONLY)
    configure_file(${AWS_DLL_DIR}/aws-c-auth.dll ${CMAKE_BUILD_DIR}/aws-c-auth.dll COPYONLY)
    configure_file(${AWS_DLL_DIR}/aws-c-cal.dll ${CMAKE_BUILD_DIR}/aws-c-cal.dll COPYONLY)
    configure_file(${AWS_DLL_DIR}/aws-c-common.dll ${CMAKE_BUILD_DIR}/aws-c-common.dll COPYONLY)
    configure_file(${AWS_DLL_DIR}/aws-c-compression.dll ${CMAKE_BUILD_DIR}/aws-c-compression.dll COPYONLY)
    configure_file(${AWS_DLL_DIR}/aws-c-event-stream.dll ${CMAKE_BUILD_DIR}/aws-c-event-stream.dll COPYONLY)
    configure_file(${AWS_DLL_DIR}/aws-checksums.dll ${CMAKE_BUILD_DIR}/aws-checksums.dll COPYONLY)
    configure_file(${AWS_DLL_DIR}/aws-c-http.dll ${CMAKE_BUILD_DIR}/aws-c-http.dll COPYONLY)
    configure_file(${AWS_DLL_DIR}/aws-c-io.dll ${CMAKE_BUILD_DIR}/aws-c-io.dll COPYONLY)
    configure_file(${AWS_DLL_DIR}/aws-c-mqtt.dll ${CMAKE_BUILD_DIR}/aws-c-mqtt.dll COPYONLY)
    configure_file(${AWS_DLL_DIR}/aws-crt-cpp.dll ${CMAKE_BUILD_DIR}/aws-crt-cpp.dll COPYONLY)
    configure_file(${AWS_DLL_DIR}/aws-c-s3.dll ${CMAKE_BUILD_DIR}/aws-c-s3.dll COPYONLY)
    configure_file(${AWS_DLL_DIR}/aws-c-sdkutils.dll ${CMAKE_BUILD_DIR}/aws-c-sdkutils.dll COPYONLY)
    # zlib1.dll is a transitive runtime dependency of aws-cpp-sdk-core.dll (vcpkg dynamic triplet).
    # vcpkg names the debug build zlibd1.dll and the release build zlib1.dll.
    if (CMAKE_BUILD_TYPE STREQUAL "Debug")
      set(ZLIB_DLL_NAME zlibd1.dll)
    else()
      set(ZLIB_DLL_NAME zlib1.dll)
    endif()
    configure_file(${AWS_DLL_DIR}/${ZLIB_DLL_NAME} ${CMAKE_BUILD_DIR}/${ZLIB_DLL_NAME} COPYONLY)
endif()

include("${CMAKE_CURRENT_SOURCE_DIR}/modules/code-coverage.cmake")
if (NOT "$ENV{BOOST_ROOT}" STREQUAL "")
    set(BOOST_ROOT "$ENV{BOOST_ROOT}")
endif()
set(CMAKE_CXX_STANDARD 11)

set(CMAKE_PROJECT_VERSION ${PROJECT_VERSION})
set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${CMAKE_SOURCE_DIR}/cmake")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -DIGNITE_IMPL -DIGNITE_FRIEND -D__STDC_LIMIT_MACROS -D__STDC_CONSTANT_MACROS")

set(CMAKE_SKIP_BUILD_RPATH FALSE)
set(CMAKE_BUILD_WITH_INSTALL_RPATH FALSE)
# Use a portable, relocatable install RPATH rather than one derived from
# CMAKE_INSTALL_PREFIX. CMAKE_INSTALL_PREFIX is pointed at the vcpkg tree to help
# find_package locate dependencies, so deriving the RPATH from it would bake the
# build machine's (e.g. CI workspace) path into shipped packages. Disabling
# USE_LINK_PATH also prevents vcpkg lib directories from leaking into the RPATH.
if (APPLE)
    set(CMAKE_INSTALL_RPATH "@loader_path;@loader_path/../lib")
else()
    set(CMAKE_INSTALL_RPATH "$ORIGIN;$ORIGIN/../lib")
endif()
set(CMAKE_INSTALL_RPATH_USE_LINK_PATH FALSE)
set(PROJECT_ROOT "${CMAKE_CURRENT_SOURCE_DIR}/..")

add_definitions(-DUNICODE=1)
if (WIN32)

    set (CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR})

    set (CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR})
else()
    set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/../build/odbc/lib")
    set(CMAKE_LIBRARY_OUTPUT_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/../build/odbc/lib")
    set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/../build/odbc/bin")
endif()

if (MSVC)
    add_compile_options(/source-charset:utf-8 /execution-charset:utf-8)

    add_definitions(-D_CRT_SECURE_NO_WARNINGS -D_SCL_SECURE_NO_WARNINGS)

    # The AWS SDK for C++ is consumed from vcpkg as dynamic libraries (DLLs) on
    # Windows. USE_IMPORT_EXPORT makes the SDK headers mark symbols as
    # __declspec(dllimport) so they are resolved from the SDK import libs at link
    # time instead of being emitted into every translation unit. Without it, SDK
    # template instantiations/inline methods get baked into timestream-odbc-static.lib
    # and collide with the SDK import libs (LNK2005 multiply-defined symbols).
    add_definitions(-DUSE_IMPORT_EXPORT)
endif()

option (WITH_ODBC OFF)
option (WITH_ODBC_MSI OFF)
option (WITH_THIN_CLIENT OFF)
option (WITH_TESTS OFF)
option (WARNINGS_AS_ERRORS OFF)

if (${WARNINGS_AS_ERRORS})
    if (MSVC)
        add_compile_options(/WX)
    else()
        add_compile_options(-Wall -Wextra -Werror -Wno-variadic-macros)
    endif()
endif()

if (${WITH_ODBC})
    add_subdirectory(odbc)
endif()

if (${WITH_TESTS})
    enable_testing()

    if (EXISTS ${CMAKE_SOURCE_DIR}/tests)
        add_subdirectory(tests)
    endif()
endif()

