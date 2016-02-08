#!/bin/bash -e
# build script for java
# Java has some really messed up dependencies like cpus - wtf, seriously ? - so, we are going against the grain
# of CODE-RADE here by deploying pre-packaged binary files.

# Build only downloads and unpacks the code to the install dir.
. /etc/profile.d/modules.sh
# NAME is set to jdk in the jenkins job
# VERSION is set to
# 8u66 7u51
# in the jenkins job

SOURCE_FILE=${NAME}-${VERSION}-linux-x64.tar.gz
module load ci
mkdir -p ${SRC_DIR}
echo "getting the file from gnu.org mirror"

if [ ! -e ${SRC_DIR}/${SOURCE_FILE}.lock ] && [ ! -s ${SRC_DIR}/${SOURCE_FILE} ] ; then
# claim the download
  touch  ${SRC_DIR}/${SOURCE_FILE}.lock
  wget --no-cookies --no-check-certificate --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" "http://download.oracle.com/otn-pub/java/jdk/8u66-b17/jdk-8u66-linux-x64.tar.gz" -O ${SRC_DIR}/${SOURCE_FILE}
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
