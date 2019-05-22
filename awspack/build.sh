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

rm -rf ${BUILD_DIR}
aws s3 cp s3://${BUCKET}/R-${VERSION}/awspack.zip ${BUILD_DIR}/dist/
unzip -q ${BUILD_DIR}/dist/awspack.zip -d ${BUILD_DIR}/layer/
