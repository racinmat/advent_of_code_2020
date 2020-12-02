module Day09

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
println(Day09.part1())
submit(Day09.part1(), Day09.cur_day, 1)
println(Day09.part2())
submit(Day09.part2(), Day09.cur_day, 2)
end
