#!/bin/bash

set -euo pipefail

VERSION=$1

if [ -z "$VERSION" ];
then
    echo 'version number required'
    exit 1
fi

./build_awspack.sh
aws s3 cp awspack.zip s3://aws-lambda-r-runtime/R-$VERSION/
