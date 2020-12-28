module Day20

using DrWatson
quickactivate(@__DIR__)
include(projectdir("misc.jl"))

using Base.Iterators, StatsBase, Images

function read_tile(str)
    lines = read_lines(str)
    tile_desc = first(lines)
    m = match(r"Tile (\d+):", tile_desc)
    grid = lines[2:end] .|> replace_chars("."=>"0", "#"=>"1") .|> collect .|> (x->parse.(Bool, x)) |> x->hcat(x...)'
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
# 1, 2, 3, 4, 5,  6,  7,  8

# we must be ware of the actual rotation of individual sides, so the correct is:
# for F as front and B as back of tile (F being not flipped and B being flipped)
#   1       2        3       4      5       6        7       8
#   N       E       SR      WR     NR      ER        S       W      1
# W F E  NR F SR  ER F WR  S F N  E B W  SR B NR  WR B ER  N B S   3 4
#   S       W       NR      ER     SR      WR        N       E      2

# neighbor borders orientations to orientation of tile
# this assumes the old tile is not rotated, one must rotate the it accordingly
# idx of border to idx of orientation
# todo: udělat
# when we have existing tile and new tile in relative position [key] to the existing one, this transforms which border
# of a new tile fits with original tile to the orientation of new tile
# beware: when we following situation: position [1, 0], and S aligning, it's actually SR, because it's reversed
#     N
# W [orig] E
#     S
#     S
# E [new]  W
#     N
#
const borders2orientation = Dict(
    CartesianIndex(1,0) => Dict(
    #=N =#    1=>1,
    #=S =#    2=>7,
    #=W =#    3=>8,
    #=E =#    4=>2,
    #=NR=#    5=>5,
    #=SR=#    6=>3,
    #=WR=#    7=>4,
    #=ER=#    8=>6,
    ),
    CartesianIndex(-1,0) => Dict(
    #=N =#    1=>7,
    #=S =#    2=>1,
    #=W =#    3=>2,
    #=E =#    4=>8,
    #=NR=#    5=>3,
    #=SR=#    6=>5,
    #=WR=#    7=>6,
    #=ER=#    8=>4,
    ),
    CartesianIndex(0,1) => Dict(
    #=N =#    1=>8,
    #=S =#    2=>4,
    #=W =#    3=>1,
    #=E =#    4=>5,
    #=NR=#    5=>2,
    #=SR=#    6=>6,
    #=WR=#    7=>7,
    #=ER=#    8=>3,
    ),
    CartesianIndex(0,-1) => Dict(
    #=N =#    1=>4,
    #=S =#    2=>8,
    #=W =#    3=>5,
    #=E =#    4=>1,
    #=NR=#    5=>6,
    #=SR=#    6=>2,
    #=WR=#    7=>3,
    #=ER=#    8=>7,
    ),
)

all_borders_not_reversed(v) = @inbounds v[1,:],v[end,:],v[:,1],v[:,end]
all_borders_reversed(v) = @inbounds v[1,end:-1:1],v[end,end:-1:1],v[end:-1:1,1],v[end:-1:1,end]

other_tile_borders(tile_borders, id) = flatten(v for (k, v) in tile_borders if k != id)

const dir2idx = Dict(
    CartesianIndex(-1, 0)=>1,
    CartesianIndex(1, 0)=>2,
    CartesianIndex(0, -1)=>3,
    CartesianIndex(0, 1)=>4,
)

reversed(d::Dict) = Dict(v=>k for (k, v) in d)
const idx2dir = reversed(dir2idx)

