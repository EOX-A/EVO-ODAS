#!/bin/bash -e

if [[ $# -ne 2 ]] ; then
    echo 'Invalid number of arguments given: <url-list> <download-dir> required'
    exit 1
fi

URL_LIST=$1
DOWNLOAD_DIR=$2

mkdir -p $DOWNLOAD_DIR

wget --http-user=evouser --http-password=evo16odas! -c -nd -i $URL_LIST -P $DOWNLOAD_DIR
