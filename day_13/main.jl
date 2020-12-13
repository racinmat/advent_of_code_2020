module Day13

using DrWatson
quickactivate(@__DIR__)
include(projectdir("misc.jl"))

using Dates
function parse_buses(x)
    tryparse.(Int, split(x[2], ","))
end

const cur_day = parse(Int, splitdir(@__DIR__)[end][5:end])
const raw_data = cur_day |> read_input
process_data() = raw_data |> read_lines |> x->(parse(Int, x[1]), parse_buses(x))
test_data =  cur_day |> read_file("test_input.txt") |> read_lines |> x->(parse(Int, x[1]), parse_buses(x))

function part1()
    data = process_data()
    # data = test_data
    time_start, buses = data
    buses = filter(!isnothing, buses)
    times2arrive = buses .- (time_start .% buses)
    idx = argmin(times2arrive)
    times2arrive[idx] * buses[idx]
end

buses_not_fit(x, ok_buses) = any((x+k) % v != 0 for (k, v) in ok_buses)

function part2()
    data = process_data()
    # data = test_data
    time_start, buses = data
    ok_buses = Dict(k-1=>v for (k, v) in enumerate(buses) if !isnothing(v))
    x = ok_buses[0]
    while buses_not_fit(x, ok_buses)
        x += ok_buses[0]
    end

    x
end


end # module

if false
println(Day13.part1())
Day13.submit(Day13.part1(), Day13.cur_day, 1)
println(Day13.part2())
Day13.submit(Day13.part2(), Day13.cur_day, 2)
end
