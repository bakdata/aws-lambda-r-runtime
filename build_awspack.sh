#!/bin/bash

set -euo pipefail

export R_LIBS=aws/R/library
mkdir -p $R_LIBS
/opt/R/bin/Rscript -e 'chooseCRANmirror(graphics=FALSE, ind=34); install.packages("awspack")'
cd aws/
zip -r awspack.zip R/
