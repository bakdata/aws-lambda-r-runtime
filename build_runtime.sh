#!/bin/bash

set -euo pipefail

VERSION=$1

if [ -z "$VERSION" ];
then
    echo 'version number required'
    exit 1
fi

rm -rf R/
unzip R-$VERSION.zip -d R/
rm -r R/doc/manual/
#remove some libraries to save space
recommended=(boot class cluster codetools foreign KernSmooth lattice MASS Matrix mgcv nlme nnet rpart spatial survival)
for package in "${recommended[@]}"
do
   rm -r R/library/$package/
done
chmod -R 755 bootstrap runtime.r R/
rm -f runtime.zip
zip -r runtime.zip runtime.r bootstrap R/
