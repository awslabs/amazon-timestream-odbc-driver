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
  include_directories(AWS_CMAKE_DIR ${CMAKE_SOURCE_DIR}/vcpkg_installed/arm64-osx/include) # TODO: Fix TMP
    include_directories(/usr/local/iODBC/include)
endif()

# Linux 
if (UNIX AND NOT APPLE)
    if (${INSTALLER_TYPE} STREQUAL "RPM" AND ${BITNESS} EQUAL 64)
        set(AWS_CMAKE_DIR ${CMAKE_SOURCE_DIR}/aws-sdk-cpp/install/lib64)
    else()
        set(AWS_CMAKE_DIR ${CMAKE_SOURCE_DIR}/aws-sdk-cpp/install/lib)
    endif()
endif()

# Windows
if (WIN32)
    if (CMAKE_SIZEOF_VOID_P EQUAL 8)
      set(AWS_CMAKE_DIR ${CMAKE_SOURCE_DIR}/vcpkg_installed/x64-windows/lib)
      set(AWS_DLL_DIR ${CMAKE_SOURCE_DIR}/vcpkg_installed/x64-windows/bin)
      set(AWS_LIB_DIR ${CMAKE_SOURCE_DIR}/vcpkg_installed/x64-windows/lib)
    else()
      set(AWS_CMAKE_DIR ${CMAKE_SOURCE_DIR}/vcpkg_installed/x86-windows/lib)
      set(AWS_DLL_DIR ${CMAKE_SOURCE_DIR}/vcpkg_installed/x86-windows/bin)
      set(AWS_LIB_DIR ${CMAKE_SOURCE_DIR}/vcpkg_installed/x86-windows/lib)
    endif()
    set(CMAKE_BUILD_DIR ${CMAKE_BINARY_DIR}/${CMAKE_BUILD_TYPE})

    # copy AWS DLL to ${CMAKE_BUILD_DIR} as they are needed for Windows building and test running
    configure_file(${AWS_DLL_DIR}/aws-cpp-sdk-core.dll ${CMAKE_BUILD_DIR}/aws-cpp-sdk-core.dll COPYONLY)
    configure_file(${AWS_DLL_DIR}/aws-cpp-sdk-timestream-query.dll ${CMAKE_BUILD_DIR}/aws-cpp-sdk-timestream-query.dll COPYONLY)
    # Timestream-write dll is needed for data writer tool
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
set(CMAKE_INSTALL_RPATH "${CMAKE_INSTALL_PREFIX}/lib")
set(CMAKE_INSTALL_RPATH_USE_LINK_PATH TRUE)
set(PROJECT_ROOT "${CMAKE_CURRENT_SOURCE_DIR}/..")

list(FIND CMAKE_PLATFORM_IMPLICIT_LINK_DIRECTORIES "${CMAKE_INSTALL_PREFIX}/lib" isSystemDir)

if("${isSystemDir}" STREQUAL "-1")
    set(CMAKE_INSTALL_RPATH "${CMAKE_INSTALL_PREFIX}/lib")
endif("${isSystemDir}" STREQUAL "-1")

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

