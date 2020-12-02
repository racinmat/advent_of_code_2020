import os
import os.path as osp
for i in range(1, 26):
    os.makedirs(f'day_{i:02d}', exist_ok=True)
    open(f'day_{i:02d}/input.txt', 'w+').close()
    with open(f'day_{i:02d}/main.jl', 'w+') as f:
        f.write(f"""
module Day:{i:02d}

using DrWatson
quickactivate(@__DIR__)
include(projectdir("misc.jl"))

const cur_day = parse(Int, splitdir(@__DIR__)[end][5:end])
const data = cur_day |> read_input

function part1()
    data
end

function part2()
    data
end

if false
println(part1())
submit(part1(), cur_day, 1)
println(part2())
submit(part2(), cur_day, 2)
end
""")
