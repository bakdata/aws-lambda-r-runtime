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

instance_id=$(aws ec2 run-instances --image-id ami-657bd20a --count 1 --instance-type t2.medium \
    --instance-initiated-shutdown-behavior terminate --iam-instance-profile Name='"'${PROFILE}'"' \
    --user-data '#!/bin/bash
yum install -y git
git clone https://github.com/bakdata/aws-lambda-r-runtime.git
cd aws-lambda-r-runtime/r/
./compile.sh '"$VERSION"'
cd build/bin/
zip -r R-'"$VERSION"'.zip .
aws s3 cp R-'"$VERSION"'.zip s3://'"$BUCKET"'/R-'"$VERSION"'/
cd ../../../awspack/
./compile_and_deploy.sh '"$VERSION"'
cd build/bin/
zip -r awspack-'"$VERSION"'.zip .
aws s3 cp awspack-'"$VERSION"'.zip s3://'"$BUCKET"'/R-'"$VERSION"'/
shutdown -h now' \
    --query 'Instances[0].InstanceId' --output text)

until aws ec2 wait instance-terminated --instance-ids ${instance_id} 2>/dev/null
do
    echo "Still waiting for $instance_id to terminate"
    sleep 10
done

