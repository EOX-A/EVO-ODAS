# Sentinel 2 data preparation for EOxServer

This repository provides scripts to download and transform Sentinel-2 data and
metadata for the use with EOxServer.

## Installation

The scripts can either be used as-is or in a specifically set up docker
container, specifically set up to contain all the required dependency software.

For the direct use, the dependencies have to be manually handled, an example
setup script can be found in ``scripts/install-ubuntu.sh``

## Usage

To run the preprocessing, you first have to obtain a URL-list of SAFE files to
process. Such a file can be obtained from
[CODE-DE](https://code-de.org/en/marketplace/view?filter%5B%5D=satellite%3ASentinel-2&sort=asc%3Atitle).

    scripts/run.sh url-list.txt output_dir/ download_dir/

Before the prepared data can be used the `output_dir/` and the `range_types/`
directories have to be made available for the EOxServer instance.
The preprocessed datasets can now be registered in an EOxServer instance using
the following commands.

    for resolution in 10 20 60 ; do
        python manage.py eoxs_rangetype_load -i range_types/Sentinel-2_${resolution}m.json
    done

    python manage.py eoxs_collection_create -i S2A_OPER

    for resolution in 10 20 60 ; do
        for filename in output_dir/*${resolution}m.tif;  do
            python manage.py eoxs_dataset_register -r Sentinel-2_${resolution}m -d "$filename" -m "${filename//.tif/.xml}" --collection "S2A_OPER" --replace --traceback;
        done
    done


for resolution in 10 20 60 ; do
    python manage.py eoxs_rangetype_load -i /var/s2preparation/range_types/Sentinel-2_${resolution}m.json;
done
python manage.py eoxs_collection_create -i S2A_OPER
for file in /var/data/*10m.tif; do
    filename="$( basename ${file} )"
    id="${filename%.*}"
    python manage.py eoxs_dataset_register -r Sentinel-2_${resolution}m -i ${id} -d "$file" -m "${file//.tif/.xml}" --collection "S2A_OPER" --replace --traceback;
    python manage.py wms_options_set -r 1 -g 2 -b 3 --resampling=AVERAGE --no-auto-scale --min=0 --max=4096 "${id}";
done
for resolution in 20 60 ; do
    for file in /var/data/*${resolution}m.tif; do
        filename="$( basename ${file} )"
        id="${filename%.*}"
        python manage.py eoxs_dataset_register -r Sentinel-2_${resolution}m -i ${id} -d "$file" -m "${file//.tif/.xml}" --replace --traceback;
    done;
done


## Usage with Docker

Since the scripts are based on a Ubuntu setup, a Docker setup is provided to
help use the scripts on other systems as well. To use the Docker version, use
the `scripts/run-docker.sh` script instead of `scripts/run.sh`
