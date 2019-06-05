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

mkdir -p ${BUILD_DIR}
cd ${BUILD_DIR}
wget https://cran.r-project.org/src/base/R-3/R-${VERSION}.tar.gz
sudo mkdir ${R_DIR}
sudo chown $(whoami) ${R_DIR}
tar -xf R-${VERSION}.tar.gz
mv R-${VERSION}/* ${R_DIR}
rm R-${VERSION}.tar.gz
sudo yum install -y readline-devel \
    xorg-x11-server-devel libX11-devel libXt-devel \
    curl-devel \
    gcc-c++ gcc-gfortran \
    zlib-devel bzip2 bzip2-libs
# workaround for making R build work
# issue seems similar to https://stackoverflow.com/questions/40639138/configure-error-installing-r-3-3-2-on-ubuntu-checking-whether-bzip2-support-suf
sudo yum install -y R 

cd ${R_DIR}
./configure --prefix=${R_DIR} --exec-prefix=${R_DIR} --with-libpth-prefix=/opt/ --enable-R-shlib
make
cp /usr/lib64/libgfortran.so.3 lib/
cp /usr/lib64/libgomp.so.1 lib/
cp /usr/lib64/libquadmath.so.0 lib/
cp /usr/lib64/libstdc++.so.6 lib/
sudo yum install -y openssl-devel libxml2-devel
./bin/Rscript -e 'install.packages(c("httr", "aws.s3", "logging"), repos="http://cran.r-project.org")'

mkdir -p ${BUILD_DIR}/bin/
cp -r bin/ lib/ etc/ library/ doc/ modules/ share/ ${BUILD_DIR}/bin/
