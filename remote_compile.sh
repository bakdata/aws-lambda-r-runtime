#!/bin/bash

set -euo pipefail

if [[ -z ${1+x} ]];
then
    echo 'version number required'
    exit 1
else
    VERSION=$1
fi

if [[ -z ${2+x} ]];
then
    echo 'bucket name required'
    exit 1
else
    BUCKET=$2
fi

if [[ -z ${3+x} ]];
then
    echo 'instance profile required'
    exit 1
else
    PROFILE=$3
fi

aws ec2 run-instances --image-id ami-657bd20a --count 1 --instance-type t2.medium \
    --instance-initiated-shutdown-behavior terminate --iam-instance-profile Name='"'${PROFILE}'"' \
    --user-data '#!/bin/bash
yum install -y git
git clone https://github.com/bakdata/aws-lambda-r-runtime.git
cd aws-lambda-r-runtime/r/
./compile_and_deploy.sh '"$VERSION $BUCKET"'
cd ../awspack/
./compile_and_deploy.sh '"$VERSION $BUCKET"'
systemctl poweroff'
