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

aws s3 cp ${BUILD_DIR}/dist/awspack.zip s3://${BUCKET}/R-${VERSION}/
