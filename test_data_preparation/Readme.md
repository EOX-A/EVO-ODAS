# Test data generation for the evaluation/benchmarking of EVO-ODAS

## Prerequisites

    pip install pyyaml

## Usage

The `generate_requests.py` script requires a definition file (YAML) which has
the following structure:

```yaml
layer: Sentinel-2
bbox: [10.2, 46.7, 18.0, 49.7]
time: [!!timestamp '2017-05-01T10:00:31', !!timestamp '2017-06-03T10:10:31']
metadata:
  cloudCover:
    min: 0
    max: 100
  orbitDirection:
    - DESCENDING
    - ASCENDING
```


Example for running the script:

```bash
python generate_requests.py sentinel-2.yaml
```
