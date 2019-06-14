#!/bin/bash

set -euo pipefail

if [[ -z ${1+x} ]];
then
    echo 'version number required'
    exit 1
else
    R_VERSION=$1
fi

function integrationTest {
    version=$1
    region=$2
    bucket="aws-lambda-r-runtime.$region"
    echo "Integration testing in region $region"
    sam package \
        --output-template-file packaged.yaml \
        --s3-bucket ${bucket} \
        --s3-prefix R-${version} \
        --template-file test-template.yaml \
        --region ${region}
    version_="${version//\./_}"
    stack_name=r-${version//\./-}-test
    sam deploy \
        --template-file packaged.yaml \
        --stack-name ${stack_name} \
        --capabilities CAPABILITY_IAM \
        --parameter-overrides Version=${version_} \
        --no-fail-on-empty-changeset \
        --region ${region}
    VERSION=${version_} INTEGRATION_TEST=True AWS_DEFAULT_REGION=${region} pipenv run python -m unittest
}

regions=(
          us-east-1
        )

for region in "${regions[@]}"
do
    integrationTest ${R_VERSION} ${region}
done
