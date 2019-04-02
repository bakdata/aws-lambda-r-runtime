#!/bin/bash

set -euo pipefail

if [[ -z ${1+x} ]];
then
    echo 'version number required'
    exit 1
else
    VERSION=$1
fi

rm -rf build/awspack/
aws s3 cp s3://aws-lambda-r-runtime/R-$VERSION/awspack.zip build/layers/
unzip -q build/layers/awspack.zip -d build/awspack/
