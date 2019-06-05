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
R_DIR=/opt/R/

rm -rf ${BUILD_DIR}

export R_LIBS=${BUILD_DIR}/layer/R/library
mkdir -p ${R_LIBS}
${R_DIR}/bin/Rscript -e 'install.packages("awspack", repos="http://cran.r-project.org")'
cd ${BUILD_DIR}/layer/
chmod -R 755 .
zip -r -q awspack-${VERSION}.zip .
mkdir -p ${BUILD_DIR}/dist/
mv awspack-${VERSION}.zip ${BUILD_DIR}/dist/
