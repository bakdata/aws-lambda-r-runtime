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
BUILD_DIR=$BASE_DIR/build/

rm -rf $BUILD_DIR
mkdir -p $BUILD_DIR/layer/
cd $BUILD_DIR/layer/
unzip -q $BASE_DIR/../r/build/dist/R-$VERSION.zip -d R.orig/
mkdir -p R/library

recommended=(boot class cluster codetools foreign KernSmooth lattice MASS Matrix mgcv nlme nnet rpart spatial survival)
for package in "${recommended[@]}"
do
   mv R.orig/library/$package/ R/library/$package/
done
rm -rf R.orig/
chmod -R 755 R/
zip -r -q recommended.zip R/
mkdir -p $BUILD_DIR/dist/
mv recommended.zip $BUILD_DIR/dist/
