module Day17

using DrWatson
quickactivate(@__DIR__)
include(projectdir("misc.jl"))

using SparseArrays
const cur_day = parse(Int, splitdir(@__DIR__)[end][5:end])
const raw_data = cur_day |> read_input
process_data() = raw_data |> replace_chars("."=>"0", "#"=>"1") |> read_lines .|> collect .|> (x->parse.(Int, x)) |> x->hcat(x...)'
test_data = cur_day |> read_file("test_input.txt") |> replace_chars("."=>"0", "#"=>"1") |> read_lines .|> collect .|> (x->parse.(Int, x)) |> x->hcat(x...)'
using SparseArrayKit

around(i::CartesianIndex, a_size) = around(i.I, a_size)
around(i::Tuple{Int,Int,Int}, a_size) = max(i[1]-1, 1):min(i[1]+1, a_size[1]),max(i[2]-1,1):min(i[2]+1, a_size[2]),max(i[3]-1, 1):min(i[3]+1, a_size[3])
around(i::Tuple{Int,Int,Int,Int}, a_size) = max(i[1]-1, 1):min(i[1]+1, a_size[1]),max(i[2]-1,1):min(i[2]+1, a_size[2]),max(i[3]-1, 1):min(i[3]+1, a_size[3]),max(i[4]-1, 1):min(i[4]+1, a_size[4])
make_offset(i::CartesianIndex{3},j::CartesianIndex{3}) = i.I.+j.I.-(2,2,2)
make_offset(i::CartesianIndex{4},j::CartesianIndex{4}) = i.I.+j.I.-(2,2,2,2)

function do_step(grid)
    new_grid = copy(grid)
    # @inbounds Threads.@threads for i in findall(grid .!= 0)
    # i = findall(grid .== 1)[1]
    # i = CartesianIndex(1,1,1)
    for i in findall(grid .== 1)
        # only 0 next to 1 can be switched to 1
        if 3 <= sum(grid[around(i, size(grid))...]) <= 4
            new_grid[i] = 1
        else
            new_grid[i] = 0
        end
        # j = findall(==(0), grid[around(i, size(grid))...])[1]
        for j in findall(==(0), grid[around(i, size(grid))...])
            k = make_offset(j, i)
            if sum(grid[around(k, size(grid))...]) == 3
                new_grid[k...] = 1
            end
        end
    end
    new_grid
end

function part1()
    data = process_data()
    # data = test_data
    n_steps = 6
    orig_offset = maximum(size(data))
    grid_size = orig_offset + n_steps*2
    grid = SparseArray{Int}(undef, (grid_size, grid_size, grid_size))
    for i in findall(==(1), data)
        grid[i.I[1]+grid_size÷2-orig_offset÷2-1,i.I[2]+grid_size÷2-orig_offset÷2-1,grid_size÷2] = 1
    end
    for i in 1:n_steps
        grid = do_step(grid)
    end
    sum(grid)
end

function part2()
    data = process_data()
    # data = test_data
    n_steps = 6
    orig_offset = maximum(size(data))
    grid_size = orig_offset + n_steps*2
    grid = SparseArray{Int}(undef, (grid_size, grid_size, grid_size, grid_size))
    for i in findall(==(1), data)
        grid[i.I[1]+grid_size÷2-orig_offset÷2-1,i.I[2]+grid_size÷2-orig_offset÷2-1,grid_size÷2,grid_size÷2] = 1
    end
    for i in 1:n_steps
        grid = do_step(grid)
    end
    sum(grid)
end


end # module

if false
println(Day17.part1())
Day17.submit(Day17.part1(), Day17.cur_day, 1)
println(Day17.part2())
Day17.submit(Day17.part2(), Day17.cur_day, 2)
end
