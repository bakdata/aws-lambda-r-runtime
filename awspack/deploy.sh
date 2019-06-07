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

./build.sh ${VERSION}
zip -r -q awspack-${VERSION}.zip .
mkdir -p ${BUILD_DIR}/dist/
mv awspack-${VERSION}.zip ${BUILD_DIR}/dist/
aws lambda publish-layer-version \
    --layer-name r-awspack-${VERSION} \
    --zip-file fileb://build/dist/awspack-${VERSION}.zip
