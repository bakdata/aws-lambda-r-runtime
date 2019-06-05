#!/bin/bash

set -euo pipefail

if [[ -z ${1+x} ]];
then
    echo 'version number required'
    exit 1
else
    VERSION=$1
fi

if [[ -z ${2+x} ]];
then
    echo 'bucket name required'
    exit 1
else
    BUCKET=$2
fi

BASE_DIR=$(pwd)
BUILD_DIR=${BASE_DIR}/build/

cd ${BUILD_DIR}/bin/
zip -r R-${VERSION}.zip .
mkdir -p ${BUILD_DIR}/dist/
mv R-${VERSION}.zip ${BUILD_DIR}/dist/
aws s3 cp build/dist/R-${VERSION}.zip s3://${BUCKET}/R-${VERSION}/
