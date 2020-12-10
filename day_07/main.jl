module Day07

using DrWatson
quickactivate(@__DIR__)
include(projectdir("misc.jl"))

using LightGraphs, MetaGraphs, Base.Iterators

function parse_row(str)
    parts = split(str, ", ")
    start = popfirst!(parts)
    m = match(r"(\w+ \w+) bags contain (?:(?:(\d+) (\w+ \w+))|(no other)) bags?", start)
    bag_from = m[1]
    if m[4] == "no other"
        bags_to = Dict{String, Int}()
    else
        bags_to = Dict(String(m[3]) => parse(Int, m[2]))
        for part in parts
            m = match(r"(\d+) (\w+ \w+) bags?", part)
            bags_to[m[2]] = parse(Int, m[1])
        end
    end
    bag_from, bags_to
end

function make_vertices(data)
    g = MetaDiGraph(SimpleDiGraph(length(data)))
    for (i, v_name) in enumerate(keys(data))
        set_indexing_prop!(g, i, :name, v_name)
    end
    g
end

function data2graph(data)
    mg = make_vertices(data)
    for (v_from, vs_to) in data
        for (v_to, e_num) in vs_to
            idx_from = mg[v_from, :name]
            idx_to = mg[v_to, :name]
            add_edge!(mg, idx_from, idx_to)
            set_prop!(mg, idx_from, idx_to, :num, e_num)
        end
    end
    mg
end

const cur_day = parse(Int, splitdir(@__DIR__)[end][5:end])
const raw_data = cur_day |> read_input
process_data() = raw_data .|> x->read_lines(x, "\n") .|> parse_row |> Dict

# v_from, vs_to = collect(data)[1]
# test_data = cur_day |> read_file("test_input.txt") .|> x->read_lines(x, "\n") .|> parse_row |> Dict

function part1()
    data = process_data()
    # data = test_data
    g = data2graph(data)
    target_bag = "shiny gold"
    # no need to revert the graph, if you use inneighbors
    n = nv(g)
    visited = falses(n)
    s = g[target_bag, :name]
    open_nodes = [s]
    @inbounds while !isempty(open_nodes)
        cur_node = pop!(open_nodes)
        @inbounds for n in inneighbors(g, cur_node)
            visited[n] && continue
            push!(open_nodes, n)
            visited[n] = true
        end
    end
    sum(visited)
end

function part2()
    data = process_data()
    g = data2graph(data)
    target_bag = "shiny gold"
    open_nodes = Tuple{Int, Int}[]
    total_bags = -1
    push!(open_nodes, (g[target_bag, :name], 1))
    while length(open_nodes) > 0
        cur_node, path_bags = pop!(open_nodes)
        for n in outneighbors(g, cur_node)
            num = get_prop(g, cur_node, n, :num)
            n_path_bags = path_bags * num
            push!(open_nodes, (n, n_path_bags))
        end
        total_bags += path_bags
    end
    total_bags
end


end # module

if false
println(Day07.part1())
Day07.submit(Day07.part1(), Day07.cur_day, 1)
println(Day07.part2())
Day07.submit(Day07.part2(), Day07.cur_day, 2)
end
