import sys
import argparse
import itertools
import csv
import random
from datetime import datetime
from pprint import pprint
from collections import namedtuple
import yaml


def main(args):
    parser = argparse.ArgumentParser()

    parser.add_argument(
        'definitions', type=open, nargs='+',
        help='the path to the collection definition'
    )
    parser.add_argument('--randomize', '-r', action='store_true', default=False)
    parser.add_argument('--parts', '-p', type=int, default=3)
    parser.add_argument('--output', type=open, default=sys.stdout)

    parsed = parser.parse_args(args)
    for definition in parsed.definitions:
        generate_requests(
            yaml.load(definition),
            parsed.randomize,
            parsed.parts,
            parsed.output
        )


def split_range(low, high, parts=3):
    delta = (high - low) / parts
    for i in range(parts):
        yield low + delta * i, low + delta * (i + 1)


class BBox(namedtuple('_BBox', ['minx', 'miny', 'maxx', 'maxy'])):
    pass


def value_to_string(value):
    if isinstance(value, basestring):
        return value

    elif isinstance(value, (int, float)):
        return str(value)

    elif isinstance(value, BBox):
        return ",".join(map(str, value))

    low, high = value
    return "[%s,%s]" % (
        low.isoformat('T') if isinstance(low, datetime) else str(low),
        high.isoformat('T') if isinstance(high, datetime) else str(high)
    )


def generate_requests(definition, randomize, rangeparts, output):
    ranges = []
    # bbox
    if 'bbox' in definition:
        bbox = definition['bbox']
        ranges.append({
            'name': 'bbox',
            'values': [
                BBox(x[0], y[0], x[1], y[1])
                for x, y in itertools.product(
                    split_range(bbox[0], bbox[2], rangeparts),
                    split_range(bbox[1], bbox[3], rangeparts)
                )
            ]
        })

    if 'time' in definition:
        time = definition['time']
        ranges.append({
            'name': 'time',
            'values': list(split_range(time[0], time[1], rangeparts))
        })
    #
    # definition.time

    for name, md_definition in definition.get('metadata', {}).items():
        ranges.append({
            'name': name,
            'values': (
                md_definition if isinstance(md_definition, list) else
                list(
                    split_range(
                        md_definition['min'],
                        md_definition['max'],
                        rangeparts
                    )
                )
            )
        })

    for rng in ranges:
        rng['values'] = [
            value_to_string(value)
            for value in rng['values']
        ]
        if rng['name'] == 'time':
            continue
        rng['values'].append(None)

    valuesets = [
        rng['values'] for rng in ranges
    ]

    pr = itertools.product(*valuesets)
    if randomize:
        pr = list(pr)
        random.shuffle(pr)

    layer = definition['layer']
    writer = csv.writer(output)

    writer.writerow(['layer'] + [
        rng['name'] for rng in ranges
    ])
    for row in pr:
        writer.writerow((layer,) + row)



if __name__ == '__main__':
    main(sys.argv[1:])
