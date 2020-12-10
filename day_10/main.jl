module Day10

using DrWatson
quickactivate(@__DIR__)
include(projectdir("misc.jl"))

using StatsBase, DataStructures
const cur_day = parse(Int, splitdir(@__DIR__)[end][5:end])
const raw_data = cur_day |> read_input
process_data() = raw_data |> read_numbers
test_data = cur_day |> read_file("test_input.txt") |> read_numbers
test_data = cur_day |> read_file("test_input_small.txt") |> read_numbers

function part1()
    data = process_data()
    # data = test_data
    data = vcat([0], data, [maximum(data)+3])
    data |> sort |> diff |> countmap |> values |> prod
end

function count_sequence_lengths(arr)
    one_ntuples = DefaultDict{Int, Int}(0)
    is_1 = false
    num_1s = 0
    for i in arr
        if i == 1
            is_1 = true
            num_1s += 1
        else
            is_1 = false
            one_ntuples[num_1s] += 1
            num_1s = 0
        end
    end
    one_ntuples
end

function part2()
    data = process_data()
    # data = test_data
    data = vcat([0], data, [maximum(data)+3])
    diffs = data |> sort |> diff
    # must find all sequences with multiple 1 next to each other, there can be leavout
    one_ntuples = count_sequence_lengths(diffs)
    num_leavouts = 1
    for (key, val) in one_ntuples
        key < 2 && continue
        num_leavouts *= (binomial(key-1,1)+binomial(key-1,2)+1) ^ val
    end

    num_leavouts
end


end # module

if false
println(Day10.part1())
Day10.submit(Day10.part1(), Day10.cur_day, 1)
println(Day10.part2())
Day10.submit(Day10.part2(), Day10.cur_day, 2)
end
