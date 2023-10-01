using Test, MyProject

@testset "Test Set 1: Unit Tests" begin
	#confirm recovered weighted velocity decreases as grid size increases in the case of no moon
	@test MyProject.max_epoch_v(100,100, moon_r = 0.0) < MyProject.max_epoch_v(50,50, moon_r = 0.0)

	#confirm that matrices that represent center of sun to patch have norm equal to sun radius 
	#@test norm.(SP_sun) == sun_radius #how to access these local variables for test????
end

@testset "Test Set 2: Integration Tests" begin
	#confirm that if moon radius >> sun radius that recovered velocity is nan (nothing visible)
	@test isnan(MyProject.max_epoch_v(100,100, moon_r = 696340*5.0))

	#confirm that is no moon present then recovered velocity approx the same at max epoch and first timestamp 
	max = MyProject.max_epoch_v(100,100, moon_r = 0.0)
	first = MyProject.loop(100,100, moon_r = 0.0)[1]
	@test isapprox(max,first; rtol = 0.1)
end 