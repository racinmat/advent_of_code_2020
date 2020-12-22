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
#  1    2    3    4    5      6      7      8
#  N    E    S    W    NR     ER     SR     WR      1
# W E  N S  E W  S N  ER WR  SR NR  WR ER  NR SR   3 4
#  S    W    N    E    SR     WR     NR     ER      2
#  maybe simple lookup table for everything will be enough

# neighbor borders orientations to orientation of tile
# so when I know which

# this assumes the new tile is below the old one, one must rotate it accordingly
# idx of border to idx of orientation
# todo: udělat
borders2orientation = Dict(
    CartesianIndex(1,0) => Dict(
    #=N =#    1=>1,
    #=S =#    2=>3,
    #=W =#    3=>4,
    #=E =#    4=>2,
    #=NR=#    5=>5,
    #=SR=#    6=>7,
    #=WR=#    7=>8,
    #=ER=#    8=>6,
    ),
    CartesianIndex(-1,0) => Dict(
    #=N =#    1=>3,
    #=S =#    2=>1,
    #=W =#    3=>2,
    #=E =#    4=>4,
    #=NR=#    5=>7,
    #=SR=#    6=>5,
    #=WR=#    7=>6,
    #=ER=#    8=>8,
    ),
    CartesianIndex(0,1) => Dict(
    #=N =#    1=>2,
    #=S =#    2=>4,
    #=W =#    3=>1,
    #=E =#    4=>3,
    #=NR=#    5=>8,
    #=SR=#    6=>6,
    #=WR=#    7=>7,
    #=ER=#    8=>5,
    ),
    CartesianIndex(0,-1) => Dict(
    #=N =#    1=>4,
    #=S =#    2=>2,
    #=W =#    3=>3,
    #=E =#    4=>1,
    #=NR=#    5=>6,
    #=SR=#    6=>8,
    #=WR=#    7=>5,
    #=ER=#    8=>7,
    ),
)

all_borders_not_reversed(v) = v[1,:],v[end,:],v[:,1],v[:,end]
all_borders_reversed(v) = v[1,end:-1:1],v[end,end:-1:1],v[end:-1:1,1],v[end:-1:1,end]

other_tile_borders(tile_borders, id) = flatten(v for (k, v) in tile_borders if k != id)

dir2idx = Dict(
    CartesianIndex(-1, 0)=>1,
    CartesianIndex(1, 0)=>2,
    CartesianIndex(0, -1)=>3,
    CartesianIndex(0, 1)=>4,
)

idx2dir=Dict(v=>k for (k, v) in dir2idx)

# maps orientation to orig direction=>rotated direction
orientation2placement = Dict(
        1=>Dict(1=>1, 2=>2, 3=>3, 4=>4),
        2=>Dict(4=>1, 1=>3, 3=>2, 2=>4),
        3=>Dict(1=>2, 2=>1, 3=>4, 4=>3),
        4=>Dict(1=>4, 3=>1, 2=>3, 4=>2),
        5=>Dict(5=>1, 6=>2, 7=>4, 8=>3),
        6=>Dict(8=>1, 6=>3, 7=>2, 5=>4),
        7=>Dict(5=>2, 6=>1, 7=>3, 8=>4),
        8=>Dict(7=>1, 5=>3, 6=>4, 8=>2),
)
# todo: figure out how to convert spatial orientation to indexes

# evaluating only free slots in grid
# alignment matrix has 1 on (k,l)th position if k-th index of old tile aligns with l-th index of new tile
# if orientation of old tile is 1
# and the new tile is in west, I'm interested in alignment between indices ()

# mappings from idxs of 0s to orientation:
# 1,4=N,E->2
# 1,3=N,W->1
# 2,4=S,E->3
# 2,2=S,W->4
zeros2orientation = Dict(
    (1,4)=>2,
    (1,3)=>1,
    (2,4)=>3,
    (2,3)=>4,
)

