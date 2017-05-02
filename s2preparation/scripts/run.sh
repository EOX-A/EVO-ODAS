#!/bin/bash -e

if [[ $# -lt 2 ]] || [[ $# -gt 3 ]] ; then
    echo 'Invalid number of arguments given: <url-list> <out-dir> required'
    exit 1
fi

URL_LIST=$1
OUT_DIR=$2
DOWNLOAD_DIR=${3:-./downloads}

scripts/download.sh $URL_LIST $DOWNLOAD_DIR

cat $URL_LIST  | tr -d '\r' | while read line
do
    FILE=$(basename "$line")
    echo "Preparing file ${FILE}"
    scripts/generate-eoom.sh ${DOWNLOAD_DIR}/${FILE} $OUT_DIR
    scripts/prepare-data.sh ${DOWNLOAD_DIR}/${FILE} $OUT_DIR
done
