#!/bin/bash

# Copyright <2022> Amazon.com, Inc. or its affiliates. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License").
# You may not use this file except in compliance with the License.
# A copy of the License is located at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# or in the "license" file accompanying this file. This file is distributed
# on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
# express or implied. See the License for the specific language governing
# permissions and limitations under the License.

Usage="Usage: $0 <32|64> <DEBUG|RELEASE> <DEB|RPM>"
if [[ $# -ne 3 ]]; then
  echo "Invalid parameters"
  echo $Usage
  exit 1
fi

BUILD_DIR=cmake-build"$1"
PROJECT_DIR=$(pwd)
DRIVER_BIN_DIR="$PROJECT_DIR/build/odbc/bin"

# TODO: Add 32 Bit
VCPKG_INSTALLED_DIR='src/vcpkg_installed/x64-linux'
if [[ $(uname -m) == 'x86_64' ]]; then
  VCPKG_INSTALLED_DIR='src/vcpkg_installed/x64-linux'
fi

if [[ $2=="DEBUG" ]]; then
  DRIVER_LOG_DIR="$PROJECT_DIR/build/odbc/logs"
  mkdir $DRIVER_LOG_DIR
fi

if [[ $1 -eq 32 ]]; then
  CMAKE_TOOLCHAIN_FILE="$PROJECT_DIR/src/linux_32bit_toolchain.cmake"
fi

# Install VCPKG dependencies
cd src
vcpkg install
cd ..

# build Timestream ODBC driver
mkdir $BUILD_DIR
cd $BUILD_DIR
cmake ../src -DCMAKE_INSTALL_PREFIX="${PROJECT_DIR}/${VCPKG_INSTALLED_DIR}" -DBITNESS=$1 -DCMAKE_BUILD_TYPE=$2 -DCODE_COVERAGE="ON" -DBUILD_SHARED_LIBS="OFF" -DWITH_TESTS="ON" -DWITH_ODBC="ON" -DCMAKE_TOOLCHAIN_FILE="$CMAKE_TOOLCHAIN_FILE" -DINSTALLER_TYPE=$3
make -j 4

RET_CODE=$?

if [ $RET_CODE -ne 0 ]; then
  echo "Error occurred while building project. Exiting."
  exit $RET_CODE
fi

make package

RET_CODE=$?

if [ $RET_CODE -ne 0 ]; then
  echo "Error occurred while building package. Exiting."
  exit $RET_CODE
fi

LOWER_CASE_SUFFIX=$(echo $3 | tr '[:upper:]' '[:lower:]')
cp *.${LOWER_CASE_SUFFIX} $DRIVER_BIN_DIR
cd ..
