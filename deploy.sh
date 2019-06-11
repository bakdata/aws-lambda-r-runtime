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
        --s3-bucket ${bucket}
    version_="${version//\./_}"
    sam deploy \
        --template-file packaged.yaml \
        --stack-name r-${version} \
        --capabilities CAPABILITY_IAM \
        --parameter-overrides Version=${version_} \
        --region ${region}
    layers=(runtime recommended awspack)
    for layer in "${layers[@]}"
    do
        layer_arn=$(aws cloudformation describe-stacks \
                  --stack-name aws-lambda-r-demo \
                  --query "Stacks[0].Outputs[?OutputKey=='$layer-layer'].OutputValue" \
                  --output text \
                  --region ${region})
        layer_name==${layer_arn%:*}
        version_number=${layer_arn##*:}
        aws lambda add-layer-version-permission \
            --layer-name ${layer_name} \
            --version-number ${version_number} \
            --principal "*" \
            --statement-id publish \
            --action lambda:GetLayerVersion \
            --region ${region}
        echo "published layer $layer_arn"
    done
}

regions=(us-east-1 us-east-2
         us-west-1 us-west-2
         ap-south-1
         ap-northeast-1 ap-northeast-2
         ap-southeast-1 ap-southeast-2
         ca-central-1
         eu-central-1
         eu-north-1
         eu-west-1 eu-west-2 eu-west-3
         sa-east-1)

integration_test=true
for region in "${regions[@]}"
do
    if [[ "$integration_test" = true ]] ; then
        version_="${VERSION//\./_}"
        bucket="aws-lambda-r-runtime.$region"
        sam package \
            --output-template-file packaged.yaml \
            --s3-bucket ${bucket} \
            --template-file test-template.yaml
        sam deploy \
            --template-file packaged.yaml \
            --stack-name r-${version}-test \
            --capabilities CAPABILITY_IAM \
            --parameter-overrides Version=${version_} \
            --region ${region}
        VERSION=version_ INTEGRATION_TEST=True pipenv run python -m unittest
        integration_test=false
    fi
    releaseToRegion ${VERSION} ${region}
done
