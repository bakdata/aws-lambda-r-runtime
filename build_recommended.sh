#!/bin/bash

set -euo pipefail

VERSION=$1

if [ -z "$VERSION" ];
then
    echo 'version number required'
    exit 1
fi

rm -rf R/
rm -rf R.orig/
unzip R-$VERSION.zip -d R.orig/
mkdir -p R/library

recommended=(boot class cluster codetools foreign KernSmooth lattice MASS Matrix mgcv nlme nnet rpart spatial survival)
for package in "${recommended[@]}"
do
   mv R.orig/library/$package/ R/library/$package/
done
chmod -R 755 R/
rm -f recommended.zip
zip -r recommended.zip R/
