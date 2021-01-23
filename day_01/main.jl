module Day01

using DrWatson
quickactivate(@__DIR__)
include(projectdir("misc.jl"))

using Combinatorics
const cur_day = parse(Int, splitdir(@__DIR__)[end][5:end])
const raw_data = cur_day |> read_input
process_data() = raw_data |> x->read_numbers(x, '\n')

function part1()
    data = process_data()
    val_min = minimum(data)
    val_max = maximum(data)
    ok_vals = filter(<=(2020 - val_min), data)
    for i in combinations(ok_vals, 2)
        sum(i) == 2020 && return prod(i)
    end
end

function part2()
    data = process_data()
    sorted_vals = sort(data)
    val_min = sorted_vals[1]
    val_min_2 = sorted_vals[2]
    val_max = sorted_vals[end]
    ok_vals = filter(<=(2020 - val_min - val_min_2), data)
    # around 12x faster than simply
    # for i in combinations(ok_vals, 3)
    #     sum(i) == 2020 && return prod(i)
    # end
    for i in combinations(ok_vals, 2)
        sum(i) >= val_max && continue
        for j in ok_vals
            sum(i)+j == 2020 && return prod(i)*j
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
