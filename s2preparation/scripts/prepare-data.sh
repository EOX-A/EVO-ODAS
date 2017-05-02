#!/bin/bash

if [[ $# -ne 2 ]] ; then
    echo 'Invalid number of arguments given: <safe-package> <out-dir> required'
    exit 1
fi

SAFE_PKG=$1
OUT_DIR=$2

mkdir -p OUT_DIR

BASENAME=$(basename "$SAFE_PKG")
EXT="${SAFE_PKG##*.}"


# treat zipped SAFE differently
if [ "$EXT" == "zip" ] ; then
    BASE_PATH="/vsizip/$SAFE_PKG/${BASENAME%.*}/MTD_MSIL1C.xml"
else
    BASE_PATH="$SAFE_PKG/MTD_MSIL1C.xml"
fi

# iterate over all resolutions
for resolution in 10 20 60 ; do
    # iterate over all granules
    for SUBDATASET_FULL in `gdalinfo $BASE_PATH | grep ":${resolution}m:"` ; do
        # extract subdataset that we can use for further GDAL commands
        SUBDATASET="${SUBDATASET_FULL#*=}"


        # TODO: level2 c products are mosaiced in GDAL and can be composed of
        # multiple granules. So this won't work
        # # extract the Granule identifier from the contributing filenames
        # GRANULE_ID=`gdalinfo $SUBDATASET | grep GRANULE | head -1`
        # GRANULE_ID="$(dirname $GRANULE_ID)"
        # GRANULE_ID="$(basename $GRANULE_ID)"

        # perform data extraction
        gdal_translate $SUBDATASET "$OUT_DIR/${BASENAME}__${resolution}m.tif" \
                 -co TILED=YES --config GDAL_CACHEMAX 1000 --config GDAL_NUM_THREADS 4 \
                 -co COMPRESS=LZW
    done
done
