# Sentinel 2 data preparation for EOxServer

This repository provides scripts to download and transform Sentinel-2 data and
metadata for the use with EOxServer.

## Installation

The scripts can either be used as-is or in a specifically set up docker
container, specifically set up to contain all the required dependency software.

For the direct use, the dependencies have to be manually handled, an example
setup script can be found in ``scripts/install-ubuntu.sh``

## Usage

./run.sh -d download_dir/ url-list.txt