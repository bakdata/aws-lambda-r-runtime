#!/bin/bash

set -euo pipefail

VERSION=$1

if [ -z "$VERSION" ];
then
    echo 'version number required'
    exit 1
fi

wget https://cran.uni-muenster.de/src/base/R-3/R-$VERSION.tar.gz
sudo mkdir /opt/R/
sudo chown $(whoami) /opt/R/
tar -xf R-$VERSION.tar.gz
mv R-$VERSION/* /opt/R/
sudo yum install -y readline-devel \
xorg-x11-server-devel libX11-devel libXt-devel \
curl-devel \
gcc-c++ gcc-gfortran \
zlib-devel bzip2 bzip2-libs
# workaround for making R build work
# issue seems similar to https://stackoverflow.com/questions/40639138/configure-error-installing-r-3-3-2-on-ubuntu-checking-whether-bzip2-support-suf
sudo yum install -y R 

cd /opt/R/
./configure --prefix=/opt/R/ --exec-prefix=/opt/R/ --with-libpth-prefix=/opt/
make
cp /usr/lib64/libgfortran.so.3 lib/
cp /usr/lib64/libgomp.so.1 lib/
cp /usr/lib64/libquadmath.so.0 lib/
cp /usr/lib64/libstdc++.so.6 lib/
sudo yum install -y openssl-devel libxml2-devel
./bin/Rscript -e 'chooseCRANmirror(graphics=FALSE, ind=34); install.packages("httr")'
./bin/Rscript -e 'chooseCRANmirror(graphics=FALSE, ind=34); install.packages("aws.s3")'
zip -r R-$VERSION.zip bin/ lib/ lib64/ etc/ library/ doc/ modules/ share/
