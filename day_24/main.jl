module Day24

using DrWatson
quickactivate(@__DIR__)
include(projectdir("misc.jl"))

using ImageFiltering

parse_row(str) = SubString.(str, findall(r"(?:se)|(?:sw)|(?:ne)|(?:nw)|e|w", str))

const cur_day = parse(Int, splitdir(@__DIR__)[end][5:end])
const raw_data = cur_day |> read_input
process_data() = raw_data |> read_lines .|> parse_row
test_data = cur_day |> read_file("test_input.txt") |> read_lines .|> parse_row

function dist(a, b)
    # from https://www.redblobgames.com/grids/hexagons/#distances-axial
    (abs(a[1] - b[1]) + abs(a[1] + a[2] - b[1] - b[2]) + abs(a[2] - b[2])) / 2
end

dist(a) = (abs(a[1]) + abs(a[1] + a[2]) + abs(a[2])) / 2

dir_vec = Dict("nw" => (0, -1), "ne" => (1, -1), "sw" => (-1, 1),
        "se" => (0, 1), "w" => (-1, 0), "e" => (1, 0))
neighbors_vec = [CartesianIndex(i) for i in values(dir_vec)]

function dest_coords(dirs)
    cur_pos = (0, 0)
    dir = dirs[1]
    for dir in dirs
        cur_pos = cur_pos .+ dir_vec[dir]
    end
    cur_pos
end

function part1()
    data = process_data()
    # data = test_data
    blacks = Set{Tuple{Int, Int}}()
    dirs = data[1]
    for d in data
        point = dest_coords(d)
        if point ∈ blacks
            delete!(blacks, point)
        else
            push!(blacks, point)
        end
    end
    length(blacks)
end

get_neighbors(i::CartesianIndex) = [i + j for j in neighbors_vec]

function do_step(blacks)
    new_blacks = copy(blacks)
    i = findfirst(==(true), blacks)
    for i in findall(==(true), blacks)
        black_neighbors = sum(blacks[get_neighbors(i)])
        if black_neighbors == 0 || black_neighbors > 2
            new_blacks[i] = false
        end
        for j in get_neighbors(i)
            blacks[j] == true && continue
            black_neighbors = sum(blacks[get_neighbors(j)])
            if black_neighbors == 2
                new_blacks[j] = true
            end
        end
    end
    new_blacks
end

function part2()
    data = process_data()
    # data = test_data
    blacks = centered(zeros(Bool, 150, 150))

    d = data[1]
    for d in data
        point = dest_coords(d)
        blacks[point...] = !blacks[point...]
    end

    for i in 1:100
        blacks = do_step(blacks)
    end
    sum(blacks)
end


end # module

if false
println(Day24.part1())
Day24.submit(Day24.part1(), Day24.cur_day, 1)
println(Day24.part2())
Day24.submit(Day24.part2(), Day24.cur_day, 2)
end
