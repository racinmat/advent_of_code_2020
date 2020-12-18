module Day18

using DrWatson
quickactivate(@__DIR__)
include(projectdir("misc.jl"))

const cur_day = parse(Int, splitdir(@__DIR__)[end][5:end])
const raw_data = cur_day |> read_input
process_data() = raw_data |> read_lines

eval_pair(x, y::Char, expr) = eval_pair(x, parse(Int, y), expr)
function eval_pair(x, y::Number, op)
    if isnothing(x)
        y
    else
        if op == '*'
            x * y
        elseif op == '+'
            x + y
        end
    end
end

function eval_str(str)
    str
    depth = 0
    depth1start = 0
    depth1end = 0
    cur_val = nothing
    cur_symbol = nothing
    for (i, v) in enumerate(str)
        if v == '('
            depth += 1
            if depth == 1
                depth1start = i
            end
        elseif v == ')'
            depth -= 1
            if depth == 0
                depth1end = i
                subexpr_val = eval_str(str[depth1start+1:depth1end-1])
                cur_val = eval_pair(cur_val, subexpr_val, cur_symbol)
            end
        elseif depth == 0 && v in ('*', '+')
            cur_symbol = v
        elseif depth == 0 && isdigit(v)
            cur_val = eval_pair(cur_val, v, cur_symbol)
        end
    end
    cur_val
end

function infix2rpn(s)
    outputq = []
    opstack = []
    infix = split(replace_chars(s, "(" => "( ", ")" => " )"))
    for tok in infix
        if all(isdigit, tok)
            push!(outputq, tok)
        elseif tok == "("
            push!(opstack, tok)
        elseif tok == ")"
            while !isempty(opstack) && (op = pop!(opstack)) != "("
               push!(outputq, op)
            end
        else # operator
            while !isempty(opstack)
                op = pop!(opstack)
                # if op has higher precedence than tok
                if op == "+" && tok == "*"
                    push!(outputq, op)
                else
                    push!(opstack, op)  # undo peek
                    break
                end
            end
            push!(opstack, tok)
        end
        # println("The working output stack is $outputq")
    end
    while !isempty(opstack)
        if (op = pop!(opstack)) == "("
            throw("mismatched parentheses")
        else
            push!(outputq, op)
        end
    end
    outputq
end

function rpn(s)
    stack = Any[]
    for op in map(eval, map(Meta.parse, s))
        if isa(op, Function)
            arg2 = pop!(stack)
            arg1 = pop!(stack)
            push!(stack, op(arg1, arg2))
        else
            push!(stack, op)
        end
        # println("$op: ", join(stack, ", "))
    end
    length(stack) != 1 && error("invalid RPN expression $s")
    return stack[1]
end

eval_str_2(str) = rpn(infix2rpn(str))

function part1()
    data = process_data()
    sum(eval_str.(data))
end

function part2()
    data = process_data()
    sum(eval_str_2.(data))
end


end # module

if false
println(Day18.part1())
Day18.submit(Day18.part1(), Day18.cur_day, 1)
println(Day18.part2())
Day18.submit(Day18.part2(), Day18.cur_day, 2)
end
