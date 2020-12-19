module Day16

using DrWatson
quickactivate(@__DIR__)
include(projectdir("misc.jl"))

using Intervals, Base.Iterators

function parse_departure(str)
    m = match(r"([\w ]+): (\d+)-(\d+) or (\d+)-(\d+)", str)
    ints = parse.(Int, [m[2], m[3], m[4], m[5]])
    m[1], Interval{Closed, Closed}(ints[1:2]...), Interval{Closed, Closed}(ints[3:4]...)
end

function parse_input(departures, my_ticket, other_tickets)
    conditions = departures |> read_lines .|> parse_departure
    my_ticket_nums = read_lines(my_ticket)[2] |> x->read_numbers(x, ",")
    other_tickets_nums = read_lines(other_tickets)[2:end] .|> x->read_numbers(x, ",")
    conditions, my_ticket_nums, other_tickets_nums
end

const cur_day = parse(Int, splitdir(@__DIR__)[end][5:end])
const raw_data = cur_day |> read_input
process_data() = raw_data |> x->split(x, "\n\n") |> x->parse_input(x...)
test_data = cur_day |>read_file("test_input.txt") |> x->split(x, "\n\n") |> x->parse_input(x...)
test_data = cur_day |>read_file("test_input_2.txt") |> x->split(x, "\n\n") |> x->parse_input(x...)

function part1()
    data = process_data()
    # data = test_data
    conditions, my_ticket_nums, other_tickets_nums = data
    all_nums = other_tickets_nums |> flatten |> collect
    sum(filter(i->!any(c->any(i .∈ c[2:3]), conditions), all_nums))
end

function part2()
    data = process_data()
    # data = test_data
    conditions, my_ticket_nums, other_tickets_nums = data
    valid_tickets = hcat(my_ticket_nums, filter(j->all(i->any(c->any(i .∈ c[2:3]), conditions), j), other_tickets_nums)...)'
    valid_mappings = Dict(i=>findall(cond->all(i->any(i .∈ cond[2:3]), col), conditions) for (i, col) in enumerate(eachcol(valid_tickets)))
    # valid_mappings
    true_mapping = Dict{Int, Int}()
    while length(true_mapping) < length(valid_mappings)
        certain = Dict(first(v)=>k for (k, v) in valid_mappings if length(v) == 1)
        merge!(true_mapping, certain)
        vals2remove = keys(certain)
        foreach(kv->deleteat!(kv[2], findall(x->x ∈ vals2remove,kv[2])), valid_mappings)
    end
    # true_mapping
    col_names = Dict(name=>true_mapping[i] for  (i, name) in enumerate(getindex.(conditions, 1)))
    departure_fields = filter(x->startswith(x, "departure"), keys(col_names))
    departure_idxs = getindex.(Ref(col_names), departure_fields)
    prod(my_ticket_nums[departure_idxs])
end


end # module

if false
println(Day16.part1())
Day16.submit(Day16.part1(), Day16.cur_day, 1)
println(Day16.part2())
Day16.submit(Day16.part2(), Day16.cur_day, 2)
end
