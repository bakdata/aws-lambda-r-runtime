#!/bin/bash
VERSION=${VERSION:=3.5.1}
rm -r R/
rm -r R.orig/
unzip R-$VERSION.zip -d R.orig/
mkdir -p R/library

recommended=(boot class cluster codetools foreign KernSmooth lattice MASS Matrix mgcv nlme nnet rpart spatial survival)
for package in "${recommended[@]}"
do
   mv R.orig/library/$package/ R/library/$package/
done
chmod -R 755 R/
rm recommended.zip
zip -r recommended.zip R/
aws lambda publish-layer-version --layer-name r-recommended --zip-file fileb://recommended.zip