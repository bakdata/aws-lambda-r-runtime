#!/bin/bash
VERSION=${VERSION:=3.5.1}

./build_recommended.sh $VERSION
aws lambda publish-layer-version --layer-name r-recommended --zip-file fileb://recommended.zip