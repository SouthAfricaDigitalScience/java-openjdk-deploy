#!/bin/bash -e
# Copyright 2016 C.S.I.R. Meraka Institute
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# build script for java
# Java has some really messed up dependencies like cpus - wtf, seriously ? - so, we are going against the grain
# of CODE-RADE here by deploying pre-packaged binary files.

# Build only downloads and unpacks the code to the install dir.
. /etc/profile.d/modules.sh
# NAME is set to jdk in the jenkins job
# VERSION is set to
# 8u66 7u51
# in the jenkins job

# we need to set the build number for the different versions. The build number corresponds to a specfic
# version, so we can't just add a variable axis... since there are only two, we have a simple case here :

# BUILD_NUMBER is an internal Jenkins variable, don't use it here.
case ${VERSION} in
  8u66 )
    export BUILD=17
    ;;
  7u80 )
    export BUILD=15
    ;;
  * )
    echo "invalid version number ${VERSION}"
    exit 2
    ;;
esac

echo "build number is ${BUILD_NUMBER}"
SOURCE_FILE=${NAME}-${VERSION}-linux-x64.tar.gz
module load ci
mkdir -p ${SRC_DIR}
echo "getting the file from Oracle"

if [ ! -e ${SRC_DIR}/${SOURCE_FILE}.lock ] && [ ! -s ${SRC_DIR}/${SOURCE_FILE} ] ; then
# claim the download
  touch  ${SRC_DIR}/${SOURCE_FILE}.lock
  wget --no-cookies --no-check-certificate --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" "http://download.oracle.com/otn-pub/java/jdk/${VERSION}-b${BUILD}/${SOURCE_FILE}" -O ${SRC_DIR}/${SOURCE_FILE}
  echo "releasing lock"
  rm -v ${SRC_DIR}/${SOURCE_FILE}.lock
elif [ -e ${SRC_DIR}/${SOURCE_FILE}.lock ] ; then
  # Someone else has the file, wait till it's released
  while [ -e ${SRC_DIR}/${SOURCE_FILE}.lock ] ; do
    echo " There seems to be a download currently under way, will check again in 5 sec"
    sleep 5
  done
fi

mkdir -p ${WORKSPACE}/${NAME}-${VERSION}
# the name of the tar upack dir is some wierd combination of underscores and numbers, so we'll just redefined where
# the code gets unpacked
tar xfz ${SRC_DIR}/${SOURCE_FILE} -C ${WORKSPACE}/${NAME}-${VERSION} --skip-old-files --strip-components=1
cd ${WORKSPACE}/${NAME}-${VERSION}
# TODO - see if Java works.
bin/java -version
