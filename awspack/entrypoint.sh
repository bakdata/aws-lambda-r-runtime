#!/bin/bash

set -euo pipefail

BUILD_DIR=/var/awspack/
R_DIR=/opt/R/

export R_LIBS=${BUILD_DIR}/R/library
mkdir -p ${R_LIBS}
${R_DIR}/bin/Rscript -e 'install.packages("aws.s3", repos="http://cran.r-project.org")'
