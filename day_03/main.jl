module Day03

using DrWatson
quickactivate(@__DIR__)
include(projectdir("misc.jl"))

const cur_day = parse(Int, splitdir(@__DIR__)[end][5:end])
# const data = cur_day |> read_input
data = cur_day |> read_input |> x->replace(x, "."=>"0") |> x->replace(x, "#"=>"1") |>
    read_lines .|> collect .|> (x->parse.(Int, x)) |> x->hcat(x...)

function part1()
    x = 1
    y = 1
    trees = data[y, x]
    w, h = size(data)
    while x < h
        x += 1
        y += 3
        y = y > w ? y % w : y
        trees += data[y, x]
    end
    trees
end

function part2()
    data
end


end # module

Day03.data
if false
println(Day03.part1())
Day03.submit(Day03.part1(), Day03.cur_day, 1)
println(Day03.part2())
Day03.submit(Day03.part2(), Day03.cur_day, 2)
end
