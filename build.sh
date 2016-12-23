#!/bin/bash

# Based on https://gist.github.com/chrismdp/6c6b6c825b07f680e710
function putS3 {
  file=$1
  aws_path=$2
  aws_id=$3
  aws_token=$4
  aws_bucket=$5
  date=$(date +"%a, %d %b %Y %T %z")
  acl="x-amz-acl:public-read"
  content_type='application/x-compressed-tar'
  string="PUT\n\n$content_type\n$date\n$acl\n/$aws_bucket$aws_path$file"
  signature=$(echo -en "${string}" | openssl sha1 -hmac "${aws_token}" -binary | base64)
  curl -X PUT -T "$file" \
    -H "Host: $aws_bucket.s3.amazonaws.com" \
    -H "Date: $date" \
    -H "Content-Type: $content_type" \
    -H "$acl" \
    -H "Authorization: AWS ${aws_id}:$signature" \
    "https://$aws_bucket.s3.amazonaws.com$aws_path$file"
  echo "Uploaded to https://$aws_bucket.s3.amazonaws.com$aws_path$file"
}

# These should be set from the outside. A git version and heroku/travis respectively
if [ -z "$VERSION" ]
then
    VERSION="unknown"
fi
if [ -z "$TARGET" ]
then
    TARGET="unknown"
fi

CCV_REVISION=07fc691

git clone https://github.com/liuliu/ccv.git
cd ccv/lib
git checkout $CCV_REVISION
./configure
echo "Configured..."
make -j4
echo "Built..."
cd -
echo "Right dir..."
tar czf libccv-${VERSION}-${TARGET}.tgz -C ccv/lib .
echo "Packing..."

if [ -z "$AMAZON_API_TOKEN" ];
then
    echo "Amazon API Token not provided, skipping upload";
else
    putS3 "libccv-${VERSION}-${TARGET}.tgz" "/bundles/" $AMAZON_API_ID $AMAZON_API_TOKEN $AMAZON_API_BUCKET
    echo "Success!"
fi
echo "End."
