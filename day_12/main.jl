module Day12

using DrWatson
quickactivate(@__DIR__)
include(projectdir("misc.jl"))

using OffsetArrays

abstract type Instruction end
abstract type Direction <: Instruction end
struct North <: Direction end
struct West <: Direction end
struct East <: Direction end
struct South <: Direction end
struct Forward <: Instruction end
struct RotateRight <: Instruction end
struct RotateLeft <: Instruction end

const translation = Dict(
    'N' => North(),
    'S' => South(),
    'E' => East(),
    'W' => West(),
    'F' => Forward(),
    'R' => RotateRight(),
    'L' => RotateLeft(),
)

const directions_clockwise = OffsetVector([North(), East(), South(), West()], 0:3)
idx(::North) = 0
idx(::East) = 1
idx(::South) = 2
idx(::West) = 3

shift_left(rot, num) = directions_clockwise[mod(idx(rot)-num÷90, length(directions_clockwise))]
shift_right(rot, num) = directions_clockwise[mod(idx(rot)+num÷90, length(directions_clockwise))]

parse_row(str) = translation[str[1]], parse(Int, str[2:end])
# parse_row(str) = str[1], parse(Int, str[2:end])

const cur_day = parse(Int, splitdir(@__DIR__)[end][5:end])
const raw_data = cur_day |> read_input
process_data() = raw_data |> read_lines .|> parse_row
test_data = cur_day |> read_file("test_input.txt") |> read_lines .|> parse_row

const L = [0 -1; 1 0]
const R = [0 1; -1 0]

const directions = Dict(North()=>[-1,0], East()=>[0,1], South()=>[1,0], West()=>[0,-1])
process(pos, rot, d::Direction, i) = pos + directions[d].*i, rot
process(pos, rot, d::Forward, i) = process(pos, rot, rot, i)
process(pos, rot, d::RotateLeft, i) = pos, shift_left(rot, i)
process(pos, rot, d::RotateRight, i) = pos, shift_right(rot, i)

process2(pos, wpos, d::Direction, i) = pos, wpos + directions[d].*i
process2(pos, wpos, d::Forward, i) = pos + wpos.*i, wpos
process2(pos, wpos, d::RotateLeft, i) = pos, L^(i÷90) * wpos
process2(pos, wpos, d::RotateRight, i) = pos, R^(i÷90) * wpos

function part1()
    data = process_data()
    # data = test_data
    pos = [0,0]
    rot = East()
    for (i, j) in data
        pos, rot = process(pos, rot, i, j)
    end
    sum(abs.(pos))
end

function part2()
    data = process_data()
    # data = test_data
    pos = [0,0]
    wpos = [-1, 10]
    for (i, j) in data
        pos, wpos = process2(pos, wpos, i, j)
    end
    sum(abs.(pos))
end


end # module

if false
println(Day12.part1())
Day12.submit(Day12.part1(), Day12.cur_day, 1)
println(Day12.part2())
Day12.submit(Day12.part2(), Day12.cur_day, 2)
end
