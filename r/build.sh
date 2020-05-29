#!/bin/bash

set -euo pipefail

if [[ -z ${1+x} ]];
then
    echo 'version number required'
    exit 1
else
    VERSION=$1
fi

BASE_DIR=$(pwd)
BUILD_DIR=${BASE_DIR}/build/
R_DIR=/opt/R/

rm -rf ${BUILD_DIR}

mkdir -p ${BUILD_DIR}/layer/R/
docker run --user $(id -u) -v ${BUILD_DIR}/layer/R:/var/r lambda-r:build-${VERSION}

cd ${BUILD_DIR}/layer/
rm -r R/doc/manual/
