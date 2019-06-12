#!/bin/bash

set -euo pipefail

BASE_DIR=$(pwd)
BUILD_DIR=${BASE_DIR}/build/

rm -rf ${BUILD_DIR}
mkdir -p ${BUILD_DIR}/layer/R.orig/
cd ${BUILD_DIR}/layer/
cp -r ${BASE_DIR}/../r/build/bin/* R.orig/
mkdir -p R/library

recommended=(boot class cluster codetools foreign KernSmooth lattice MASS Matrix mgcv nlme nnet rpart spatial survival)
for package in "${recommended[@]}"
do
   mv R.orig/library/${package}/ R/library/${package}/
done
rm -rf R.orig/
chmod -R 755 .
