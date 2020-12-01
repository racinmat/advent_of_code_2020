using DrWatson
quickactivate(@__DIR__)
include(projectdir("misc.jl"))

using Combinatorics
const cur_day = parse(Int, splitdir(@__DIR__)[end][5:end])
const data = cur_day |> read_input |> x->read_numbers(x, '\n')

function part1()
    for (i, j) in combinations(data, 2)
        println("$i, $j")
        if i+j == 2020
            return i*j
        end
    end
end

function part2()
    data
end

println(part1())
submit(part1(), cur_day, 1)
println(part2())
submit(part2(), cur_day, 2)
