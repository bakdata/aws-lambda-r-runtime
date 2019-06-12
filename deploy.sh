#!/bin/bash

set -euo pipefail

if [[ -z ${1+x} ]];
then
    echo 'version number required'
    exit 1
else
    VERSION=$1
fi

function releaseToRegion {
    version=$1
    region=$2
    bucket="aws-lambda-r-runtime.$region"
    echo "publishing layers to region $region"
    sam package \
        --output-template-file packaged.yaml \
        --s3-bucket ${bucket} \
        --region ${region}
    version_="${version//\./_}"
    stack_name=r-${version//\./-}
    sam deploy \
        --template-file packaged.yaml \
        --stack-name ${stack_name} \
        --parameter-overrides Version=${version_} \
        --no-fail-on-empty-changeset \
        --region ${region}
    layers=(runtime recommended awspack)
    echo "Published layers:"
    aws cloudformation describe-stack-resources \
        --stack-name ${stack_name} \
        --query "StackResources[?ResourceType=='AWS::Lambda::LayerVersion'].PhysicalResourceId" \
        --region ${region}
}

regions=(
          us-east-1 us-east-2
          us-west-1 us-west-2
          ap-south-1
          ap-northeast-1 ap-northeast-2
          ap-southeast-1 ap-southeast-2
          ca-central-1
          eu-central-1
          eu-north-1
          eu-west-1 eu-west-2 eu-west-3
          sa-east-1
        )

for region in "${regions[@]}"
do
    releaseToRegion ${VERSION} ${region}
done
