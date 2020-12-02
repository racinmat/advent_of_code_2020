module Day01

using DrWatson
quickactivate(@__DIR__)
include(projectdir("misc.jl"))

using Combinatorics
const cur_day = parse(Int, splitdir(@__DIR__)[end][5:end])
const data = cur_day |> read_input |> x->read_numbers(x, '\n')

function part1()
    for i in combinations(data, 2)
        if sum(i) == 2020
            return prod(i)
        end
    end
end

function part2()
    for i in combinations(data, 3)
        if sum(i) == 2020
            return prod(i)
        end
    end
end

if false
println(part1())
submit(part1(), cur_day, 1)
println(part2())
submit(part2(), cur_day, 2)
end
