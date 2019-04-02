#!/bin/bash
VERSION=${VERSION:=3.5.1}

./unpack_awspack.sh $VERSION
aws lambda publish-layer-version --layer-name r-awspack --zip-file fileb://build/layers/awspack.zip
