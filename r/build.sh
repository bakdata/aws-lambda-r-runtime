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
BUILD_DIR=$BASE_DIR/build/

rm -rf $BUILD_DIR
aws s3 cp s3://aws-lambda-r-runtime/R-$VERSION/R-$VERSION.zip $BUILD_DIR/dist/
unzip -q $BUILD_DIR/dist/R-$VERSION.zip -d $BUILD_DIR/layer/