function rotate_tile2orientation(tile, idx)
    if idx == 1
        tile
    elseif idx == 2
        tile[:,end:-1:1]'
    elseif idx == 3
        tile[end:-1:1,end:-1:1]
    elseif idx == 4
        tile[end:-1:1,:]'
    elseif idx == 5
        tile[:,end:-1:1]
    elseif idx == 6
        tile'
    elseif idx == 7
        tile[end:-1:1,:]
    elseif idx == 8
        tile[end:-1:1,end:-1:1]'
    end
end

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

function tiles2whole_tiles(side_len, result_tiles, result_orientation)
    whole_tiles = zeros(Int, side_len*10, side_len*10)
    for i in findall(!=(0), result_tiles)
        whole_tiles[1+(i.I[1]-1)*10:i.I[1]*10, 1+(i.I[2]-1)*10:i.I[2]*10] = rotate_tile2orientation(tiles[result_tiles[i]], result_orientation[i])
    end
    whole_tiles
end

# place top left tile
function place_tl_tile(tile_borders, il_idx)
    tl_neighbors = tile_borders[tl_key] .∈ Ref(other_tile_borders(tile_borders, tl_key))
    # figuring out orientation from the tl_neighbors
    nonplacable_directions = findall(==(0), tl_neighbors[begin:4])
    cur_orientation = zeros2orientation[tuple(nonplacable_directions...)]
    cur_orientation, tl_neighbors
end

function get_neighbor_tiles(tile_borders, border_tiles_sum, tile_neighbors, tile_idx)
    placable_directions = findall(==(1), tile_neighbors[begin:4])
    border_tile_borders = filter(kv->kv[1] ∈ keys(border_tiles_sum), tile_borders)
    tile_fits = Dict(k=>v .∈ Ref(tile_borders[tile_idx]) for (k, v) in border_tile_borders)
    tile_fit_counts = Dict(k=>sum(v) for (k, v) in tile_fits)
    neighbor_tiles = [k for (k, v) in tile_fit_counts if v == 2]
    neighbor_tiles, placable_directions
end

function place_neighbor(tile_borders, placable_directions, tl_key, cur_orientation, result_tiles, result_orientation)
    placements = hcat([tile_borders[neighbor_tile] .== Ref(x) for x in tile_borders[tl_key][placable_directions]]...)
    to_idx, from_idx = findfirst(placements .== 1).I
    new_tile_direction = orientation2placement[cur_orientation][placable_directions[from_idx]]
    new_tile_pos = tl_idx + idx2dir[new_tile_direction]

    new_tile_orientation = borders2orientation[idx2dir[new_tile_direction]][to_idx]
    result_orientation[new_tile_pos] = new_tile_orientation
    result_tiles[new_tile_pos] = neighbor_tile
end

function part2()
    data = process_data()
    data = test_data
    tiles = Dict(data)

    tile_borders = Dict(k=>[all_borders_not_reversed(v)..., all_borders_reversed(v)...] for (k, v) in tiles)
    borders_match = Dict(k=>v .∈ Ref(other_tile_borders(tile_borders, k)) for (k, v) in tile_borders)
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

    cur_orientation, tl_neighbors = place_tl_tile(tile_borders, tl_idx)
    result_orientation[tl_idx] = cur_orientation

    neighbor_tiles, placable_directions = get_neighbor_tiles(tile_borders, border_tiles_sum, tl_neighbors, tl_key)
    neighbor_tile = first(neighbor_tiles)

    place_neighbor(tile_borders, placable_directions, tl_key, cur_orientation, result_tiles, result_orientation)

    whole_tiles = tiles2whole_tiles(side_len, result_tiles, result_orientation)
    # todo: now I have matching side, need to figure out where to put it based on index
    # todo: write down which index is which side



    # any(non_fitting_borders[2729] .== 2)

    result_grid
end

end # module

if false
println(Day20.part1())
Day20.submit(Day20.part1(), Day20.cur_day, 1)
println(Day20.part2())
Day20.submit(Day20.part2(), Day20.cur_day, 2)
end
