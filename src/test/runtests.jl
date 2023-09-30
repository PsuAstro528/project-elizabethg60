using Test, MyProject

@testset "Test Set 1: Unit Tests" begin
	#confirm recovered weighted velocity decreases as grid size increases
	@test MyProject.max_epoch_v(100,100) < MyProject.max_epoch_v(50,50)

	#confirm that matrices that represent center of sun to patch have norm equal to sun radius 
	#@test norm.(SP_sun) == sun_radius #how to access these local variables for test????
end

# @testset "Test Set 2: Integration Tests" begin
# 	#confirm that if moon radius >> sun radius that recovered velocity is zero
# 	@test MyProject.max_epoch_v(100,100, moon_r = (696340.0*50)) == 0.0

# 	#next test: confirm that if no moon present then recovered velocity approx the same at each timestamp 
# end 