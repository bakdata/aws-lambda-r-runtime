#!/bin/bash
VERSION=${VERSION:=3.5.1}

./build_runtime.sh $VERSION
aws lambda publish-layer-version --layer-name r-runtime --zip-file fileb://runtime.zip
