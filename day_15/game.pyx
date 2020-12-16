# from libcpp.map cimport map as cpp_map

cpdef play_game_cython(list data, int n_turns):
    # cdef cpp_map[int,int] last_occur = {n: i + 1 for i, n in enumerate(data[:-1])}
    cdef dict last_occur = {n: i + 1 for i, n in enumerate(data[:-1])}
    cdef int cur_number = data[-1]
    cdef int turn = len(data)
    cdef int next_number = 0
    while turn < n_turns:
        if cur_number in last_occur:
            next_number = turn - last_occur[cur_number]
        else:
            next_number = 0

        last_occur[cur_number] = turn
        cur_number = next_number
        turn += 1
    return cur_number
