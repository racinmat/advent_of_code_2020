module Day19

using DrWatson
quickactivate(@__DIR__)
include(projectdir("misc.jl"))

function parse_rule(str)
    if '"' in str
        m = match(r"(\d+): \"(\w)\"", str)
        parse(Int, m[1]) => m[2]
    elseif '|' in str
        m = match(r"(\d+):((?: (?:\d+))+) \|((?: (?:\d+))+)", str)
        parse(Int, m[1]) => (parse.(Int, split(m[2])), parse.(Int, split(m[3])))
    else
        m = match(r"(\d+):((?: (?:\d+))+)", str)
        parse(Int, m[1]) => parse.(Int, split(m[2]))
    end
end

function parse_input(rules, texts)
    Dict(parse_rule.(rules)), texts
end

const cur_day = parse(Int, splitdir(@__DIR__)[end][5:end])
const raw_data = cur_day |> read_input
process_data() = raw_data |> x->split(x, "\n\n") .|> (x->split(x, "\n"))
test_data = cur_day |> read_file("test_input.txt") |> x->split(x, "\n\n") .|> (x->split(x, "\n"))

function rule2regex(rules, idx)
    @inbounds val = rules[idx]
    if val isa Vector{Int}
        reduce(*, rule2regex.(Ref(rules), val))
    elseif val isa AbstractString
        val
    elseif val isa Tuple
        idxs1, idxs2 = val
        reg1 = reduce(*, rule2regex.(Ref(rules), idxs1))
        reg2 = reduce(*, rule2regex.(Ref(rules), idxs2))
        # string interpolation is faster than concatenation in this case, benchmarked
        "(?:$reg1|$reg2)"
    end
end

function rule2regex2(rules, idx)
    @inbounds val = rules[idx]
    if idx == 8
        reg1 = rule2regex2(rules, 42)
        "(?:$reg1)+"
    elseif idx == 11
        reg1 = rule2regex2(rules, 42)
        reg2 = rule2regex2(rules, 31)
        make_regex(i) = "(($reg1){$i}($reg2){$i})"
        # fuck it, it's day 19, I'm lazy
        "(?:$(make_regex(1))|$(make_regex(2))|$(make_regex(3))|$(make_regex(4))|$(make_regex(5)))"
    elseif val isa Vector{Int}
        reduce(*, rule2regex2.(Ref(rules), val))
    elseif val isa AbstractString
        val
    elseif val isa Tuple
        idxs1, idxs2 = val
        reg1 = reduce(*, rule2regex2.(Ref(rules), idxs1))
        reg2 = reduce(*, rule2regex2.(Ref(rules), idxs2))
        "(?:$reg1|$reg2)"
    end
end

function part1()
    data = process_data()
    # data = test_data
    rules, texts = parse_input(data...)
    whole_regex = Regex("^"*rule2regex(rules, 0)*"\$")
    count(!isnothing, match.(whole_regex, texts))
end

function part2()
    data = process_data()
    # data = test_data
    rules, texts = parse_input(data...)
    whole_regex = Regex("^"*rule2regex2(rules, 0)*"\$")
    count(!isnothing, match.(whole_regex, texts))
end


end # module

if false
println(Day19.part1())
Day19.submit(Day19.part1(), Day19.cur_day, 1)
println(Day19.part2())
Day19.submit(Day19.part2(), Day19.cur_day, 2)
end
