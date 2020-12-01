import yaml
from aocd import get_data, submit

with open('secret.yaml', 'r') as f:
    token = yaml.safe_load(f)['session']


def read_day(i: int):
    with open(f'day_{i}/input.txt', 'r', encoding='utf-8') as f:
        in_data = f.read()
    if in_data == '':
        in_data = get_data(token, day=i, year=2019)
        with open(f'day_{i}/input.txt', 'w', encoding='utf-8') as f:
            f.write(in_data)
    return in_data


def submit_day(answer, i: int, part: int):
    parts = {1: 'a', 2: 'b'}
    return submit(answer, part=parts[part], day=i, year=2019, session=token)
