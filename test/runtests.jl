include("../src/SampleArrays.jl")
using .SampleArrays  # Use the local module
using Test

@testset "SampleArrays.jl" begin
    # Create a 2x2 StatArray
    A = SampleArray(2, 2, type=Float64)
    
    # Test single index appending
    A[1, 1] += 1.0
    A[:, 1] .+= 2.0
    A[1, :] .+= 3.0
    
    # Validate statistics
    @test A[1, 1].vals == [1.0, 2.0, 3.0]
    @test A[1, 1].mean ≈ 2.0
    @test A[1, 1].std ≈ 0.816496580927726
    @test A[1, 1].var ≈ 0.6666666666666666
    @test isnan(A[1, 1].lower_std )
    @test A[1,1].min == 1.0
    @test A[1, 1].max == 3.0
    @test A[1, 1].upper_std ≈ 0.7071067811865476

end
