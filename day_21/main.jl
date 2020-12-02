module Day21

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

if false
println(part1())
submit(part1(), cur_day, 1)
println(part2())
submit(part2(), cur_day, 2)
end
