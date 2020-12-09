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

function data_loops(data, flip_index=0)
    accumulator = 0
    row = 1
    num_rows = length(data)
    row_ran = falses(num_rows)
    last_jmp = 0
    @inbounds while row <= num_rows && !row_ran[row]
        instr, val = data[row]
        if row == flip_index
            if instr == "nop"
                instr = "jmp"
            elseif instr == "jmp"
                instr = "nop"
            end
        end
        row_ran[row] = true
        if instr == "nop"
            row += 1
        elseif instr == "acc"
            accumulator += val
            row += 1
        elseif instr == "jmp"
            last_jmp = row
            row += val
        end
    end
    accumulator, row <= num_rows, last_jmp
end

function part1()
    data = process_data()
    # data = test_data
    accumulator, looped, last_jmp = data_loops(data)
    accumulator
end

function part2()
    data = process_data()
    # orig_data = test_data
    accumulator, looped, last_jmp = data_loops(data)
    jumps = findall(x->x[1] ∈ ("jmp", "nop"), data)
    nth_jump = 0
    while looped
        nth_jump += 1
        accumulator, looped, last_jmp = data_loops(data, jumps[nth_jump])
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
