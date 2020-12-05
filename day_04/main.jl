module Day04

using DrWatson
quickactivate(@__DIR__)
include(projectdir("misc.jl"))

str2dict(x) = Dict(x .|> y->split(y, ":"))

const cur_day = parse(Int, splitdir(@__DIR__)[end][5:end])
const raw_data = cur_day |> read_input
process_data() = raw_data |> x->read_lines(x, "\n\n") .|> x->split(x, (' ', '\n')) |> str2dict

function part1()
    data = process_data()
    fields = ["byr", "iyr", "eyr", "hgt", "hcl", "ecl", "pid"]
    (data .|> x->all(haskey.(Ref(x), fields))) |> sum
end

function part2()
    data = process_data()
    fields = Dict(
        "byr" => x-> (n = tryparse(Int, x); !isnothing(n) && 1920<=n<=2002),
        "iyr" => x-> (n = tryparse(Int, x); !isnothing(n) && 2010<=n<=2020),
        "eyr" => x-> (n = tryparse(Int, x); !isnothing(n) && 2020<=n<=2030),
        "hgt" => x->
        if endswith(x, "cm")
            height = parse(Int, replace(x, "cm"=>""))
            150 <= height <= 193
        elseif endswith(x, "in")
            height = parse(Int, replace(x, "in"=>""))
            59 <= height <= 76
        else
            false
        end,
        "hcl" => x->!isnothing(match(r"^#[0-9a-f]{6}$"i, x)),
        "ecl" => x->x ∈ ["amb", "blu", "brn", "gry", "grn", "hzl", "oth"],
        "pid" => x->!isnothing(match(r"^\d{9}$", x)),
    )
    (data .|> x->all([cond(get(x, key, "")) for (key, cond) in fields])) |> sum
end


end # module

if false
println(Day04.part1())
Day04.submit(Day04.part1(), Day04.cur_day, 1)
println(Day04.part2())
Day04.submit(Day04.part2(), Day04.cur_day, 2)
end
