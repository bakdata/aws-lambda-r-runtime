#!/bin/bash
VERSION=${VERSION:=3.5.1}
rm -r R/
unzip R-$VERSION.zip -d R/
rm -r R/doc/manual/
#remove some libraries to save space
recommended=(boot class cluster codetools foreign KernSmooth lattice MASS Matrix mgcv nlme nnet rpart spatial survival)
for package in "${recommended[@]}"
do
   rm -r R/library/$package/
done
chmod -R 755 bootstrap runtime.r R/
rm runtime.zip
zip -r runtime.zip runtime.r bootstrap R/
aws lambda publish-layer-version --layer-name r-runtime --zip-file fileb://runtime.zip
