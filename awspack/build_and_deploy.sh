#!/bin/bash

set -euo pipefail

if [[ -z ${1+x} ]];
then
    echo 'version number required'
    exit 1
else
    VERSION=$1
fi

./build.sh $VERSION
aws lambda publish-layer-version --layer-name r-awspack --zip-file fileb://build/dist/awspack.zip
