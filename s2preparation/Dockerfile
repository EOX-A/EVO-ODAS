FROM ubuntu:16.04

RUN apt-get update \
&& apt-get install -y -o Dpkg::Options::="--force-confnew" software-properties-common --no-install-recommends
RUN apt-add-repository ppa:ubuntugis/ubuntugis-unstable \
&& apt-get update \
&& apt-get install -y -o Dpkg::Options::="--force-confnew" \
        python-pip python-lxml wget \
        python-gdal gdal-bin libgeos-dev libpython-dev libproj-dev python-pyproj python-shapely

RUN pip install https://github.com/constantinius/s2reader/archive/transform.zip

WORKDIR /var