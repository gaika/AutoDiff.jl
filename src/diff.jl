macro δ(expr)
    esc(:( $expr; $(δ(parse_function(expr); ))))
end

function δ(ops)
    name = Symbol("δ$(ops.name)")
    func = :(function $name($(ops.inputs...)); end)
    body = func.args[2].args
    empty!(body)
    info = Expr(:line)
    nablas = []
    for line in ops.body
        if info != line.info
            info = line.info
            push!(body, info)
        end
        nabla = gensym("∇$(line.name)")
        push!(nablas, nabla)
        name = Symbol("δ$(line.name)")
        temp = gensym(name)
        push!(body, :($temp = $name($(line.inputs...))))
        for k in 1:length(line.outputs)
            push!(body, :($(line.outputs[k]) = $temp[$k]))
        end
        push!(body, :($nabla = $temp[$(length(line.outputs)+1)]))
    end
    push!(body, ∇(ops, nablas))
    push!(body, :($(ops.outputs...), $(Symbol("∇$(ops.name)"))))
    @show func
    func
end

function ∇(ops, nablas)
    name = Symbol("∇$(ops.name)")
    inputs =  [Symbol("∂$x") for x in ops.outputs]
    func = :(function $name($(inputs...)); end)
    if length(inputs) == 1
        func.args[1].args[2] = Expr(:kw, func.args[1].args[2], 1.0)
    end
    body = func.args[2].args
    empty!(body)
    info = Expr(:line)
    dupes = Set(inputs)
    for line in reverse(ops.body)
        if info != line.info
            info = line.info
            push!(body, info)
        end
        nabla = pop!(nablas)
        ins = [Symbol("∂$x") for x in line.outputs]
        outs = [Symbol("∂$x") for x in line.inputs]
        dedup = [in(k, dupes)? gensym(k) : (push!(dupes, k); k) for k in outs]
        push!(body, :($(to_tuple_or_expr(dedup)) = $nabla($(ins...))))
        [push!(body, :($(outs[k]) += $(dedup[k]))) for k in find(outs .!= dedup)]
    end

    outputs = [Symbol("∂$x") for x in ops.inputs]
    push!(body, to_tuple_or_expr(outputs))
    func
end

to_tuple_or_expr(symbols) = length(symbols) == 1 ? symbols[1] : Expr(:tuple, symbols...)