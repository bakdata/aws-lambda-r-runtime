#!/bin/bash

set -euo pipefail

if [[ -z ${1+x} ]];
then
    echo 'version number required'
    exit 1
else
    VERSION=$1
fi

BASE_DIR=$(pwd)
BUILD_DIR=${BASE_DIR}/build/

rm -rf ${BUILD_DIR}
mkdir -p ${BUILD_DIR}/layer/
cp ${BASE_DIR}/src/* ${BUILD_DIR}/layer/
cd ${BUILD_DIR}/layer/
unzip -q ${BASE_DIR}/../r/build/dist/R-${VERSION}.zip -d R/
rm -r R/doc/manual/
#remove some libraries to save space
recommended=(boot class cluster codetools foreign KernSmooth lattice MASS Matrix mgcv nlme nnet rpart spatial survival)
for package in "${recommended[@]}"
do
   rm -r R/library/${package}/
done
chmod -R 755 bootstrap runtime.R R/
zip -r -q runtime.zip runtime.R bootstrap R/
mkdir -p ${BUILD_DIR}/dist/
mv runtime.zip ${BUILD_DIR}/dist/
