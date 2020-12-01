import os
import os.path as osp
for i in range(1, 26):
    os.makedirs(f'day_{i}', exist_ok=True)
    open(f'day_{i}/input.txt', 'w+').close()
    with open(f'day_{i}/main.jl', 'w+') as f:
        f.write("""using DrWatson
quickactivate(@__DIR__)
include(projectdir("misc.jl"))

cur_day = parse(Int, splitdir(@__DIR__)[end][5:end])
data = read_input(cur_day)

function part1()
    data
end

function part2()
    data
end

println(part1())
submit(part1(), cur_day, 1)
println(part2())
submit(part2(), cur_day, 2)
""")
