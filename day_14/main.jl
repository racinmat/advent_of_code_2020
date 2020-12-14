module Day14

using DrWatson
quickactivate(@__DIR__)
include(projectdir("misc.jl"))

using Memoize
const mapping = Dict('0'=>false, '1'=>true, 'X'=>missing)

function parse_row(x)
    if startswith(x, "mask ")
        m = match(r"mask = ((?:\d|X)+)", x)
        return "mask", getindex.(Ref(mapping), collect(m[1]))
    else
        m = match(r"mem\[(\d+)\] = (\d+)", x)
        return "mem", (parse(Int, m[1]), parse(Int, m[2]))
    end
    tryparse.(Int, split(x[2], ","))
end

const cur_day = parse(Int, splitdir(@__DIR__)[end][5:end])
const raw_data = cur_day |> read_input
process_data() = raw_data |> read_lines .|> parse_row
test_data = cur_day |> read_file("test_input.txt") |> read_lines .|> parse_row
test_data = cur_day |> read_file("test_input_2.txt") |> read_lines .|> parse_row

dec2bin(x) = parse.(Bool, collect(bitstring(x)))[end-35:end]
merge_with_mask(x, mask) = ismissing(mask) ? x : mask
bin2dec(x) = Int(reinterpret(UInt64, reverse(x).chunks)[1])

merge_with_mask2(x, mask) = isequal(mask, 0) ? x : mask

function part1()
    data = process_data()
    # data = test_data
    memory = Dict{Int, Int}()
    cur_mask = nothing
    for (i, j) in data
        if i == "mask"
            cur_mask = j
        elseif i == "mem"
            idx, val = j
            memory[idx] = bin2dec(merge_with_mask.(dec2bin(val), cur_mask))
        end
    end
    sum(values(memory))
end

sum_floats(pos, floatings) = sum(p*2^(f-1) for (p, f) in zip(pos, floatings))

@memoize function get_pair_combinations(i)
    collect(Iterators.product(fill(0:1,i)...))[:]
end

function part2()
    data = process_data()
    # data = test_data
    memory = Dict{Int, Int}()
    cur_mask = nothing
    i, j = data[2]
    for (i, j) in data
        if i == "mask"
            cur_mask = j
        elseif i == "mem"
            idx, val = j
            addresses = merge_with_mask2.(dec2bin(idx), cur_mask)
            addresses_rev = reverse(addresses)
            floatings = findall(ismissing, addresses_rev)
            base_num = sum(2 .^ (findall(isequal(true), addresses_rev).-1))
            all_combs = get_pair_combinations(length(floatings))
            @simd for pos in all_combs
                idx_i = sum_floats(pos, floatings) + base_num
                memory[idx_i] = val
            end
        end
    end
    sum(values(memory))
end


end # module

if false
println(Day14.part1())
Day14.submit(Day14.part1(), Day14.cur_day, 1)
println(Day14.part2())
Day14.submit(Day14.part2(), Day14.cur_day, 2)
end
