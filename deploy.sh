#!/bin/bash -e
# deploy script for java openjdk

# Build only downloads and unpacks the code to the install dir.
. /etc/profile.d/modules.sh
SOURCE_FILE=${NAME}-${VERSION}-linux-x64.tar.gz

module add deploy

echo "now deploying to ${SOFT_DIR}"
cd ${WORKSPACE}/${NAME}-${VERSION}
echo "Java $VERSION will now go into ${SOFT_DIR}/"
mkdir -p ${SOFT_DIR}
tar xfz ${SRC_DIR}/${SOURCE_FILE} -C ${SOFT_DIR} --skip-old-files --strip-components=1


# TODO - see if Java works.
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
setenv JAVA_DIR                 $::env(CVMFS_DIR)/$::env(SITE)/$::env(OS)/$::env(ARCH)/$NAME/$VERSION
setenv JAVA_HOME                $::env(CVMFS_DIR)/$::env(SITE)/$::env(OS)/$::env(ARCH)/$NAME/$VERSION
prepend-path LD_LIBRARY_PATH    $::env(JAVA_DIR)/lib
prepend-path PATH               $::env(JAVA_DIR)/bin
MODULE_FILE
) > modules/${VERSION}
mkdir -p ${LIBRARIES_MODULES}/${NAME}
cp modules/${VERSION} ${LIBRARIES_MODULES}/${NAME}

echo "Checking java module"
module add $NAME/$VERSION
module list
echo "which java are we using ? "
which java
echo "which version of java are we using ?"
java -version
