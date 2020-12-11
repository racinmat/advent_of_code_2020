module Day11

using DrWatson
quickactivate(@__DIR__)
include(projectdir("misc.jl"))

using StatsBase
using DSP
using ImageFiltering
numone=[2,3,4,5,6]
numtwo=[1,2,3]
xcorr(numone, numtwo, padmode=:none)
ones(3,3)

const cur_day = parse(Int, splitdir(@__DIR__)[end][5:end])
const raw_data = cur_day |> read_input
process_data() = raw_data |> replace_chars("."=>"0", "L"=>"1") |> read_lines .|> collect .|> (x->parse.(Int, x)) |> x->hcat(x...)'
test_data = cur_day |> read_file("test_input.txt") |> replace_chars("."=>"0", "L"=>"1") |> read_lines .|> collect .|> (x->parse.(Int, x)) |> x->hcat(x...)'

mat = centered(ones(Int, 3,3))

function print_mat(A)
    translator = Dict(0=>".",10=>"#",1=>"L")
    A .|> (x->translator[x]) |> eachrow .|> join .|> println
    println()
end

function do_step_v1(data)
    new_data = copy(data)
    res = imfilter(new_data, mat, Fill(0, mat))
    new_data[(res .< 10) .& (data .!= 0)] .= 10
    new_data[(res .>= 50) .& (data .== 10)] .= 1
    new_data
end

idxs2vals(A,a,b) = @inbounds zip(a,b) .|> CartesianIndex .|> x->A[x]
function arrs8dirs(A, i::CartesianIndex)
    m,n = size(A)
    k, l = i.I

    dir_n = A[begin:k-1,l]
    dir_s = A[k+1:end,l]
    dir_w = A[k,begin:l-1]
    dir_e = A[k,l+1:end]

    dir_nw = idxs2vals(A, k-1:-1:1+k-min(k,l), l-1:-1:1+l-min(k,l))
    dir_ne = idxs2vals(A, k-1:-1:k-min(k,n-l), l+1:1:l+1+min(k,n-l))
    dir_se = idxs2vals(A, k+1:1:min(m-k,n-l)+k, l+1:1:min(m-k,n-l)+l)
    dir_sw = idxs2vals(A, k+1:1:k+min(m-k,l-1), l-1:-1:l-min(m-k,l-1))
    # @info i dir_n dir_s dir_w dir_e dir_ne dir_nw dir_se dir_sw
    @info i dir_ne dir_nw dir_se dir_sw
    dir_n, dir_s, dir_w, dir_e, dir_ne, dir_nw, dir_se, dir_sw
end

function is1st_sitting(A::Matrix,a,b)
    @inbounds for (i,j) in zip(a,b)
        A[i,j] == 1 && return false
        A[i,j] == 10 && return true
    end
    false
end

function is1st_sitting(A::Vector)
    for i in A
        i == 1 && return false
        i == 10 && return true
    end
    false
end

function sitting8dirs(A, i::CartesianIndex)
    m,n = size(A)
    k, l = i.I

    sittings = 0
    sittings += is1st_sitting(A[begin:k-1,l])
    sittings += is1st_sitting(A[k+1:end,l])
    sittings += is1st_sitting(A[k,begin:l-1])
    sittings += is1st_sitting(A[k,l+1:end])
    sittings += is1st_sitting(A, k-1:-1:1+k-min(k,l), l-1:-1:1+l-min(k,l))
    sittings += is1st_sitting(A, k-1:-1:k-min(k,n-l), l+1:1:l+1+min(k,n-l))
    sittings += is1st_sitting(A, k+1:1:min(m-k,n-l)+k, l+1:1:min(m-k,n-l)+l)
    sittings += is1st_sitting(A, k+1:1:k+min(m-k,l-1), l-1:-1:l-min(m-k,l-1))
    sittings
end

A = reshape(1:50, 10, 5)
i = CartesianIndex(10, 3)
i = CartesianIndex(1, 1)
for i in CartesianIndices(A)
    arrs8dirs(A,i)
end
function do_step_v2(data)
    new_data = copy(data)
    res = imfilter(new_data, mat, Fill(0, mat))
    i = CartesianIndices(new_data)[80]
    A=data
    new_data[(res .< 10) .& (data .!= 0)] .= 10
    @inbounds for i in CartesianIndices(data)
        data[i] == 0 && continue
        num_sits = sitting8dirs(data, i)
        if num_sits >= 5
            new_data[i] = 1
        end
    end
    new_data
end

function find_equilibrium(data, step_fun)
    while true
        print_mat(data)
        new_data = step_fun(data)
        print_mat(new_data)
        if data == new_data
            return data
        end
        data = new_data
    end
end

function part1()
    data = process_data()
    # data = test_data
    data *= 1  # the goal is to have L=1 and #=10
    data = find_equilibrium(data, do_step_v1)
    sum(data .== 10)
end
step_fun = do_step_v2
function part2()
    data = process_data()
    data = test_data
    data *= 1  # the goal is to have L=1 and #=10
    data = find_equilibrium(data, do_step_v2)
    sum(data .== 10)
end


end # module

if false
println(Day11.part1())
Day11.submit(Day11.part1(), Day11.cur_day, 1)
println(Day11.part2())
Day11.submit(Day11.part2(), Day11.cur_day, 2)
end
