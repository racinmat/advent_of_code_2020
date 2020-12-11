module Day11

using DrWatson
quickactivate(@__DIR__)
include(projectdir("misc.jl"))

using ImageFiltering

using TimerOutputs
const to = TimerOutput()

const cur_day = parse(Int, splitdir(@__DIR__)[end][5:end])
const raw_data = cur_day |> read_input
process_data() = raw_data |> replace_chars("."=>"0", "L"=>"1") |> read_lines .|> collect .|> (x->parse.(Int, x)) |> x->hcat(x...)'
test_data = cur_day |> read_file("test_input.txt") |> replace_chars("."=>"0", "L"=>"1") |> read_lines .|> collect .|> (x->parse.(Int, x)) |> x->hcat(x...)'

const mat = centered(ones(Int, 3,3))

function print_mat(A)
    translator = Dict(0=>".",10=>"#",1=>"L")
    A .|> (x->translator[x]) |> eachrow .|> join .|> println
    println()
end

function do_step_v1(data)
    new_data = copy(data)
    do_step_v1!(data, new_data)
    new_data
end

function do_step_v1!(data, new_data)
    res = imfilter(new_data, mat, Fill(0, mat))
    new_data[(res .< 10) .& (data .!= 0)] .= 10
    new_data[(res .>= 50) .& (data .== 10)] .= 1
end

idxs2vals(A,a,b) = @inbounds zip(a,b) .|> CartesianIndex .|> x->A[x]
function arrs8dirs(A, i::CartesianIndex)
    m,n = size(A)
    k, l = i.I

    dir_n = A[k-1:-1:begin,l]
    dir_s = A[k+1:end,l]
    dir_w = A[k,l-1:-1:begin]
    dir_e = A[k,l+1:end]

    dir_nw = idxs2vals(A, k-1:-1:1+k-min(k,l), l-1:-1:1+l-min(k,l))
    dir_ne = idxs2vals(A, k-1:-1:k-min(k-1,n-l), l+1:1:l+min(k-1,n-l))
    dir_se = idxs2vals(A, k+1:1:min(m-k,n-l)+k, l+1:1:min(m-k,n-l)+l)
    dir_sw = idxs2vals(A, k+1:1:k+min(m-k,l-1), l-1:-1:l-min(m-k,l-1))
    # @info i dir_n dir_s dir_w dir_e dir_ne dir_nw dir_se dir_sw
    @info i A[i] dir_ne dir_nw dir_se dir_sw
    dir_n, dir_s, dir_w, dir_e, dir_ne, dir_nw, dir_se, dir_sw
end

function is1st_sitting(A::Matrix,a,b)
    @inbounds for (i,j) in zip(a,b)
        A[i,j] == 1 && return false
        A[i,j] == 10 && return true
    end
    false
end

function is1st_sitting(A::Union{Vector,SubArray})
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
    sittings += is1st_sitting(@view A[k-1:-1:begin,l]) # n
    sittings += is1st_sitting(@view A[k+1:end,l]) # s
    sittings += is1st_sitting(@view A[k,l-1:-1:begin]) # w
    sittings += is1st_sitting(@view A[k,l+1:end]) # e
    sittings += is1st_sitting(A, k-1:-1:1+k-min(k,l), l-1:-1:1+l-min(k,l)) # nw
    sittings += is1st_sitting(A, k-1:-1:k-min(k-1,n-l), l+1:1:l+min(k-1,n-l)) # ne
    sittings += is1st_sitting(A, k+1:1:min(m-k,n-l)+k, l+1:1:min(m-k,n-l)+l) # se
    sittings += is1st_sitting(A, k+1:1:k+min(m-k,l-1), l-1:-1:l-min(m-k,l-1)) # sw
    sittings
end

function do_step_v2(data)
    new_data = copy(data)
    do_step_v2!(data, new_data)
    new_data
end

function do_step_v2!(data, new_data)
    @inbounds Threads.@threads for i in findall(data .!= 0)
        #=@timeit to "sitting8dirs"=# num_sits = sitting8dirs(data, i)
        if num_sits >= 5 && data[i] == 10
            new_data[i] = 1
        elseif num_sits == 0 && data[i] == 1
            new_data[i] = 10
        end
    end
end

function find_equilibrium(data, step_fun)
    new_data = copy(data)
    while true
        # print_mat(data)
        #=@timeit to "step_fun"=#  step_fun(data, new_data)
        # print_mat(new_data)
        if #=@timeit to "data == new_data"=# data == new_data
            return data
        end
        data = copy(new_data)
    end
end

function part1()
    #=@timeit to "process_data"=#  data = process_data()
    # data = test_data
    data *= 1  # the goal is to have L=1 and #=10
    #=@timeit to "find_equilibrium"=#  data = find_equilibrium(data, do_step_v1!)
    sum(data .== 10)
end

function part2()
    #=@timeit to "process_data"=#  data = process_data()
    # data = test_data
    data *= 1  # the goal is to have L=1 and #=10
    #=@timeit to "find_equilibrium"=#  data = find_equilibrium(data, do_step_v2!)
    sum(data .== 10)
end


end # module

if false
println(Day11.part1())
Day11.submit(Day11.part1(), Day11.cur_day, 1)
Day11.reset_timer!(Day11.to)
println(Day11.part2())
display(Day11.to)
Day11.submit(Day11.part2(), Day11.cur_day, 2)
end
