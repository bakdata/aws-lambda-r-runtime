#!/bin/bash

set -euo pipefail

if [[ -z ${1+x} ]];
then
    echo 'version number required'
    exit 1
else
    VERSION=$1
fi

aws s3 cp s3://aws-lambda-r-runtime/R-$VERSION/R-$VERSION.zip .
./build_runtime.sh $VERSION
./build_recommended.sh $VERSION
./unpack_awspack.sh $VERSION
