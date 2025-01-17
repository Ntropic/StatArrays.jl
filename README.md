# StatArrays

[![Build Status](https://github.com/Ntropic/StatArrays.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/Ntropic/StatArrays.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/Ntropic/StatArrays.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/Ntropic/StatArrays.jl)

**StatArrays.jl** provides a flexible data structure, `StatArray`, for statistical data storage and analysis in Julia. Each element of a `StatArray` contains a vector of data points, with built-in methods to compute key statistics such as the mean, standard deviation, and variance. 

### Key Features:
- **Efficient Data Storage**: Each element of a `StatArray` stores a vector of values for statistical analysis.
- **Built-in Statistical Methods**:
  - `mean`, `std`, `var`: Compute the mean, standard deviation, and variance.
  - `lower_std`, `upper_std`: Calculate standard deviations for values below or above the mean.
  - `val`: Access the vectors of sample values 
- **Flexible Indexing**:
  - Append data ona single element using `A[1,1] += value` or `A[1,1] = [value1, value2, ...]`.
  - Manipulate slices of the array at once using `A[:, 1] += value` or `A[:, 1] += [value1, value2, ...]`.
  - Rescale a slice using `A[:, 1] *= c` or `A[:, 1] /= c`.
  - Append arrays & slices using `A[:,1] + B[:,1]` or `A[:, 1] += B[:,1]`.

## Installation

To install the package, run:
```julia
using Pkg
Pkg.add("StatArrays")
``` 

## Usage
``` 
using StatArrays 
A = StatArray{Float64}(2, 2)
A[1, 1] += 1.0
A[:, 1] += 2.0
A[1, :] += 3.0
println(A[1, 1].vals) # prints [1.0, 2.0, 3.0]
println(A[1, 1].mean) # prints 2.0
println(A[1, 1].std) # prints 0.816496580927726
println(A[2,2].std) # prints NaN (since we didn't store any values)
```
This functionality allows us to eaily store samples for every entry of an array, without having to worry about the storage of those samples. 

## Author 
Michael Schilling