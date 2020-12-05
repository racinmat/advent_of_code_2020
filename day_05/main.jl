module Day05

using DrWatson
quickactivate(@__DIR__)
include(projectdir("misc.jl"))

const cur_day = parse(Int, splitdir(@__DIR__)[end][5:end])
const raw_data = cur_day |> read_input
process_data() = raw_data |> replace_chars("F"=>"0", "B"=>"1", "L"=>"0", "R"=>"1") |> read_lines .|>
    collect .|> (x->parse.(Int, x)) |> x->hcat(x...)

function make_grid()
    data = process_data()
    row_mul = 6:-1:0 .|> x->2^x
    col_mul = 2:-1:0 .|> x->2^x
    rows = sum(data[1:7,:].*row_mul, dims=1)
    cols = sum(data[8:10,:].*col_mul, dims=1)
    rows .* 8 .+ cols
end

function part1()
    maximum(make_grid())
end

function part2()
    seats = make_grid()
    min_val = minimum(occupied)
    max_val = maximum(occupied)
    first(setdiff(min_val:max_val, seats[:]))
end


end # module

if false
println(Day05.part1())
Day05.submit(Day05.part1(), Day05.cur_day, 1)
println(Day05.part2())
Day05.submit(Day05.part2(), Day05.cur_day, 2)
end
