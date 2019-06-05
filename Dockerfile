FROM lambci/lambda:build-provided

ARG VERSION=3.6.0
ARG R_DIR=/opt/R/

RUN yum install -y wget readline-devel \
    xorg-x11-server-devel libX11-devel libXt-devel \
    curl-devel \
    gcc-c++ gcc-gfortran \
    zlib-devel bzip2 bzip2-libs \
    openssl-devel libxml2-devel
# workaround for making R build work
# issue seems similar to https://stackoverflow.com/questions/40639138/configure-error-installing-r-3-3-2-on-ubuntu-checking-whether-bzip2-support-suf
RUN yum install -y R

RUN wget https://cran.r-project.org/src/base/R-3/R-${VERSION}.tar.gz && \
    mkdir ${R_DIR} && \
    tar -xf R-${VERSION}.tar.gz && \
    mv R-${VERSION}/* ${R_DIR} && \
    rm R-${VERSION}.tar.gz

WORKDIR ${R_DIR}
RUN ./configure --prefix=${R_DIR} --exec-prefix=${R_DIR} --with-libpth-prefix=/opt/ --enable-R-shlib && \
    make && \
    cp /usr/lib64/libgfortran.so.3 lib/ && \
    cp /usr/lib64/libgomp.so.1 lib/ && \
    cp /usr/lib64/libquadmath.so.0 lib/ && \
    cp /usr/lib64/libstdc++.so.6 lib/ && \
    ./bin/Rscript -e 'install.packages(c("httr", "aws.s3", "logging"), repos="http://cran.r-project.org")'
CMD mkdir -p /var/r/ && \
    cp -r bin/ lib/ etc/ library/ doc/ modules/ share/ /var/r/
