using DrWatson
quickactivate(@__DIR__)
using BenchmarkTools, ProgressMeter, Printf, Dates, Pkg, Latexify
import DataFrames: DataFrame

max_day = 11

for day = 1:max_day
    include(@sprintf("day_%02d/main.jl", day))
end

pkg"precompile"

formatTime(t) = (1e9 * t) |> BenchmarkTools.prettytime

new_df() = DataFrame(part1_time = String[], part2_time = String[], part1_memory = String[], part2_memory = String[])
function benchmarkAll(; onlyOnce = false)
    df = new_df()
    for day = 1:max_day
        @info "benchmarking day" day
        module_name = Symbol(@sprintf("Day%02d", day))
        !isdefined(@__MODULE__, module_name) && continue
        benchmark(day=day, df=df, onlyOnce=onlyOnce)
    end
    show(df, summary=false, eltypes=false, rowlabel=:Day)
    df
end

function benchmark(; day::Int = min(Dates.day(Dates.today()), 25), df = new_df(), onlyOnce = false)
    module_name = Symbol(@sprintf("Day%02d", day))
    m = getproperty(@__MODULE__, module_name)
    t1 = onlyOnce ? @elapsed(m.part1()) : @benchmark($m.part1())
    t2 = onlyOnce ? @elapsed(m.part2()) : @benchmark($m.part2())
    if onlyOnce
        push!(df, [formatTime.((t1, t2))..., "-", "-"])
    else
        push!(df, [BenchmarkTools.prettytime.(time.((t1, t2)))...,  BenchmarkTools.prettymemory.(memory.((t1, t2)))...])
    end
    df
end

df = benchmarkAll()

print(latexify(df, env=:mdtable, latex=false, side=1:max_day))
df = benchmark(day=11)
print(latexify(df, env=:mdtable, latex=false, side=11))
