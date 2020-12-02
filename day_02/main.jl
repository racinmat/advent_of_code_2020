module Day02

using DrWatson
quickactivate(@__DIR__)
include(projectdir("misc.jl"))

using StatsBase

function parse_row(str)
    m = match(r"(\d+)-(\d+)\s(\w):\s(\w+)", str)
    parse(Int, m[1]), parse(Int, m[2]), first(m[3]), m[4]
end

const cur_day = parse(Int, splitdir(@__DIR__)[end][5:end])
const data = cur_day |> read_input |> read_lines .|> parse_row

function part1()
    valid = 0
    for (from, to, char, word) in data
        hist = countmap(word)
        println("$from, $to, $char, $word")
        if from <= get(hist, char, 0) <= to
            valid += 1
        end
    end
    valid
end

function part2()
    valid = 0
    for (from, to, char, word) in data
        if (word[from] == char) ⊻ (word[to] == char)
            valid += 1
        end
    end
    valid
end

if false
println(part1())
submit(part1(), cur_day, 1)
println(part2())
submit(part2(), cur_day, 2)
end


end # module
