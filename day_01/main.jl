module Day01

using DrWatson
quickactivate(@__DIR__)
include(projectdir("misc.jl"))

using Combinatorics
const cur_day = parse(Int, splitdir(@__DIR__)[end][5:end])
const data = cur_day |> read_input |> x->read_numbers(x, '\n')

function part1()
    val_min = minimum(data)
    val_max = maximum(data)
    ok_vals = filter(<=(2020 - val_min), data)
    for i in combinations(ok_vals, 2)
        if sum(i) == 2020
            return prod(i)
        end
    end
end

function part2()
    sorted_vals = sort(data)
    val_min = sorted_vals[1]
    val_min_2 = sorted_vals[2]
    val_max = sorted_vals[end]
    ok_vals = filter(<=(2020 - val_min - val_min_2), data)
    for i in combinations(ok_vals, 3)
        if sum(i) == 2020
            return prod(i)
        end
    end
end


end # module

if false
println(Day01.part1())
Day01.submit(Day01.part1(), Day01.cur_day, 1)
println(Day01.part2())
Day01.submit(Day01.part2(), Day01.cur_day, 2)
end
