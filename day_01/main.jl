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


end # module

if false
println(Day01.part1())
submit(Day01.part1(), Day01.cur_day, 1)
println(Day01.part2())
submit(Day01.part2(), Day01.cur_day, 2)
end
