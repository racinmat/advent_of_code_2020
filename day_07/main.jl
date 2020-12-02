module Day07

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
println(Day07.part1())
submit(Day07.part1(), Day07.cur_day, 1)
println(Day07.part2())
submit(Day07.part2(), Day07.cur_day, 2)
end
