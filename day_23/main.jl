module Day23

using DrWatson
quickactivate(@__DIR__)
include(projectdir("misc.jl"))

using DataStructures
const cur_day = parse(Int, splitdir(@__DIR__)[end][5:end])
const raw_data = cur_day |> read_input
process_data() = raw_data |> collect .|> x->parse(Int, x)
test_data = "389125467" |> collect .|> x->parse(Int, x)

using TimerOutputs
const to = TimerOutput()

function do_step!(q::Vector, cur_idx)
    @inbounds cur = q[cur_idx]
    #=@timeit to "pop1"=# r1 = popat!(q, mod1(cur_idx+1, length(q)))
    #=@timeit to "pop2"=# r2 = popat!(q, mod1(cur_idx+1, length(q)))
    #=@timeit to "pop3"=# r3 = popat!(q, mod1(cur_idx+1, length(q)))

    dest_val = mod1(cur - 1, length(q))
    while dest_val == r1 || dest_val == r2 || dest_val == r3
        dest_val = mod1(dest_val - 1, length(q))
    end
    #=@timeit to "find dest"=# dest_idx = findfirst(==(dest_val), q)
    insert!(q, dest_idx+1, r1)
    insert!(q, dest_idx+2, r2)
    insert!(q, dest_idx+3, r3)
    #=@timeit to "find cur"=# cur_idx = findfirst(==(cur), q)
    cur_idx = cur_idx + 1 > length(q) ? 1 : cur_idx + 1
    cur_idx
end

function do_step!(q::MutableLinkedList)
    cur = first(q)
    rotate_left!(q)

    #=@timeit to "pop1"=# r1 = popfirst!(q)
    #=@timeit to "pop2"=# r2 = popfirst!(q)
    #=@timeit to "pop3"=# r3 = popfirst!(q)

    dest_val = cur - 1 == 0 ? maximum(q) : cur - 1
    while dest_val == r1 || dest_val == r2 || dest_val == r3
        dest_val = dest_val - 1 == 0 ? maximum(q) : dest_val - 1
    end
    #=@timeit to "find dest"=# rotate_left_until!(q, ==(dest_val))
    rotate_left!(q)
    pushfirst!(q, r3)
    pushfirst!(q, r2)
    pushfirst!(q, r1)
    #=@timeit to "find cur"=# rotate_left_until!(q, ==(cur))
    rotate_left!(q)
end

mutable struct StaticLinkedList
    next::Vector{Int}
    head::Int
    tail::Int

    StaticLinkedList(i::Int) = new(zeros(Int, i), 0, 0)
    StaticLinkedList(i::Int, j::Int) = new(zeros(Int, i), j, 0)
    StaticLinkedList(i::Int, j::Int, k::Int) = new(zeros(Int, i), j, k)
end

import Base: length, first, iterate
length(q::StaticLinkedList) = length(q.next)
first(q::StaticLinkedList) = q.head

iterate(q::StaticLinkedList) = length(q) == 0 ? nothing : (q.head, q.next[q.head])
iterate(q::StaticLinkedList, i::Int) = i == 0 ? nothing : (i, i == q.tail ? 0 : q.next[i])

function do_step!(q::StaticLinkedList)
    cur = first(q)

    r1 = q.next[cur]
    r2 = q.next[r1]
    r3 = q.next[r2]
    new_next = q.next[r3]
    q.next[cur] = new_next

    dest_val = mod1(cur - 1, length(q))
    while dest_val == r1 || dest_val == r2 || dest_val == r3
        dest_val = mod1(dest_val - 1, length(q))
    end

    # todo: ošetřit u každého nextu, že to bude nula, a místo toho vzít head
    new_next = q.next[dest_val]
    q.next[dest_val] = r1
    q.next[r3] = new_next

    q.head = q.next[cur]
    # q.next[q.tail] = cur
    q.tail = cur
    # q.next[q.tail] = 0
end

function build_static_linked_list(data)
    q = StaticLinkedList(length(data), first(data), last(data))

    for i in eachindex(data)
        if i == length(data)
            q.next[data[i]] = q.head
        else
            q.next[data[i]] = data[i+1]
        end
    end
    q
end

function part1()
    data = process_data()
    # data = test_data
    q = build_static_linked_list(data)

    for i in 1:100
        do_step!(q)
    end

    q_vec = collect(q)
    idx1 = findfirst(==(1), q_vec)
    vcat(q_vec[idx1+1:end], q_vec[begin:idx1-1]) .|> string |> x->reduce(*, x)
end

function part2()
    data = process_data()
    # data = test_data
    # q = build_static_linked_list(vcat(copy(data),(length(data)+1):1_000))
    q = build_static_linked_list(vcat(copy(data),(length(data)+1):1_000_000))

    for i in 1:10_000_000
    # for i in 1:10_000
        do_step!(q)
    end

    q_vec = collect(q)
    idx1 = findfirst(==(1), q_vec)
    next_1 = q.next[1]
    next_next_1 = q.next[next_1]
    next_1 * next_next_1
end


end # module

if false
println(Day23.part1())
@assert Day23.part1() == "76952348"
Day23.submit(Day23.part1(), Day23.cur_day, 1)
println(Day23.part2())
Day23.submit(Day23.part2(), Day23.cur_day, 2)

using BenchmarkTools
@benchmark Day23.part1()
@btime Day23.part2()
@btime Day23.part2_linked()

Day23.reset_timer!(Day23.to)
Day23.part2()
display(Day23.to)

end
