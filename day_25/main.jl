module Day25

using DrWatson
quickactivate(@__DIR__)
include(projectdir("misc.jl"))

const cur_day = parse(Int, splitdir(@__DIR__)[end][5:end])
const raw_data = cur_day |> read_input
process_data() = raw_data |> read_lines .|> x->parse(Int, x)
test_data = 5764801, 17807724

do_loop(i, j) = (i * j) % 20201227

function part1()
    data = process_data()
    # data = test_data
    pub1, pub2 = data

    cur = 1
    loop1 = 0
    while cur != pub1
        cur = do_loop(cur, 7)
        loop1 += 1
    end

    cur = 1
    loop2 = 0
    while cur != pub2
        cur = do_loop(cur, 7)
        loop2 += 1
    end

    cur = 1
    loop3 = 0
    for i in 1:loop1
        cur = do_loop(cur, pub2)
    end

    cur
end

function part2()
    data = process_data()
end


end # module

if false
println(Day25.part1())
Day25.submit(Day25.part1(), Day25.cur_day, 1)
println(Day25.part2())
Day25.submit(Day25.part2(), Day25.cur_day, 2)
end
