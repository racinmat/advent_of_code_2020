module Day12

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
println(Day12.part1())
Day12.submit(Day12.part1(), Day12.cur_day, 1)
println(Day12.part2())
Day12.submit(Day12.part2(), Day12.cur_day, 2)
end
