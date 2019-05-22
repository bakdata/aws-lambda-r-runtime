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
cd ${BASE_DIR}/r
./build.sh ${VERSION} ${BUCKET}
cd ${BASE_DIR}/runtime
./build.sh ${VERSION}
cd ${BASE_DIR}/recommended
./build.sh ${VERSION}
cd ${BASE_DIR}/awspack
./build.sh ${VERSION} ${BUCKET}
