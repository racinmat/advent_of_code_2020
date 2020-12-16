import time
from numba import jit
from numba.core import types
from numba.typed import Dict

from game import play_game_cython

with open('input.txt', 'r') as file:
    raw_data = file.read()


def process_data(): return [int(i) for i in raw_data.split(',')]


def play_game(data, n_turns):
    last_occur = {n: i + 1 for i, n in enumerate(data[:-1])}
    cur_number = data[-1]
    turn = len(data)
    while turn < n_turns:
        if cur_number in last_occur:
            next_number = turn - last_occur[cur_number]
        else:
            next_number = 0

        last_occur[cur_number] = turn
        cur_number = next_number
        turn += 1
    return cur_number


@jit(nopython=True)
def play_game_numba(data, n_turns):
    # dict comprehension is not supported in numba, see https://github.com/numba/numba/issues/5135
    last_occur = Dict.empty(
        key_type=types.int64,
        value_type=types.int64,
    )
    for i, n in enumerate(data[:-1]):
        last_occur[n] = i + 1
    cur_number = data[-1]
    turn = len(data)
    while turn < n_turns:
        last_occur.keys()
        if cur_number in last_occur:
            next_number = turn - last_occur[cur_number]
        else:
            next_number = 0

        last_occur[cur_number] = turn
        cur_number = next_number
        turn += 1
    return cur_number


def part1():
    data = process_data()
    # data = test_data
    return play_game(data, 2020)


def part2():
    data = process_data()
    return play_game(data, 30_000_000)


def part2_numba():
    data = process_data()
    return play_game_numba(data, 30_000_000)


def part2_cython():
    data = process_data()
    return play_game_cython(data, 30_000_000)


if __name__ == '__main__':
    print(part1())

    start = time.time()
    [part1() for i in range(5)]
    end = time.time()
    print(f"part 1: 5 runs, average millis: {(end - start) / 5}")

    print(part2_numba())
    start = time.time()
    [part2_numba() for i in range(5)]
    end = time.time()
    print(f"part 2 in numba: 5 runs, average millis: {(end - start) / 5}")

    print(part2_cython())
    start = time.time()
    [part2_cython() for i in range(5)]
    end = time.time()
    print(f"part 2 in numba: 5 runs, average millis: {(end - start) / 5}")

    print(part2())
    start = time.time()
    [part2() for i in range(5)]
    end = time.time()
    print(f"part 2: 5 runs, average millis: {(end - start) / 5}")
# todo: try numba or cython
