#!/bin/bash

if [[ $# -ne 2 ]] ; then
    echo 'Invalid number of arguments given: <url-list> <download-dir> required'
    exit 1
fi

URL_LIST=$1
DOWNLOAD_DIR=$2

mkdir -p $DOWNLOAD_DIR

wget -nc -nd -i $URL_LIST -P $DOWNLOAD_DIR
