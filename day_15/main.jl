module Day15

using DrWatson
quickactivate(@__DIR__)
include(projectdir("misc.jl"))

using DataStructures
const cur_day = parse(Int, splitdir(@__DIR__)[end][5:end])
const raw_data = cur_day |> read_input
process_data() = raw_data |> x->read_numbers(x, ",")
test_data = cur_day |> read_file("test_input.txt") |> x->read_numbers(x, ",")

function play_game(data, n_turns)
    turn = 0
    all_occurs = Set{Int}()
    last_occur = Dict{Int, Int}()
    penultimate_occur = Dict{Int, Int}()
    cur_number = 0
    was_seen_first_time = false
    @inbounds while turn < n_turns
        turn += 1
        if turn <= length(data)
            cur_number = data[turn]
        else
            if was_seen_first_time
                cur_number = 0
            else
                cur_number = last_occur[cur_number] - penultimate_occur[cur_number]
            end
        end
        if haskey(last_occur, cur_number)
            penultimate_occur[cur_number] = last_occur[cur_number]
        end
        last_occur[cur_number] = turn
        if cur_number ∉ all_occurs
            push!(all_occurs, cur_number)
            was_seen_first_time = true
        else
            was_seen_first_time = false
        end
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
