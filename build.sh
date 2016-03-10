#!/bin/bash

# These should be set from the outside. A git version and heroku/travis respectively
if [ -z "$VERSION" ]
then
    VERSION="unknown"
fi
if [ -z "$TARGET" ]
then
    TARGET="unknown"
fi

CCV_REVISION=29b2bca

git clone https://github.com/liuliu/ccv.git
cd ccv/lib
git checkout $CCV_REVISION
./configure
make
cd ~
tar czf libccv-0.1.0.tar.gz -C ccv/lib .
curl -T libccv-0.1.0.tar.gz -u USERNAME:PASSWORD ftp://REMOTE_HOST

if [ -z "$FTP_PASSWORD" ];
then
    echo "FTP_PASSWORD not provided, skipping upload";
else
    curl --ftp-create-dirs -T libccv-${VERSION}-${TARGET}.tgz -u ${FTP_USER}:${FTP_PASSWORD} ${FTP_SERVER}/
fi
