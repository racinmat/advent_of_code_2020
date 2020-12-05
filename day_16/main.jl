module Day16

using DrWatson
quickactivate(@__DIR__)
include(projectdir("misc.jl"))

const cur_day = parse(Int, splitdir(@__DIR__)[end][5:end])
const raw_data = cur_day |> read_input
process_data() = raw_data

function part1()
    data = process_data()
end

function part2()
    data = process_data()
end


end # module

if false
println(Day16.part1())
Day16.submit(Day16.part1(), Day16.cur_day, 1)
println(Day16.part2())
Day16.submit(Day16.part2(), Day16.cur_day, 2)
end
