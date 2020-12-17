module Day17

using DrWatson
quickactivate(@__DIR__)
include(projectdir("misc.jl"))

const cur_day = parse(Int, splitdir(@__DIR__)[end][5:end])
const raw_data = cur_day |> read_input
process_data() = raw_data |> replace_chars("."=>"0", "#"=>"1") |> read_lines .|> collect .|> (x->parse.(Int, x)) |> x->hcat(x...)'
test_data = cur_day |> read_file("test_input.txt") |> replace_chars("."=>"0", "L"=>"1") |> read_lines .|> collect .|> (x->parse.(Int, x)) |> x->hcat(x...)'

function part1()
    data = process_data()
end

function part2()
    data = process_data()
end


end # module

if false
println(Day17.part1())
Day17.submit(Day17.part1(), Day17.cur_day, 1)
println(Day17.part2())
Day17.submit(Day17.part2(), Day17.cur_day, 2)
end
