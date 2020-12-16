using DrWatson
quickactivate(@__DIR__)
using BenchmarkTools
include("main.jl")
println(Day15.part1())
println(@benchmark Day15.part1())
println(Day15.part2())
println(@benchmark Day15.part2())
