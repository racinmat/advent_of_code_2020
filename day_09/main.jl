module Day09

using DrWatson
quickactivate(@__DIR__)
include(projectdir("misc.jl"))

using Combinatorics
const cur_day = parse(Int, splitdir(@__DIR__)[end][5:end])
const raw_data = cur_day |> read_input
process_data() = raw_data |> read_numbers

function part1()
    data = process_data()
    preamble_size = 25
    k = preamble_size+1
    @inbounds for k in preamble_size+1:length(data)
        val = data[k]
        preamble = data[k-preamble_size:k-1]
        if val ∉ unique(sum.(combinations(preamble, 2)))
            return val
        end
    end
end

function part2()
    data = process_data()
    the_sum = part1()
    for l in 2:length(data)
        @inbounds for k in 1:length(data)-l
            a_range = data[k:k+l]
            if sum(a_range) == the_sum
                return minimum(a_range) + maximum(a_range)
            end
        end
    end
end


end # module

if false
println(Day09.part1())
Day09.submit(Day09.part1(), Day09.cur_day, 1)
println(Day09.part2())
Day09.submit(Day09.part2(), Day09.cur_day, 2)
end
