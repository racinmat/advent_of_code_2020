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

function data2rev_graph(data)
    mg = make_vertices(data)
    for (v_from, vs_to) in data
        for (v_to, e_num) in vs_to
            add_edge!(mg, mg[v_to, :name], mg[v_from, :name])
            set_prop!(mg, mg[v_to, :name], mg[v_from, :name], :num, e_num)
        end
    end
    mg
end

const cur_day = parse(Int, splitdir(@__DIR__)[end][5:end])
const raw_data = cur_day |> read_input
process_data() = raw_data .|> x->read_lines(x, "\n") .|> parse_row |> Dict

# v_from, vs_to = collect(data)[1]
# test_data = cur_day |> x->read_file(x, "test_input.txt") .|> x->read_lines(x, "\n") .|> parse_row |> Dict

function part1()
    data = process_data()
    # data = test_data
    rev_mg = data2rev_graph(data)
    target_bag = "shiny gold"

    res = bfs_tree(rev_mg, rev_mg[target_bag, :name])
    edges(res) .|> dst |> length
end

function part2()
    data = process_data()
    mg = data2graph(data)
    target_bag = "shiny gold"

    open_nodes = Int[]
    res = dfs_tree(mg, mg[target_bag, :name])
    neighbors(res, mg[target_bag, :name])
    outneighbors(res, mg[target_bag, :name])
    outneighbors(mg, mg[target_bag, :name])

    push!(open_nodes, mg[target_bag, :name])
    while length(open_nodes) > 0
        cur_node = pop!(open_nodes)
        edges(res, cur_node)
    end
    edges(res) .|> dst |> length
end


end # module

if false
println(Day07.part1())
Day07.submit(Day07.part1(), Day07.cur_day, 1)
println(Day07.part2())
Day07.submit(Day07.part2(), Day07.cur_day, 2)
end
