apt-get update
apt-get install -y software-properties-common --no-install-recommends
apt-add-repository ppa:ubuntugis/ubuntugis-unstable
apt-get update
apt-get install -y \
    python-pip python-lxml wget \
    python-gdal gdal-bin libgeos-dev libpython-dev libproj-dev python-pyproj python-shapely

pip install -r requirements.txt