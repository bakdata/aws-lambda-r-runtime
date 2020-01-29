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
${R_DIR}/bin/Rscript -e 'install.packages("aws.s3", repos="http://cran.r-project.org")'
chmod -R 755 ${BUILD_DIR}/layer/
