import time
import timeit

with open('input.txt', 'r') as file:
    raw_data = file.read()


def process_data(): return [int(i) for i in raw_data.split(',')]


def play_game(data, n_turns):
    last_occur = {n: i+1 for i, n in enumerate(data[:-1])}
    cur_number = data[-1]
    turn = len(data)
    while turn < n_turns:
        if cur_number in last_occur.keys():
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


if __name__ == '__main__':
    print(part1())

    start = time.time()
    part1()
    end = time.time()
    print(f"part 1 took: {end - start}")

    print(part2())
    start = time.time()
    part2()
    end = time.time()
    print(f"part 2 took: {end - start}")
# todo: try numba or cython