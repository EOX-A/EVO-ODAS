#!/bin/bash

if [[ $# -ne 2 ]] ; then
    echo 'Invalid number of arguments given: <safe-package> <out-dir> required'
    exit 1
fi

SAFE_PKG=$1
OUT_DIR=$2

mkdir -p $OUT_DIR

for resolution in 10 20 60 ; do
    s2_transform --resolution $resolution --out-file "${OUT_DIR}/$(basename "$SAFE_PKG")__${resolution}m.xml" --single-granule $SAFE_PKG
done
