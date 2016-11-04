function checkdiff(f, δf, x0...)
    x = [x0...]
    y0 = f(x...)
    @assert length(y0) == 1 "Scalar functions only"
    y, ∇f = δf(x...)
    if !isapprox(y0, y)
        error("function values do not match")
    end
    ∂x = ∇f()

    h = 1e-8

    for k = 1:length(x)
        ∂xx = length(x) == 1 ? ∂x : ∂x[k]
        if isa(x[k], AbstractFloat)
            x2 = deepcopy(x)
            x2[k] -= h
            y1 = f(x2...)
            x2 = deepcopy(x)
            x2[k] += h
            y2 = f(x2...)
            if !isapprox(2h * ∂xx, y2-y1, atol=h)
                error("gradient for argument #$k doesn't match")
            end
        elseif isa(x[k], AbstractVector)
            for l = 1:length(x[k])
                x2 = deepcopy(x)
                x2[k][l] -= h
                y1 = f(x2...)
                x2 = deepcopy(x)
                x2[k][l] += h
                y2 = f(x2...)
                if !isapprox(2h * ∂xx[l], y2-y1, atol=h)
                    error("gradient for argument #$k element $l doesn't match")
                end
            end
        elseif isa(x[k], AbstractArray)
            for l = 1:size(x[k], 1)
                for m = 1:size(x[k], 2)
                    x2 = deepcopy(x)
                    x2[k][l,m] -= h
                    y1 = f(x2...)
                    x2 = deepcopy(x)
                    x2[k][l,m] += h
                    y2 = f(x2...)
                    if !isapprox(2h * ∂xx[l,m], y2-y1, atol=h)
                        error("gradient for argument #$k element $l,$m doesn't match")
                    end
                end
            end
        else
            error("not supported argument type: $(typeof(x[k]))")
        end
    end
    true
end
