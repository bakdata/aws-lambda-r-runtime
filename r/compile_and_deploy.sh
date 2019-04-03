#!/bin/bash

set -euo pipefail

if [[ -z ${1+x} ]];
then
    echo 'version number required'
    exit 1
else
    VERSION=$1
fi

./compile.sh $VERSION
aws s3 cp build/dist/R-$VERSION.zip s3://aws-lambda-r-runtime/R-$VERSION/
