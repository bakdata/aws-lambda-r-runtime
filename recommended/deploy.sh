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

./build.sh
zip -r -q recommended-${VERSION}.zip R/
mkdir -p ${BUILD_DIR}/dist/
mv recommended-${VERSION}.zip ${BUILD_DIR}/dist/
aws lambda publish-layer-version \
    --layer-name r-recommended-${VERSION} \
    --zip-file fileb://build/dist/recommended-${VERSION}.zip
