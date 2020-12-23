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

function do_step!(q, cur_idx)
    @inbounds cur = q[cur_idx]
    @timeit to "pop1" r1 = popat!(q, cur_idx+1 > length(q) ? 1 : cur_idx+1)
    @timeit to "pop2" r2 = popat!(q, cur_idx+1 > length(q) ? 1 : cur_idx+1)
    @timeit to "pop3" r3 = popat!(q, cur_idx+1 > length(q) ? 1 : cur_idx+1)

    dest_val = cur - 1 == 0 ? maximum(q) : cur - 1
    while dest_val == r1 || dest_val == r2 || dest_val == r3
        dest_val = dest_val - 1 == 0 ? maximum(q) : dest_val - 1
    end
    @timeit to "find dest" dest_idx = findfirst(==(dest_val), q)
    insert!(q, dest_idx+1, r1)
    insert!(q, dest_idx+2, r2)
    insert!(q, dest_idx+3, r3)
    @timeit to "find cur" cur_idx = findfirst(==(cur), q)
    cur_idx = cur_idx + 1 > length(q) ? 1 : cur_idx + 1
    cur_idx
end

function part1()
    data = process_data()
    # data = test_data
    # q = CircularDeque{Int}(length(data))
    # for d in data
    #     push!(q, d)
    # end
    # q = CircularBuffer{Int}(length(data))
    q = copy(data)
    cur_idx = 1

    for i in 1:100
        cur_idx = do_step!(q, cur_idx)
    end

    q
    idx1 = findfirst(==(1), q)
    vcat(q[idx1+1:end], q[begin:idx1-1]) .|> string |> x->reduce(*, x)
end

function part2()
    data = process_data()
    # data = test_data
    # q = CircularDeque{Int}(length(data))
    # for d in data
    #     push!(q, d)
    # end
    # q = CircularBuffer{Int}(length(data))
    q = vcat(copy(data),(length(data)+1):1_000)
    # q = vcat(copy(data),(length(data)+1):1_000_000)
    cur_idx = 1

    # for i in 1:10_000_000
    for i in 1:10_000
        @timeit to "do_step!" cur_idx = do_step!(q, cur_idx)
    end

    q
    idx1 = findfirst(==(1), q)
    vcat(q[idx1+1:end], q[begin:idx1-1]) .|> string |> x->reduce(*, x)
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

Day23.reset_timer!(Day23.to)
Day23.part2()
display(Day23.to)

end
