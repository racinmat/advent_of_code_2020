module Day22

using DrWatson
quickactivate(@__DIR__)
include(projectdir("misc.jl"))

function parse_player(str)
    lines = read_lines(str)
    lines[1][begin:end-1], parse.(Int, lines[2:end])
end

const cur_day = parse(Int, splitdir(@__DIR__)[end][5:end])
const raw_data = cur_day |> read_input
process_data() = raw_data |> x->split(x, "\n\n") .|> parse_player

function part1()
    data = process_data()
    player1, player2 = data
    deck1 = player1[2]
    deck2 = player2[2]

    while length(deck1) > 0 && length(deck2) > 0
        card1 = popfirst!(deck1)
        card2 = popfirst!(deck2)
        if card1 > card2
            push!(deck1, card1)
            push!(deck1, card2)
        else
            push!(deck2, card2)
            push!(deck2, card1)
        end
    end
    winning_deck = length(deck1) > 0 ? deck1 : deck2
    sum(winning_deck .* collect(length(winning_deck):-1:1))
end

# returns both decka and if player 1 wins
function play_game(deck1, deck2)
    configurations = Set()
    while length(deck1) > 0 && length(deck2) > 0
        # infinite game prevention
        if (deck1, deck2) ∈ configurations
            return deck1, deck2, true
        end
        push!(configurations, (copy(deck1), copy(deck2)))
        card1 = popfirst!(deck1)
        card2 = popfirst!(deck2)
        if length(deck1) >= card1 && length(deck2) >= card2
            _, _, player1won = play_game(copy(deck1[1:card1]), copy(deck2[1:card2]))
        else
            player1won = card1 > card2
        end
        if player1won
            push!(deck1, card1)
            push!(deck1, card2)
        else
            push!(deck2, card2)
            push!(deck2, card1)
        end
    end
    deck1, deck2, length(deck1) != 0
end

function part2()
    data = process_data()
    player1, player2 = data
    deck1 = player1[2]
    deck2 = player2[2]
    deck1, deck2 = play_game(deck1, deck2)
    winning_deck = length(deck1) > 0 ? deck1 : deck2
    sum(winning_deck .* collect(length(winning_deck):-1:1))
end


end # module

if false
println(Day22.part1())
Day22.submit(Day22.part1(), Day22.cur_day, 1)
println(Day22.part2())
Day22.submit(Day22.part2(), Day22.cur_day, 2)
end
