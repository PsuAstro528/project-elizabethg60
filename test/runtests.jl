using Test, MyProject

# Add your tests below

@testset "Test Set 1" begin 
   @test 1 == 1
   addfive(0) == 5
   addfive(1) == 6
end;

# julia-actions/julia-runtest
touch(joinpath(ENV["HOME"], "julia-runtest"))

#plotting tests:

	# # CHANGE: PLOTTING
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


# 	x = getindex.(KP,1)
# 	y = getindex.(KP,2)
# 	z = getindex.(KP,3)
# 	fig = plt.figure()
# 	ax = fig.add_subplot(projection="3d")
# 	ax.scatter(x,y,z)
# 	ax.scatter(OK...)
# 	ax.set_xlabel("x")
# 	ax.set_ylabel("y")
# 	ax.set_zlabel("z")
# 	plt.show()


	# cnorm = mpl.colors.Normalize(minimum(projected_velocities), maximum(projected_velocities))
	# colors = mpl.cm.seismic(cnorm(projected_velocities))

	# pcm = plt.pcolormesh(dx, dy, projected_velocities, cmap="seismic",)
	# #plt.xlabel(L"\Delta x\ {\rm (arcmin)}")
	# #plt.ylabel(L"\Delta y\ {\rm (arcmin)}")
	# cb = plt.colorbar(pcm, norm=cnorm, ax=plt.gca())
	# cb.set_label("projected velocity (m/s)")
	# plt.show()

	# x = getindex.(BP_bary,1)
	# y = getindex.(BP_bary,2)
	# z = getindex.(BP_bary,3)
	# fig = plt.figure()
	# ax = fig.add_subplot(projection="3d")
	# ax.scatter(x,y,z)
	# ax.scatter(BO_bary..., label = "earth")
	# ax.scatter(moon_pv[1:3]...)
	# ax.set_xlabel("x")
	# ax.set_ylabel("y")
	# ax.set_zlabel("z")
	# plt.legend()
	# plt.show()