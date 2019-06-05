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

mkdir -p ${BUILD_DIR}/bin/
docker run -v ${BUILD_DIR}/bin/:/var/r lambda-r:build-${VERSION}
sudo chown -R $(whoami):$(whoami) ${BUILD_DIR}/bin/
