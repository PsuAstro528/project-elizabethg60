#test one: confirm that if no moon is present then recovered velocity is approx the same at each timestamp





#test one: confirm recovered weighted velocity decrease as grid size increases
#test two: confirm norm of patch vectors from sun center equal sun radius 
#test three: confirm that if moon radius = sun radius then recovered velocity goes to zero
#test four: confirm that if no moon present then recovered velocity approx the same at each timestamp 









#to be addressed: 
	#1. need to get Test depedency working to run tests as follow 
		# using Test, MyProject

		# # Add your tests below

		# @testset "Test Set 1" begin 
		#    @test 1 == 1
		#    addfive(0) == 5
		#    addfive(1) == 6
		# end;
		# # julia-actions/julia-runtest
		# touch(joinpath(ENV["HOME"], "julia-runtest"))

	#2. need to get PyPlot depedency working for plot checks 
		#mu_grid check 
			# cnorm = mpl.colors.Normalize(minimum(mu_grid), maximum(mu_grid))
			# colors = mpl.cm.viridis(cnorm(mu_grid))

			# xs = getindex.(OP_bary, 1)
			# ys = getindex.(OP_bary, 2)
			# zs = getindex.(OP_bary, 3)

			# dx = rad2deg.((ys .- mean(ys)) ./ norm(earth_pv[1:3] .- sun_pv[1:3]))
			# dy = rad2deg.((zs .- mean(zs)) ./ norm(earth_pv[1:3] .- sun_pv[1:3]))

			# dx *= 60.0
			# dy *= 60.0

			# pcm = plt.pcolormesh(dx, dy, mu_grid, vmin=-1.0, vmax=1.0)
			# #plt.xlabel(L"\Delta x\ {\rm (arcmin)}")
			# #plt.ylabel(L"\Delta y\ {\rm (arcmin)}")
			# cb = plt.colorbar(norm=cnorm, ax=plt.gca())
			# #cb.set_label(L"\mu")
			# plt.show()

		#projected velocity grid check
			# cnorm = mpl.colors.Normalize(minimum(projected_velocities), maximum(projected_velocities))
			# colors = mpl.cm.seismic(cnorm(projected_velocities))

			# pcm = plt.pcolormesh(dx, dy, projected_velocities, cmap="seismic",)
			# #plt.xlabel(L"\Delta x\ {\rm (arcmin)}")
			# #plt.ylabel(L"\Delta y\ {\rm (arcmin)}")
			# cb = plt.colorbar(pcm, norm=cnorm, ax=plt.gca())
			# cb.set_label("projected velocity (m/s)")
			# plt.show()