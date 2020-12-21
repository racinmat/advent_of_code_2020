module Day21

using DrWatson
quickactivate(@__DIR__)
include(projectdir("misc.jl"))

using Base.Iterators

const cur_day = parse(Int, splitdir(@__DIR__)[end][5:end])
const raw_data = cur_day |> read_input

function parse_row(str)
    m = match(r"([\w ]+)\(contains ([\w, ]+)\)", str)
    split(m[1]), split(m[2], ", ")
end

process_data() = raw_data |> read_lines .|> parse_row

function compute_allergic_ingreditents(data)
    alergens = unique(flatten(getfield.(data, 2)))
    valid_mappings = Dict(alergen => collect(intersect((Set(i) for (i, a) in data if alergen ∈ a)...)) for alergen in alergens)

    true_mapping = Dict{AbstractString, AbstractString}()
    while length(true_mapping) < length(valid_mappings)
        certain = Dict(k=>first(v) for (k, v) in valid_mappings if length(v) == 1)
        merge!(true_mapping, certain)
        vals2remove = values(certain)
        foreach(kv->deleteat!(kv[2], findall(x->x ∈ vals2remove,kv[2])), valid_mappings)
    end
    true_mapping
end

function part1()
    data = process_data()
    true_mapping = compute_allergic_ingreditents(data)
    allergic_ingredients = values(true_mapping)
    sum(count(!in(allergic_ingredients), i) for (i, a) in data)
end

function part2()
    data = process_data()
    true_mapping = compute_allergic_ingreditents(data)
    allergic_ingredients = values(true_mapping)
    join(getfield.(sort(collect(true_mapping), by=kv->kv[1]), 2), ",")
end


end # module

if false
println(Day21.part1())
Day21.submit(Day21.part1(), Day21.cur_day, 1)
println(Day21.part2())
Day21.submit(Day21.part2(), Day21.cur_day, 2)
end
