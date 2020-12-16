cdef play_game(data, n_turns):
    last_occur = {n: i + 1 for i, n in enumerate(data[:-1])}
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
