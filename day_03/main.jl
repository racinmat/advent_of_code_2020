module Day03

using DrWatson
quickactivate(@__DIR__)
include(projectdir("misc.jl"))

const cur_day = parse(Int, splitdir(@__DIR__)[end][5:end])
const raw_data = cur_day |> read_input
process_data() = raw_data |> replace_chars("."=>"0", "#"=>"1") |>
    read_lines .|> collect .|> (x->parse.(Bool, x)) |> x->hcat(x...)

function check_trees(data, x_diff, y_diff)
    x = 1
    y = 1
    trees = data[y, x]
    w, h = size(data)
    while x < h
        x += x_diff
        y += y_diff
        y = y > w ? y % w : y
        trees += data[y, x]
    end
    trees
end

function part1()
    data = process_data()
    check_trees(data, 1, 3)
end

function part2()
    data = process_data()
    check_trees(data, 1, 1) * check_trees(data, 1, 3) * check_trees(data, 1, 5) * check_trees(data, 1, 7) * check_trees(data, 2, 1)
end


end # module

if false
println(Day03.part1())
Day03.submit(Day03.part1(), Day03.cur_day, 1)
println(Day03.part2())
Day03.submit(Day03.part2(), Day03.cur_day, 2)
end
