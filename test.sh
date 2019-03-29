#!/bin/bash

set -euo pipefail

VERSION=$1

if [ -z "$VERSION" ];
then
    echo 'version number required'
    exit 1
fi

function releaseToRegion {
    version=$1
    region=$2
    layer=$3
    bucket="aws-lambda-r-runtime.$region"
    resource="R-$version/$layer-test.zip"
    layer_name="r-$layer-test-$version"
    layer_name="${layer_name//\./_}"
    echo "publishing layer $layer_name to region $region"
    aws s3 cp $layer.zip s3://$bucket/$resource --region $region
    response=$(aws lambda publish-layer-version --layer-name $layer_name \
        --content S3Bucket=$bucket,S3Key=$resource --region $region)
    version_number=$(jq -r '.Version' <<< "$response")
    layer_arn=$(jq -r '.LayerVersionArn' <<< "$response")
    echo "published layer $layer_arn"
}

region=eu-central-1

releaseToRegion $VERSION $region runtime
runtimeLayer=$layer_arn
runtimeLayerName=$layer_name
runtimeLayerVersion=$version_number
releaseToRegion $VERSION $region recommended
recommendedLayer=$layer_arn
recommendedLayerName=$layer_name
recommendedLayerVersion=$version_number
aws s3 cp s3://aws-lambda-r-runtime/R-$VERSION/awspack.zip .
releaseToRegion $VERSION $region awspack
awsLayer=$layer_arn
awsLayerName=$layer_name
awsLayerVersion=$version_number

./start_server.sh $runtimeLayer $recommendedLayer $awsLayer
python -m unittest discover
aws lambda delete-layer-version --layer-name $runtimeLayerName --version-number $runtimeLayerVersion
aws lambda delete-layer-version --layer-name $recommendedLayerName --version-number $recommendedLayerVersion
aws lambda delete-layer-version --layer-name $awsLayerName --version-number $awsLayerVersion
./stop_server.sh
