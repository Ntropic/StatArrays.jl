include("../src/SampleArrays.jl")
using .SampleArrays  # Use the local module
using Test

@testset "SampleArrays.jl" begin
    # Create a 2x2 StatArray
    A = SampleArray{Float64}(2, 2)
    
    # Test single index appending
    A[1, 1] += 1.0
    A[:, 1] += 2.0
    A[1, :] += 3.0
    
    # Validate statistics
    @test A[1, 1].vals == [1.0, 2.0, 3.0]
    @test A[1, 1].mean ≈ 2.0
    @test A[1, 1].std ≈ 0.816496580927726
    @test A[1, 1].var ≈ 0.6666666666666666
    
    # Test slicing and appending
    A[:, 2] = [4.0, 5.0]
    
    @test A[1, 2].vals == [4.0, 5.0] == A[2, 2].vals

end
