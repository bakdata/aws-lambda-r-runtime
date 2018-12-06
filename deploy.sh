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
    resource="R-$version/$layer.zip"
    layer_name="test-r-$layer-$version"
    layer_name="${layer_name//\./_}"
    echo "publishing layer $layer_name to region $region"
    aws s3 cp $layer.zip s3://$bucket/$resource --region $region
    response=$(aws lambda publish-layer-version --layer-name $layer_name \
        --content S3Bucket=$bucket,S3Key=$resource --region $region)
    version_number=$(jq -r '.Version' <<< "$response")
    aws lambda add-layer-version-permission --layer-name $layer_name \
        --version-number $version_number --principal "*" \
        --statement-id publish --action lambda:GetLayerVersion \
        --region $region
    layer_arn=$(jq -r '.LayerVersionArn' <<< "$response")
    echo "published layer $layer_arn"
}

regions=(us-east-1 us-east-2
         us-west-1 us-west-2 
         ap-south-1 
         ap-northeast-1 ap-northeast-2 
         ap-southeast-1 ap-southeast-2 
         ca-central-1 
         eu-central-1 
         eu-west-1 eu-west-2 eu-west-3 
         sa-east-1)
regions=(us-east-2)

for region in "${regions[@]}"
do
   releaseToRegion $VERSION $region runtime
   releaseToRegion $VERSION $region recommended
done
