module Day08

using DrWatson
quickactivate(@__DIR__)
include(projectdir("misc.jl"))

function parse_row(str)
    parts = split(str, ", ")
    start = popfirst!(parts)
    m = match(r"(\w+) ((?:\+|-)?\d+)", str)
    [m[1], parse(Int, m[2])]
end

const cur_day = parse(Int, splitdir(@__DIR__)[end][5:end])
const raw_data = cur_day |> read_input
process_data() = raw_data |> read_lines .|> parse_row
test_data = cur_day |> x->read_file(x, "test_input.txt") |> read_lines .|> parse_row

function data_loops(data)
    accumulator = 0
    row = 1
    num_rows = length(data)
    row_ran = falses(num_rows)
    @inbounds while !row_ran[row] && row <= num_rows
        instr, val = data[row]
        row_ran[row] = true
        if instr == "nop"
            row += 1
        elseif instr == "acc"
            accumulator += val
            row += 1
        elseif instr == "jmp"
            row += val
        end
    end
    accumulator, row <= num_rows
end

function part1()
    data = process_data()
    # data = test_data
    accumulator, looped = data_loops(data)
    accumulator
end

function part2()
    orig_data = process_data()
    # orig_data = test_data
    accumulator, looped = data_loops(orig_data)
    jumps = findall(x->x[1] == "jmp", orig_data)
    findall(x->length(x) ==2, orig_data)
    orig_data[2][1]
    nth_jump = 0
    while looped
        nth_jump += 1
        data = deepcopy(orig_data)
        data[jumps[nth_jump]][1] = "nop"
        accumulator, looped = data_loops(data)
    end
    accumulator
end


end # module

if false
println(Day08.part1())
Day08.submit(Day08.part1(), Day08.cur_day, 1)
println(Day08.part2())
Day08.submit(Day08.part2(), Day08.cur_day, 2)
end
