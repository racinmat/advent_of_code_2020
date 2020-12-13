module Day13

using DrWatson
quickactivate(@__DIR__)
include(projectdir("misc.jl"))

using Dates, BenchmarkTools
function parse_buses(x)
    tryparse.(Int, split(x[2], ","))
end

const cur_day = parse(Int, splitdir(@__DIR__)[end][5:end])
const raw_data = cur_day |> read_input
process_data() = raw_data |> read_lines |> x->(parse(Int, x[1]), parse_buses(x))
test_data = cur_day |> read_file("test_input.txt") |> read_lines |> x->(parse(Int, x[1]), parse_buses(x))
test_data = cur_day |> read_file("test_input_2.txt") |> read_lines |> x->(parse(Int, x[1]), parse_buses(x))
test_data = cur_day |> read_file("test_input_3.txt") |> read_lines |> x->(parse(Int, x[1]), parse_buses(x))
test_data = cur_day |> read_file("test_input_4.txt") |> read_lines |> x->(parse(Int, x[1]), parse_buses(x))

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

function combine_buses(a, b, a_offset, b_offset)
    g, s, t = gcdx(a,b)
    offset_diff = a_offset - b_offset
    pd_mult, pd_remainder = divrem(offset_diff, g)
    pd_remainder != 0 && throw(DomainError((a,b), "Rotation reference points never synchronize."))
    combined_period = a ÷ g * b
    combined_phase = (a_offset - s * pd_mult * a) % combined_period
    combined_period, combined_phase
end

function find_pair_meets(a, b, offset)
    combined_period, combined_phase = combine_buses(a, b, offset)
    mod(-combined_phase, combined_period)
end

find_pair_meets(combined_period, combined_phase) = mod(-combined_phase, combined_period)

function combine_buses(ok_buses)
    sorted_idxs = sort(collect(keys(ok_buses)))
    bus1 = ok_buses[sorted_idxs[1]]
    bus2 = ok_buses[sorted_idxs[2]]
    period_combined = ok_buses[sorted_idxs[1]]
    phase_combined = sorted_idxs[1]
    for i in sorted_idxs[2:end]
        period_combined, phase_combined = combine_buses(period_combined, ok_buses[i], phase_combined, i)
    end
    period_combined, phase_combined
end

function part2()
    data = process_data()
    # data = test_data
    time_start, buses = data
    ok_buses = Dict(k-1=>v for (k, v) in enumerate(buses) if !isnothing(v))
    # sorted_idxs = sort(collect(keys(ok_buses)))
    # period_combined, phase_combined = combine_buses(ok_buses)
    # for some reason it gives me too high time for all buses, combining these approaches
    period_combined, phase_combined = combine_buses(filter(kv->kv[1]<65, ok_buses))
    group_meets = find_pair_meets(period_combined, phase_combined)
    x = group_meets
    # next_log = 0
    while buses_not_fit(x, ok_buses)
        x += period_combined
    end
    x
end

end # module

if false
println(Day13.part1())
Day13.submit(Day13.part1(), Day13.cur_day, 1)
println(Day13.part2())
Day13.submit(Day13.part2(), Day13.cur_day, 2)
Day13.@btime Day13.part2()
end
