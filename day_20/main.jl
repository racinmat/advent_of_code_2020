module Day20

using DrWatson
quickactivate(@__DIR__)
include(projectdir("misc.jl"))

using Base.Iterators, StatsBase

function read_tile(str)
    lines = read_lines(str)
    tile_desc = first(lines)
    m = match(r"Tile (\d+):", tile_desc)
    grid = lines[2:end] .|> replace_chars("."=>"0", "#"=>"1") .|> collect .|> (x->parse.(Int, x)) |> x->hcat(x...)'
    parse(Int, m[1]) => grid
end

const cur_day = parse(Int, splitdir(@__DIR__)[end][5:end])
const raw_data = cur_day |> read_input
process_data() = raw_data |> x->split(x, "\n\n") .|> read_tile
test_data = cur_day |> read_file("test_input.txt") |> x->split(x, "\n\n") .|> read_tile

# semantics:
# the are 8 symmetries, and 8 "borders" we can consider, 4 corders and 4 borders reversed
# for tile
#  N
# W E
#  S
# and reversed versions -R, 8 borders are in following order:
# N, S, W, E, NR, SR, WR, ER

# so orientation semantics is: or maybe figure out different numbers so it goes better with the rest of arithmetics
#  1    2    3    4    5    6    7    8
#  N    E    S    W    N    E    S    W
# W E  N S  E W  S N  E W  S N  W E  N S
#  S    W    N    E    S    W    N    E
#  maybe simple lookup table for everything will be enough

all_borders_not_reversed(v) = v[1,:],v[end,:],v[:,1],v[:,end]
all_borders_reversed(v) = v[1,end:-1:1],v[end,end:-1:1],v[end:-1:1,1],v[end:-1:1,end]

other_tile_borders(tile_borders, id) = flatten(v for (k, v) in tile_borders if k != id)

dir2idx = Dict(
    CartesianIndex(-1, 0)=>1,
    CartesianIndex(1, 0)=>2,
    CartesianIndex(0, -1)=>4,
    CartesianIndex(0, 1)=>3,
)
# todo: figure out how to convert spatial orientation to indexes

# evaluating only free slots in grid
# alignment matrix has 1 on (k,l)th position if k-th index of old tile aligns with l-th index of new tile
# if orientation of old tile is 1
# and the new tile is in west, I'm interested in alignment between indices ()

function get_0s_in_4neighborhood(m, i)
    neighbors = CartesianIndex[]
    i.I[1] > 1 && push!(neighbors, CartesianIndex(-1, 0))
    i.I[2] > 1 && push!(neighbors, CartesianIndex(0, -1))
    i.I[1] < size(m)[1] && push!(neighbors, CartesianIndex(1, 0))
    i.I[2] < size(m)[2] && push!(neighbors, CartesianIndex(0, 1))
    [j for j in neighbors if m[i+j] == 0]
end

function part1()
    data = process_data()
    # data = test_data
    tiles = Dict(data)
    tiles

    tile_borders = Dict(k=>[all_borders_not_reversed(v)..., all_borders_reversed(v)...] for (k, v) in tiles)
    # display(tiles[2729])
    borders_match = Dict(k=>v .∈ Ref(other_tile_borders(tile_borders, k)) for (k, v) in tile_borders)
    # display(borders_match)
    non_fitting_borders = Dict(k=> 8 .- sum(v) for (k, v) in borders_match)
    # any(non_fitting_borders[2729] .== 2)
    edge_tiles = Dict(k=>v for (k, v) in non_fitting_borders if v .== 4)
    @assert length(edge_tiles) == 4
    prod(keys(edge_tiles))
end

function part2()
    data = process_data()
    data = test_data
    tiles = Dict(data)

    tile_borders = Dict(k=>[all_borders_not_reversed(v)..., all_borders_reversed(v)...] for (k, v) in tiles)
    # display(tiles[2729])
    borders_match = Dict(k=>v .∈ Ref(other_tile_borders(tile_borders, k)) for (k, v) in tile_borders)
    # display(borders_match)
    non_fitting_borders = Dict(k=> 8 .- sum(v) for (k, v) in borders_match)

    edge_tiles_sum = filter(kv->kv[2] == 4, non_fitting_borders)
    @assert length(edge_tiles_sum) == 4
    border_tiles_sum = filter(kv->kv[2] == 2, non_fitting_borders)
    # there are 8 symmetries of the resulting grid, so I arbitrarily pick one
    side_len = Int(sqrt(length(tiles)))
    @assert length(border_tiles_sum) == 4*(side_len-2)

    # todo: add another matrix to denote which similarity is used where, by index 1-8
    result_tiles = zeros(Int, side_len, side_len)
    result_orientation = zeros(Int, side_len, side_len)

    tl_idx = CartesianIndex(1, 1)
    tl_key = first(keys(edge_tiles_sum))
    result_tiles[tl_idx] = tl_key

    possible_placements = get_0s_in_4neighborhood(result_tiles, tl_idx)
    tl_neighbors = tile_borders[tl_key] .∈ Ref(other_tile_borders(tile_borders, tl_key))
    # figure out orientation from the tl_neighbors
    result_orientation[tl_idx] = 1
    # mappings from idxs of 0s to orientation:
    # 1,4=N,E->

    # making sure that west and north side don't have neighbor
    @assert tl_neighbors[1] == false
    @assert tl_neighbors[3] == false

    border_tile_borders = filter(kv->kv[1] ∈ keys(border_tiles_sum), tile_borders)
    tile_fits = Dict(k=>v .∈ Ref(tile_borders[tl_key]) for (k, v) in border_tile_borders)
    tile_fit_counts = Dict(k=>sum(v) for (k, v) in tile_fits)
    neighbor_tiles = [k for (k, v) in tile_fit_counts if v == 2]

    tile_fits[neighbor_tiles[1]]
    tile_borders[neighbor_tiles[1]]
    tile_borders[tl_key]

    tile_borders[neighbor_tiles[1]] .== Ref(tile_borders[tl_key][1])
    tile_borders[neighbor_tiles[1]] .== Ref(tile_borders[tl_key][2])
    [tile_borders[neighbor_tiles[1]] .== Ref(x) for x in tile_borders[tl_key]]
    placements = hcat([tile_borders[neighbor_tiles[1]] .== Ref(x) for x in tile_borders[tl_key]]...)
    findfirst(placements .== 1)

    tile_borders[neighbor_tiles[1]] .== Ref(tile_borders[tl_key][1])
    tile_borders[tl_key][1][2]

    # todo: now I have matching side, need to figure out where to put it based on index
    # todo: write down which index is which side


    nei
    # any(non_fitting_borders[2729] .== 2)

    result_grid
end
using BenchmarkTools

end # module

if false
println(Day20.part1())
Day20.submit(Day20.part1(), Day20.cur_day, 1)
println(Day20.part2())
Day20.submit(Day20.part2(), Day20.cur_day, 2)
end
