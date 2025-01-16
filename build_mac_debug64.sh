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

cd src
vcpkg install
cd ..

VCPKG_INSTALLED_DIR='src/vcpkg_installed/x64-osx'
if [[ $(uname -m) == 'arm64' ]]; then
  VCPKG_INSTALLED_DIR='src/vcpkg_installed/arm64-osx'
fi

BUILD_DIR=cmake-build64
BUILD_TYPE=Debug
PROJECT_DIR=$(pwd)

mkdir $PROJECT_DIR/build/odbc/logs

mkdir $BUILD_DIR
cd $BUILD_DIR
cmake ../src -DCMAKE_INSTALL_PREFIX="${PROJECT_DIR}/${VCPKG_INSTALLED_DIR}" -DCMAKE_BUILD_TYPE="$BUILD_TYPE" -DCODE_COVERAGE="ON" -DBUILD_SHARED_LIBS="OFF" -DWITH_TESTS="ON" -DWITH_ODBC="ON"
make -j 4

RET_CODE=$?

if [ $RET_CODE -ne 0 ]; then
  echo "Error occurred while building macOS x64 project. Exiting."
  exit $RET_CODE
fi

make package

RET_CODE=$?

if [ $RET_CODE -ne 0 ]; then
  echo "Error occurred while building macOS x64 installer. Exiting."
  exit $RET_CODE
fi

cd ..
