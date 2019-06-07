#!/bin/bash

set -euo pipefail

BASE_DIR=$(pwd)
BUILD_DIR=${BASE_DIR}/build/

rm -rf ${BUILD_DIR}
mkdir -p ${BUILD_DIR}/layer/R/
cp ${BASE_DIR}/src/* ${BUILD_DIR}/layer/
cd ${BUILD_DIR}/layer/
cp -r ${BASE_DIR}/../r/build/bin/* R/
rm -r R/doc/manual/
#remove some libraries to save space
recommended=(boot class cluster codetools foreign KernSmooth lattice MASS Matrix mgcv nlme nnet rpart spatial survival)
for package in "${recommended[@]}"
do
   rm -r R/library/${package}/
done
chmod -R 755 .
