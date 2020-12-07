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
    vertex_names = collect(keys(data))
    g = SimpleDiGraph(length(data))
    mg = MetaDiGraph(g)
    for (i, v_name) in enumerate(vertex_names)
        set_indexing_prop!(mg, i, :name, v_name)
    end
    mg
end

function data2graph(data)
    mg = make_vertices(data)
    for (v_from, vs_to) in data
        for (v_to, e_num) in vs_to
            add_edge!(mg, mg[v_from, :name], mg[v_to, :name])
            set_prop!(mg, mg[v_from, :name], mg[v_to, :name], :num, e_num)
        end
    end
    mg
end

const cur_day = parse(Int, splitdir(@__DIR__)[end][5:end])
const raw_data = cur_day |> read_input
process_data() = raw_data .|> x->read_lines(x, "\n") .|> parse_row |> Dict

# v_from, vs_to = collect(data)[1]
test_data = cur_day |> x->read_file(x, "test_input.txt") .|> x->read_lines(x, "\n") .|> parse_row |> Dict

function part1()
    data = process_data()
    # data = test_data
    g = reverse(data2graph(data))
    target_bag = "shiny gold"

    res = bfs_tree(g, g[target_bag, :name])
    edges(res) .|> dst |> length
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
