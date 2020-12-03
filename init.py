import os
import os.path as osp
for i in range(1, 26):
    os.makedirs(f'day_{i:02d}', exist_ok=True)
    input_name = f'day_{i:02d}/input.txt'
    if not osp.isfile(input_name):
        open(input_name, 'w+').close()
    with open(f'day_{i:02d}/main.jl', 'w+') as f:
        f.write(f"""module Day{i:02d}

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


end # module

if false
println(Day{i:02d}.part1())
Day{i:02d}.submit(Day{i:02d}.part1(), Day{i:02d}.cur_day, 1)
println(Day{i:02d}.part2())
Day{i:02d}.submit(Day{i:02d}.part2(), Day{i:02d}.cur_day, 2)
end
""")
