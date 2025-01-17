module SampleArrays
export SampleArray, show, display, string, size, length, eltype, sample_sizes, all_same_sample_size, mean, std, var, lower_std, upper_std, +, *, /

# Define the SampleArray type
struct SampleArray{T, N} <: AbstractArray{Vector{T}, N}
    data::Array{Vector{T}, N}
    eltype::Type
end

# Constructor: Initialize SampleArray with given dimensions
function SampleArray{T}(dims::Int...) where {T}
    # Create an uninitialized array of Vector{T}
    arr = Array{Vector{T}}(undef, dims...)
    
    # Initialize each element with a fresh Vector{T}()
    for idx in eachindex(arr)
        arr[idx] = Vector{T}()
    end
    
    # Return the SampleArray instance
    return SampleArray{T, length(dims)}(arr, T)

end
function _format_statarray(A::SampleArray)
    # Print a header with basic information
    return join(size(A), "x")*" SampleArray{$(eltype(A)), $(length(size(A)))}"
end
function Base.show(io::IO, A::SampleArray)
    print(io, _format_statarray(A))
end
function Base.show(io::IO, ::MIME"text/plain", A::SampleArray)
    print(io, _format_statarray(A))
end
function Base.show(io::IO, ::MIME"text/html", A::SampleArray)
    print(io, _format_statarray(A))
end
function Base.display(A::SampleArray)
    println(_format_statarray(A))
end
function Base.show(io::IO, ::MIME"text/markdown", A::SampleArray)
    print(io, _format_statarray(A))
end
function Base.show(io::IO, ::MIME"text/latex", A::SampleArray)
    print(io, _format_statarray(A))
end
function Base.string(A::SampleArray)
    return _format_statarray(A, format = :plain)
end

# 1. size
Base.size(A::SampleArray) = size(A.data)
Base.length(A::SampleArray) = length(A.data)
Base.eltype(A::SampleArray) = A.eltype

# To check sample sizes and whether they are all the same size
function sample_sizes(A::SampleArray) # return sample sizes 
    out = similar(A.data, Int)
    for idx in eachindex(A.data)
        out[idx] = length(A.data[idx])
    end
    return out
end
function all_same_sample_size(A::SampleArray) # Check if all sample sizes are the same

    sizes = sample_sizes(A)
    return all(x -> x == sizes[1], sizes)
end

function Base.setindex!(A::SampleArray, values::Array{Vector{T}}, I::Vararg{Any}) where {T}
    # Check for slicing by detecting `Colon`
    indices = Base.to_indices(A.data, I)
    for (idx, val) in zip(CartesianIndices(indices), values)
        A.data[idx] = val
    end
    #return A
end
function Base.setindex!(A::SampleArray, value::Vector{T}, I::Vararg{Any}) where {T}
    # Check for slicing by detecting `Colon`
    indices = Base.to_indices(A.data, I)
    for idx in CartesianIndices(indices)
        A.data[idx] = value
    end
    #return A
end
function Base.setindex!(A::SampleArray, value::T, I::Vararg{Any}) where {T}
    # Check for slicing by detecting `Colon`
    indices = Base.to_indices(A.data, I)
    for idx in CartesianIndices(indices)
        A.data[idx] = [value]
    end
    #return A
end
function Base.setindex!(A::SampleArray, values::SampleArray, I::Vararg{Any})
    # Normalize the indices
    indices = Base.to_indices(A.data, I)
    for (idx, val) in zip(CartesianIndices(indices), values.data)
        A.data[idx] = val
    end
end

function Base.getindex(A::SampleArray, I::Vararg{Any})
    # Check for slicing by detecting `Colon`
    if any(x -> x isa Colon, I)
        # Extract the appropriate slice of the underlying `data`
        sliced_data = A.data[I...]
        return SampleArray(sliced_data)
    else
        # Return the specific element as usual
        return A.data[I...]
    end
end
function Base.getindex(A::SampleArray, I::Vararg{Any})
    # Translate user-provided indices into canonical array indices
    indices = Base.to_indices(A.data, I)

    # Slice the data using the indices
    sliced_data = A.data[indices...]
    # if sliced data is a Vector{T}, convert it to a vector containing the vector of T
    if isa(sliced_data, Vector{eltype(A)}) 
        sliced_data = Vector{eltype(A)}[sliced_data]
    end
    # Create a new SampleArray with the sliced data
    return SampleArray{eltype(A), ndims(sliced_data)}(sliced_data, eltype(A))
