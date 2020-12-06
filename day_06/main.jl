module Day06

using DrWatson
quickactivate(@__DIR__)
include(projectdir("misc.jl"))

const cur_day = parse(Int, splitdir(@__DIR__)[end][5:end])
const raw_data = cur_day |> read_input
process_data() = raw_data |> x->read_lines(x, "\n\n") .|> x->split(x, "\n")

function part1()
    data = process_data()
    (data .|> collect .|> x->union(x...)) .|> length |> sum
end

function part2()
    data = process_data()
    (data .|> collect .|> x->intersect(x...)) .|> length |> sum
end


end # module

if false
println(Day06.part1())
Day06.submit(Day06.part1(), Day06.cur_day, 1)
println(Day06.part2())
Day06.submit(Day06.part2(), Day06.cur_day, 2)
end
