using DrWatson
quickactivate(@__DIR__)
using Pkg


# if Sys.iswindows()
# 	python_installation = read(`where python`, String) |> split |> x->x[1]
# 	ENV["PYTHON"] = python_installation
# 	Pkg.build("PyCall")
# elseif Sys.islinux()
# 	python_installation = read(`which python`, String) |> split |> x->x[1]
# 	ENV["PYTHON"] = python_installation
# 	Pkg.build("PyCall")
# end

using PyCall
pushfirst!(PyVector(pyimport("sys")."path"), joinpath(@__DIR__, "."))

function read_input(day::Int)
	misc = pyimport("misc")
	misc.read_day(day)
end

function submit(answer, day::Int, part::Int)
	misc = pyimport("misc")
	misc.submit_day(answer, day, part)
end

read_lines(data::AbstractString, delim='\n') = split(data, delim)
read_numbers(data::AbstractString, delim='\n') = parse.(Int, read_lines(data, delim))
read_number(data::AbstractString) = parse(Int, data)

function test_input(day::Int)
	data = open(joinpath("day_$day", "test_input.txt")) do f
		read(f, String)
	end
	data
end

function read_file(day::Int, filename)
	data = open(joinpath("day_$day", filename)) do f
		read(f, String)
	end
	data
end
