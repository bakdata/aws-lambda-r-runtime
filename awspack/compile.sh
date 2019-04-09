#!/bin/bash

set -euo pipefail

BASE_DIR=$(pwd)
BUILD_DIR=$BASE_DIR/build/
R_DIR=/opt/R/

rm -rf $BUILD_DIR

export R_LIBS=$BUILD_DIR/layer/R/library
mkdir -p $R_LIBS
$R_DIR/bin/Rscript -e 'chooseCRANmirror(graphics=FALSE, ind=34); install.packages("awspack")'
cd $BUILD_DIR/layer/
zip -r awspack.zip R/
mkdir -p $BUILD_DIR/dist/
mv awspack.zip $BUILD_DIR/dist/