# maps orientation to tile direction=>direction in grid (rotated direction from POV of tile)
# todo: must fix this! this is wrong, must use reversed sides here for 1-4 where appropriate
const orientation2placement = Dict(
        1=>Dict(1=>1, 2=>2, 3=>3, 4=>4),
        2=>Dict(4=>1, 5=>3, 3=>2, 6=>4),
        3=>Dict(5=>2, 6=>1, 7=>4, 8=>3),
        4=>Dict(1=>4, 7=>1, 2=>3, 8=>2),
        5=>Dict(5=>1, 6=>2, 3=>4, 4=>3),
        6=>Dict(8=>1, 6=>3, 7=>2, 5=>4),
        7=>Dict(1=>2, 2=>1, 7=>3, 8=>4),
        8=>Dict(3=>1, 1=>3, 2=>4, 4=>2),
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
const zeros2orientation = Dict(
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
        tile[end:-1:1,end:-1:1]'
    elseif idx == 7
        tile[end:-1:1,:]
    elseif idx == 8
        tile'
    end
end

function get_0s_in_4neighborhood(m, i)
    neighbors = CartesianIndex[]
    @inbounds i.I[1] > 1 && push!(neighbors, CartesianIndex(-1, 0))
    @inbounds i.I[2] > 1 && push!(neighbors, CartesianIndex(0, -1))
    @inbounds i.I[1] < size(m)[1] && push!(neighbors, CartesianIndex(1, 0))
    @inbounds i.I[2] < size(m)[2] && push!(neighbors, CartesianIndex(0, 1))
    @inbounds [j for j in neighbors if m[i+j] == 0]
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

function tiles2whole_tiles(tiles, side_len, result_tiles, result_orientation)
    whole_tiles = zeros(Bool, side_len*10, side_len*10)
    @inbounds for i in findall(!=(0), result_tiles)
        whole_tiles[1+(i.I[1]-1)*10:i.I[1]*10, 1+(i.I[2]-1)*10:i.I[2]*10] = rotate_tile2orientation(tiles[result_tiles[i]], result_orientation[i])
    end
    whole_tiles
end

# place top left tile
function place_tl_tile(tile_borders, tl_idx)
    @inbounds cur_tile_borders = tile_borders[tl_idx] .∈ Ref(other_tile_borders(tile_borders, tl_idx))
    nonplacable_directions = findall(==(0), cur_tile_borders[begin:4])
    cur_orientation = zeros2orientation[tuple(nonplacable_directions...)]
    cur_orientation
end

"""
Returns list of tiles that can be placed next to `tile_pos`, and placable_direction, which tell in which directions
relative to `tile_pos` they can be placed in, from POV of `tile_pos`, so they are rotated in same manner as `tile_pos`
"""
function get_free_neighbor_tiles(tile_borders, result_tiles, result_orientation, tile_pos, tile_subset=nothing)
    # now it works only for border tiles
    @inbounds tile_idx = result_tiles[tile_pos]
    @inbounds tile_neighbors = tile_borders[tile_idx] .∈ Ref(other_tile_borders(tile_borders, tile_idx))
    @inbounds tile_orientation = result_orientation[tile_pos]
    # findall does not with with indices
    @inbounds rotation_map = orientation2placement[tile_orientation]
    @inbounds placable_directions = [k for (k, v) in enumerate(tile_neighbors) if v == 1 && k ∈ keys(orientation2placement[tile_orientation])]
    already_placed_tiles = unique(result_tiles)
    feasible_tile_borders = filter(kv->kv[1] ∉ unique(result_tiles), tile_borders)
    if !isnothing(tile_subset)
        feasible_tile_borders = filter(kv->kv[1] ∈ tile_subset, feasible_tile_borders)
    end

    free_neighbors = get_0s_in_4neighborhood(result_tiles, tile_pos)
    free_placable_directions = [i for i in placable_directions if getindex.(Ref(rotation_map), i) ∈ getindex.(Ref(dir2idx), free_neighbors)]

    @inbounds tile_fits = Dict(k=>v .∈ Ref(tile_borders[tile_idx]) for (k, v) in feasible_tile_borders)
    tile_fit_counts = Dict(k=>sum(v) for (k, v) in tile_fits)
    @inbounds neighbor_tiles = [k for (k, v) in tile_fit_counts if v == 2]
    # todo: filter out already placed neighbors, return only non-used neighbors
    free_neighbor_tiles = filter(x -> x ∉ unique(result_tiles), neighbor_tiles)
    free_neighbor_tiles, free_placable_directions
end

function place_borders!(edge_tiles_sum, border_tiles_sum, tile_borders, result_tiles, result_orientation, side_len)
    tl_pos = CartesianIndex(1, 1)
    tl_idx = first(keys(edge_tiles_sum))
    @inbounds result_tiles[tl_pos] = tl_idx

    cur_orientation = place_tl_tile(tile_borders, tl_idx)
    @inbounds result_orientation[tl_pos] = cur_orientation
    cur_pos = tl_pos
    # this works, generalize this for all 4 borders and corners, make it side_len-2 times per side

    for j in 1:3
        for i in 1:side_len-2
            neighbor_tiles, placable_directions = get_free_neighbor_tiles(tile_borders, result_tiles, result_orientation, cur_pos, keys(border_tiles_sum))
            neighbor_tile = first(neighbor_tiles)
            cur_pos, cur_orientation = place_neighbor!(tile_borders, placable_directions, cur_pos, neighbor_tile, result_tiles, result_orientation)
        end

        neighbor_tiles, placable_directions = get_free_neighbor_tiles(tile_borders, result_tiles, result_orientation, cur_pos, keys(edge_tiles_sum))
        neighbor_tile = first(neighbor_tiles)
        cur_pos, cur_orientation = place_neighbor!(tile_borders, placable_directions, cur_pos, neighbor_tile, result_tiles, result_orientation)
    end

    for i in 1:side_len-2
        neighbor_tiles, placable_directions = get_free_neighbor_tiles(tile_borders, result_tiles, result_orientation, cur_pos, keys(border_tiles_sum))
        neighbor_tile = first(neighbor_tiles)
        cur_pos, cur_orientation = place_neighbor!(tile_borders, placable_directions, cur_pos, neighbor_tile, result_tiles, result_orientation)
    end
end

function place_neighbor!(tile_borders, placable_directions, start_pos, neighbor_tile, result_tiles, result_orientation)
    @inbounds start_idx = result_tiles[start_pos]
    @inbounds start_orientation = result_orientation[start_pos]
    @inbounds placements = hcat([tile_borders[neighbor_tile] .== Ref(x) for x in tile_borders[start_idx][placable_directions]]...)
    to_idx, from_idx = findfirst(placements .== 1).I
    @inbounds new_tile_direction = orientation2placement[start_orientation][placable_directions[from_idx]]
    @inbounds new_tile_pos = start_pos + idx2dir[new_tile_direction]

    @inbounds new_tile_orientation = borders2orientation[idx2dir[new_tile_direction]][to_idx]
    @inbounds result_orientation[new_tile_pos] = new_tile_orientation
    @inbounds result_tiles[new_tile_pos] = neighbor_tile
    new_tile_pos, new_tile_orientation
end

function remove_borders(whole_tiles)
    # we know it's square
    all_rows = collect(1:size(whole_tiles)[1])
    keep_rows = all_rows .% 10 .∉ Ref((0,1))
    whole_tiles[keep_rows, keep_rows]
end

function is_result_consistent(whole_tiles, side_len, result_tiles)
    i = 2
    j = 2
    # c = 0
    # todo: add check for gorizontal borders, these are only vertical
    for i in 1:side_len
        for j in 1:side_len-1
            borders_match = whole_tiles[1+(i-1)*10:i*10, j*10] == whole_tiles[1+(i-1)*10:i*10, j*10+1]
            borders_filled = result_tiles[i,j] != 0 && result_tiles[i,j+1] != 0
            if borders_filled && !borders_match
                @info "border not fitting" i j borders_match borders_filled
                return false
            end
            # c += borders_filled
        end
    end
    # c
    # 1+(i.I[1]-1)*10:i.I[1]*10, 1+(i.I[2]-1)*10:i.I[2]*10
    true
end

function assemble_puzzle(tiles)
    tile_borders = Dict(k=>[all_borders_not_reversed(v)..., all_borders_reversed(v)...] for (k, v) in tiles)
    borders_match = Dict(k=>v .∈ Ref(other_tile_borders(tile_borders, k)) for (k, v) in tile_borders)
    non_fitting_borders = Dict(k=> 8 .- sum(v) for (k, v) in borders_match)

    edge_tiles_sum = filter(kv->kv[2] == 4, non_fitting_borders)
    @assert length(edge_tiles_sum) == 4
    border_tiles_sum = filter(kv->kv[2] == 2, non_fitting_borders)
    # there are 8 symmetries of the resulting grid, so I arbitrarily pick one
    side_len = Int(sqrt(length(tiles)))
    @assert length(border_tiles_sum) == 4*(side_len-2)

    result_tiles = zeros(Int, side_len, side_len)
    result_orientation = zeros(Int, side_len, side_len)

    place_borders!(edge_tiles_sum, border_tiles_sum, tile_borders, result_tiles, result_orientation, side_len)

    cur_pos = CartesianIndex(2, 1)
    cur_orientation = result_orientation[cur_pos]

    while count(==(0), result_tiles) > 0
        if isempty(get_0s_in_4neighborhood(result_tiles, cur_pos))
            cur_pos = findfirst(==(0), result_tiles)-CartesianIndex(1, 0)
        end
        neighbor_tiles, placable_directions = get_free_neighbor_tiles(tile_borders, result_tiles, result_orientation, cur_pos)
        neighbor_tile = first(neighbor_tiles)
        cur_pos, cur_orientation = place_neighbor!(tile_borders, placable_directions, cur_pos, neighbor_tile, result_tiles, result_orientation)
    end
    whole_tiles = tiles2whole_tiles(tiles, side_len, result_tiles, result_orientation)
    @assert is_result_consistent(whole_tiles, side_len, result_tiles)
    whole_tiles, result_tiles, result_orientation
end

function find_sea_monsters(result_tile, monster_pattern)
    monster_pattern_temp = monster_pattern * 100
    thr_sum = sum(monster_pattern_temp)
    num_monsters = Threads.Atomic{Int}(0)
    @inbounds Threads.@threads for i in 1:size(result_tile)[1]-2
        @inbounds for j in 1:size(result_tile)[1]-19
            win = result_tile[i:i+2,j:j+19]
            if sum(win.*monster_pattern_temp) >= thr_sum
                # @info "found it" i j sum(win.*monster_pattern)
                Threads.atomic_add!(num_monsters, 1)
            end
        end
    end
    num_monsters[]
end

function print_mat(A)
    translator = Dict(0=>".",1=>"#")
    A .|> (x->translator[x]) |> eachrow .|> join .|> println
    println()
end

function part2()
    data = process_data()
    # data = test_data
    tiles = Dict(data)
    whole_tiles, result_tiles, result_orientation = assemble_puzzle(tiles)
    result_tile = remove_borders(whole_tiles)

    monster_pattern = [
        0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0;
        1 0 0 0 0 1 1 0 0 0 0 1 1 0 0 0 0 1 1 1;
        0 1 0 0 1 0 0 1 0 0 1 0 0 1 0 0 1 0 0 0;
    ]

    num_monsters = 0
    for i in 1:8
        num_monsters = find_sea_monsters(rotate_tile2orientation(result_tile, i), monster_pattern)
        if num_monsters > 0
            break
        end
    end
    sum(result_tile) - sum(monster_pattern) * num_monsters
end

end # module

if false
println(Day20.part1())
Day20.submit(Day20.part1(), Day20.cur_day, 1)
println(Day20.part2())
Day20.submit(Day20.part2(), Day20.cur_day, 2)
end
