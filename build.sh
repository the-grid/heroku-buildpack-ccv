#!/bin/bash

# On your local machine, create a Heroku app to stage the buildpack
#
#    heroku create buildpack-stage
#
# And ssh to it
#
#    heroku run bash --app buildpack-stage
#
# Now run the following script, changing username and host as expected...

git clone https://github.com/liuliu/ccv.git
cd ccv/lib
./configure
make
cd ~
tar czf libccv-0.1.0.tar.gz -C ccv/lib .
curl -T libccv-0.1.0.tar.gz -u USERNAME:PASSWORD ftp://REMOTE_HOST
