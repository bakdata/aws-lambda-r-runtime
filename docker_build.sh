#!/bin/bash

set -euo pipefail

if [[ -z ${1+x} ]];
then
    echo 'version number required'
    exit 1
else
    VERSION=$1
fi

docker build -t lambda-r:build-${VERSION} --build-arg VERSION=${VERSION} .
