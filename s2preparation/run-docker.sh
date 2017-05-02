#!/bin/bash -e

if [[ $# -lt 2 ]] || [[ $# -gt 3 ]] ; then
    echo 'Invalid number of arguments given: <url-list> <out-dir> required'
    exit 1
fi

URL_LIST=$1
OUT_DIR=$2
DOWNLOAD_DIR=${3:-./downloads}

URL_LIST_DIR=$(dirname $URL_LIST)
URL_LIST_BASE=$(basename $URL_LIST)

IMAGE_NAME="s2preparation"

if [[ "$(docker images -q $IMAGE_NAME 2> /dev/null)" == "" ]]; then
    echo "Docker image $IMAGE_NAME not found, building it."
    docker build -t $IMAGE_NAME .
fi

docker run \
    -v `pwd`/$OUT_DIR:/var/out \
    -v `pwd`/$DOWNLOAD_DIR:/var/download \
    -v `pwd`/$URL_LIST_DIR:/var/urldir \
    $IMAGE_NAME ./run.sh /var/urldir/$URL_LIST_BASE /var/out /var/download
