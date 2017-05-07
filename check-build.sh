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

. /etc/profile.d/modules.sh
module add ci
SOURCE_FILE=${NAME}-${VERSION}-linux-x64.tar.gz
mkdir -p ${SOFT_DIR}
tar xfz ${SRC_DIR}/${SOURCE_FILE} -C ${SOFT_DIR} --skip-old-files --strip-components=1
echo "making module"
mkdir -p modules
(
cat <<MODULE_FILE
#%Module1.0
## $NAME modulefile
##
proc ModulesHelp { } {
puts stderr " This module does nothing but alert the user"
puts stderr " that the [module-info name] module is not available"
}
module-whatis "$NAME $VERSION."
setenv JAVA_VERSION $VERSION
setenv JAVA_DIR                                 /data/ci-build/$::env(SITE)/$::env(OS)/$::env(ARCH)/$NAME/$VERSION
setenv JAVA_HOME                           /data/ci-build/$::env(SITE)/$::env(OS)/$::env(ARCH)/$NAME/$VERSION
prepend-path LD_LIBRARY_PATH    $::env(JAVA_DIR)/lib
prepend-path PATH                            $::env(JAVA_DIR)/bin
MODULE_FILE
) > modules/${VERSION}
mkdir -vp ${LIBRARIES}/${NAME}
cp modules/${VERSION} ${LIBRARIES}/${NAME}

echo "Checking java module"
module add $NAME/$VERSION
module list
echo "which java are we using ? "
which java
echo "which version of java are we using ?"
java -version
