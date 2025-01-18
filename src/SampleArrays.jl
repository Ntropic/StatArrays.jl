module SampleArrays
using Printf
export Samples, SampleArray, show, string, size, length, eltype, mean, std, var, lower_std, upper_std, +, *, /


struct Samples{T}
    data::Vector{T}
end

function Samples{T}() where {T}
    Samples{T}(Vector{T}())
end

function Base.:+(s::Samples{T}, x::T) where {T}
    push!(s.data, x)  # in-place append
    return s
end
function Base.:+(s::Samples{T}, xs::AbstractVector{T}) where {T}
    append!(s.data, xs)  # in-place append of a vector
    return s
end
function Base.:+(s::Samples{T}, t::Samples{T}) where {T}
    # Concatenate two Samples.
    return Samples{T}(vcat(s.data, t.data))
end

function Base.:*(s::Samples{T}, α::Real) where {T}
    # Make a *new* Samples with each old value scaled by α.
    return Samples{T}([x*α for x in s.data])
end
function Base.:/(s::Samples{T}, α::Real) where {T}
    return Samples{T}([x/α for x in s.data])
end


function mean(s::Samples{T}) where {T}
    n = length(s.data)
    return n == 0 ? NaN : sum(s.data) / n
end
function var(s::Samples{T}) where {T}
    n = length(s.data)
    n < 2 && return NaN
    μ = mean(s)
    return sum((x - μ)^2 for x in s.data) / n
end
function std(s::Samples{T}) where {T}
    return sqrt(var(s))
end
function lower_std(s::Samples{T}) where {T}
    n = length(s.data)
    if n < 2
        return NaN
    end
    μ = mean(s)
    lower_vals = filter(x -> x < μ, s.data)
    length(lower_vals) < 2 && return NaN
    dev = sum((μ - x)^2 for x in lower_vals) / length(lower_vals)
    return sqrt(dev)
end
function upper_std(s::Samples{T}) where {T}
    n = length(s.data)
    if n < 2
        return NaN
    end
    μ = mean(s)
    upper_vals = filter(x -> x >= μ, s.data)
    length(upper_vals) < 2 && return NaN
    dev = sum((x - μ)^2 for x in upper_vals) / length(upper_vals)
    return sqrt(dev)
end
function min(s::Samples{T}) where {T}
    n = length(s.data)
    if n == 0
        return NaN
    end
    return minimum(s.data)
end
function max(s::Samples{T}) where {T}
    n = length(s.data)
    if n == 0
        return NaN
    end
    return maximum(s.data)
end

function Base.string(s::Samples{T}) where {T}
    m = @sprintf("%.2g", mean(s))
    s_val = @sprintf("%.2g", std(s))
    return "$(m)±$(s_val)"
end
function Base.show(io::IO, A::Samples)
    print(io, string(A))
end
function Base.show(io::IO, ::MIME"text/plain", A::Samples)
    print(io, string(A))
end
function Base.show(io::IO, ::MIME"text/html", A::Samples)
    print(io, string(A))
end


function SampleArray(dims::Int...; type::Type=Float64)
arr = Array{Samples{type}}(undef, dims...)
for idx in eachindex(arr)
    arr[idx] = Samples{type}()
end
return arr
end

function Base.getproperty(s::Samples, prop::Symbol)
    # If prop matches any “computed” property, return it
    if prop === :mean
        return mean(s)
    elseif prop === :std
        return std(s)
    elseif prop === :vals 
        return s.data
    elseif prop === :var
        return var(s)
    elseif prop === :lower_std
        return lower_std(s)
    elseif prop === :upper_std
        return upper_std(s)
    elseif prop === :min
        return min(s)
    elseif prop === :max
        return max(s)
    else
        # otherwise, fall back to normal field access
        return getfield(s, prop)
    end
end
function Base.getproperty(obj::Array{Samples{T}}, prop::Symbol) where {T}
    if prop === :mean
        return map(mean, obj)  # Apply `mean` to each element in `obj.data`
    elseif prop === :std
        return map(std, obj)  # Apply `std` to each element in `obj.data`
    elseif prop === :vals 
        return map(vals, obj)  # Apply `vals` to each element in `obj.data`
    elseif prop === :var
        return map(var, obj)  # Apply `var` to each element in `obj.data`
    elseif prop === :lower_std
        return map(lower_std, obj)  # Apply `lower_std` to each element in `obj.data`
    elseif prop === :upper_std
        return map(upper_std, obj)  # Apply `upper_std` to each element in `obj.data`
    elseif prop === :min
        return map(min, obj)  # Apply `min` to each element in `obj.data`
    elseif prop === :max
        return map(max, obj)  # Apply `max` to each element in `obj.data`
    else
        # For fields, fall back to normal field access
        return getfield(obj, prop)
    end
end

end