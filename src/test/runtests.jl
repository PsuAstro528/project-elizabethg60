using Test, MyProject, SPICE

#tests ran for singular timestamp for NEID eclipse

#NEID location 
obs_lat = 31.9583 
obs_long = -111.5967  
alt = 2.097938
#timestamp for tests
epoch = utc2et("2023-10-14T16:00:45")

@testset "Test Set 1: Unit Tests" begin
	#confirm recovered weighted velocity increases as grid size increases in the case of no moon
	@test MyProject.compute_rv(100,100, epoch, 0, obs_long, obs_lat, alt, moon_r = 0.0)[1] > MyProject.compute_rv(50,50, epoch, 0, obs_long, obs_lat, alt, moon_r = 0.0)[1]
	#above test for parallel code
	@test MyProject.compute_rv_pa(100,100, epoch, obs_long, obs_lat, alt, moon_r = 0.0)[1] > MyProject.compute_rv_pa(50,50, epoch, obs_long, obs_lat, alt, moon_r = 0.0)[1]
end

@testset "Test Set 2: Integration Tests" begin
	#confirm that if moon radius >> sun radius that recovered velocity is nan (nothing visible)
    @test isnan(MyProject.compute_rv(100,100, epoch, 0, obs_long, obs_lat, alt, moon_r = 696340*5.0)[1])
	#above test for parallel code
	@test isnan(MyProject.compute_rv_pa(100,100, epoch, obs_long, obs_lat, alt, moon_r = 696340*5.0)[1])

	#confirm that is no moon present then recovered velocity approx the same at max epoch and first timestamp 
	max = MyProject.compute_rv(100,100, epoch, 0, obs_long, obs_lat, alt, moon_r = 0.0)[1]
	first = MyProject.compute_rv(100,100, utc2et("2023-10-14T15:26:18"), 0,obs_long, obs_lat, alt, moon_r = 0.0)[1]
	@test isapprox(-max,first; rtol = 1)
	#above test for parallel code
	max = MyProject.compute_rv_pa(100,100, epoch, obs_long, obs_lat, alt, moon_r = 0.0)[1]
	first = MyProject.compute_rv_pa(100,100, utc2et("2023-10-14T15:26:18"), obs_long, obs_lat, alt, moon_r = 0.0)[1]
	@test isapprox(-max,first; rtol = 1)

	#integration test between serial and parallel code
	max_serial = MyProject.compute_rv(100,100, epoch, 0, obs_long, obs_lat, alt, moon_r = 0.0)[1]
	max_parallel = MyProject.compute_rv_pa(100,100, epoch, obs_long, obs_lat, alt, moon_r = 0.0)[1]
	@test isapprox(max_serial, max_parallel; rtol = 1)
end  