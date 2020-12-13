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
    period_combined, phase_combined = combine_buses(filter(kv->kv[1]<50, ok_buses))
    group_meets = find_pair_meets(period_combined, phase_combined)
    # # x = ok_buses[sorted_idxs[1]]
    # # x = time_12_fit
    # # x = time_123_fit
    # x = time_1234_fit
    x = group_meets
    next_log = 0
    while buses_not_fit(x, ok_buses)
        # x += ok_buses[0]
        # x += period_12
        # x += period_123
        # x += period_1234
        x += period_combined
        if x > next_log
            next_log += 1_000_000_000
            @info Dates.now() x
        end
    end
    x
end

# todo: figure it out, try on more test inputs, combine iterative approach and this one
# wrong answer: 578230687890668
# That's not the right answer; your answer is too high.  If you're stuck, make sure you're using the full input data; there are also some general tips on the about page, or you can ask for hints on the subreddit.  Please wait one minute before trying
# again. (You guessed 578230687890668.) [Return to Day 13]
# 289115343945334 is too low
# 289_115_343_945_334
# 578_230_687_890_668
end # module

if false
println(Day13.part1())
Day13.submit(Day13.part1(), Day13.cur_day, 1)
println(Day13.part2())
Day13.submit(Day13.part2(), Day13.cur_day, 2)
Day13.@btime Day13.part2()
end
# benchmark on test input
# native:               11.535 ms (152727 allocations: 2.34 MiB)
# merged buses 1,2:     621.500 μs (11857 allocations: 198.31 KiB)
# merged buses 1,2,3:   26.901 μs (318 allocations: 18.03 KiB)
# merged buses 1,2,3,4: 16.200 μs (129 allocations: 15.09 KiB)
