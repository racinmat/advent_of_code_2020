module Day02

using DrWatson
quickactivate(@__DIR__)
include(projectdir("misc.jl"))

using StatsBase

#todo: try threaded stuff and atomic accumulator, maybe transducers reduce?
function parse_row(str)
    m = match(r"(\d+)-(\d+)\s(\w):\s(\w+)", str)
    parse(Int, m[1]), parse(Int, m[2]), first(m[3]), m[4]
end

const cur_day = parse(Int, splitdir(@__DIR__)[end][5:end])
const raw_data = cur_day |> read_input
process_data() = raw_data |> read_lines .|> parse_row

function part1()
    data = process_data()
    valid = Threads.Atomic{Int}(0)
    Threads.@threads for (from, to, char, word) in data
        occurs = mapreduce(==(char), +, word)
        if from <= occurs <= to
            Threads.atomic_add!(valid, 1)
        end
    end
    valid[]
end

function part2()
    data = process_data()
    valid = Threads.Atomic{Int}(0)
    Threads.@threads for (from, to, char, word) in data
        if (word[from] == char) ⊻ (word[to] == char)
            Threads.atomic_add!(valid, 1)
        end
    end
    valid[]
end


end # module

if false
println(Day02.part1())
Day02.submit(Day02.part1(), Day02.cur_day, 1)
println(Day02.part2())
Day02.submit(Day02.part2(), Day02.cur_day, 2)
end