end

function Base.getproperty(A::SampleArray, prop::Symbol)
    if prop == :mean
        v = mean(A)
    elseif prop == :std
        v = std(A)
    elseif prop == :var 
        v = var(A)
    elseif prop == :vals 
        v = A.data 
    elseif prop == :lower_std
        v = lower_std(A)
    elseif prop == :upper_std
        v = upper_std(A)
    else
        return getfield(A, prop)
    end
    if length(A.data) == 1
        return v[1]
    else
        return v
    end
end
# -----------------------------
# Statistical Methods
# -----------------------------
# Compute mean across the entire SampleArray
function mean(A::SampleArray)
    out = similar(A.data, Float64)
    for idx in eachindex(A.data)
        out[idx] = isempty(A.data[idx]) ? NaN : mean(A.data[idx])
    end
    return out
end
# Compute std across the entire SampleArray
function std(A::SampleArray)
    out = similar(A.data, Float64)
    for idx in eachindex(A.data)
        out[idx] = (length(A.data[idx]) < 2) ? NaN : std(A.data[idx])
    end
    return out
end
function var(A::SampleArray)
    out = similar(A.data, Float64)
    for idx in eachindex(A.data)
        out[idx] = (length(A.data[idx]) < 2) ? NaN : var(A.data[idx])
    end
    return out
end
# Compute lower standard deviation across the entire SampleArray
function lower_std(A::SampleArray)
    out = similar(A.data, Float64)
    for idx in eachindex(A.data)
        samples = A.data[idx]
        out[idx] = lower_std(samples)
    end
    return out
end
# Compute upper standard deviation across the entire SampleArray
function upper_std(A::SampleArray)
    out = similar(A.data, Float64)
    for idx in eachindex(A.data)
        samples = A.data[idx]
        out[idx] = upper_std(samples)
    end
    return out
end

function mean(data::Vector{T}) where T
    if length(data) < 1
        return NaN
    end
    out = sum(data) / length(data)
    return out
end
function std(data::Vector{T}) where T
    if length(data) < 2
        return NaN
    end
    return sqrt(sum((x - mean(data))^2 for x in data) / (length(data)))
end
function var(data::Vector{T}) where T
    if length(data) < 2
        return NaN
    end
    return sum((x - mean(data))^2 for x in data) / (length(data))
end

# Compute the lower standard deviation
function lower_std(data::Vector{T}) where T
    if isempty(data) || length(data) < 2
        return NaN
    end
    m = Statistics.mean(data)
    lower_samples = filter(x -> x < m, data)
    if length(lower_samples) < 2
        return NaN
    end
    return sqrt(sum((m - x)^2 for x in lower_samples) / length(lower_samples))
end
# Compute the upper standard deviation
function upper_std(data::Vector{T}) where T
    if isempty(data) || length(data) < 2
        return NaN
    end
    m = Statistics.mean(data)
    upper_samples = filter(x -> x >= m, data)
    if length(upper_samples) < 2
        return NaN
    end
    return sqrt(sum((x - m)^2 for x in upper_samples) / length(upper_samples))
end

function Base.:+(A::SampleArray{T,N}, value::T) where {T,N}
    # append value to each 
    B_data = copy(A.data)
    for idx in eachindex(A.data)
        push!(B_data[idx], value)
    end
    return SampleArray{T,N}(B_data, T)
end
function Base.:+(A::SampleArray{T,N}, value::Vector{T}) where {T,N}
    # append value to each 
    B_data = copy(A.data)
    for idx in eachindex(A.data)
        append!(B_data[idx], value)
    end
    return SampleArray{T,N}(B_data, T)
end
function Base.:*(A::SampleArray, scalar::T) where {T}
    # Create a new SampleArray of the same size
    result = SampleArray{T}(size(A)...)
    
    # Apply scalar multiplication to each vector in the SampleArray
    for idx in CartesianIndices(A.data)
        result.data[idx] = A.data[idx] .* scalar  # Element-wise multiplication
    end
    return result
end
function Base.:/(A::SampleArray, scalar::T) where {T}
    # Create a new SampleArray of the same size
    result = SampleArray{T}(size(A)...)
    
    # Apply scalar multiplication to each vector in the SampleArray
    for idx in CartesianIndices(A.data)
        result.data[idx] = A.data[idx] ./ scalar  # Element-wise multiplication
    end
    return result
end



end