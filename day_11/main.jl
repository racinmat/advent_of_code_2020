module Day11

using DrWatson
quickactivate(@__DIR__)
include(projectdir("misc.jl"))

const cur_day = parse(Int, splitdir(@__DIR__)[end][5:end])
const data = cur_day |> read_input

function part1()
    data
end

function part2()
    data
end


end # module

if false
println(Day11.part1())
submit(Day11.part1(), Day11.cur_day, 1)
println(Day11.part2())
submit(Day11.part2(), Day11.cur_day, 2)
end
