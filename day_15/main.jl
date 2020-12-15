module Day15

using DrWatson
quickactivate(@__DIR__)
include(projectdir("misc.jl"))

const cur_day = parse(Int, splitdir(@__DIR__)[end][5:end])
const raw_data = cur_day |> read_input
process_data() = raw_data |> x->read_numbers(x, ",")
test_data = cur_day |> read_file("test_input.txt") |> x->read_numbers(x, ",")

function play_game(data, n_turns)
    last_occur = Dict(n=>i for (i, n) in enumerate(data[1:end-1]))
    cur_number = last(data)
    turn = length(data)
    @inbounds while turn < n_turns
        next_number = if cur_number ∈ keys(last_occur)
             turn - last_occur[cur_number]
        else
            0
        end
        last_occur[cur_number] = turn
        cur_number = next_number
        turn += 1
    end
    cur_number
end

function part1()
    data = process_data()
    # data = test_data
    play_game(data, 2020)
end

function part2()
    data = process_data()
    play_game(data, 30_000_000)
end


end # module

if false
println(Day15.part1())
Day15.submit(Day15.part1(), Day15.cur_day, 1)
println(Day15.part2())
Day15.submit(Day15.part2(), Day15.cur_day, 2)
end
