### A Pluto.jl notebook ###
# v0.19.27

using Markdown
using InteractiveUtils

# ╔═╡ 842ac223-aa38-4fb1-956a-5eca1d6c1a0e
#determine xyz stellar coordinates for lat/long grid
begin
	function get_xyz(ρ::T, ϕ::T, θ::T) where T
	    # pre-compute trig quantitites
	    sinϕ = sin(ϕ)
	    sinθ = sin(θ)
	    cosϕ = cos(ϕ)
	    cosθ = cos(θ)
	
	    # now get cartesian coords
	    x = ρ * cosϕ * cosθ
		y = ρ * cosϕ * sinθ
	    z = ρ * sinϕ
	    return Vector{Float64}([x, y, z])
	end

	function get_xyz_for_surface(ρ::T; num_lats::Int=100, num_lons::Int=100) where T
	    # get grids of polar and azimuthal angles
	    ϕ = deg2rad.(range(-90.0, 90.0, length=num_lats))
	    θ = deg2rad.(range(0.0, 360.0, length=num_lons))'
	    return get_xyz.(ρ, ϕ, θ)
	end

	SP_sun = get_xyz_for_surface(sun_radius, num_lats = 100, num_lons = 100) #720 vs #1440

	#transform xyz stellar coordinates of grid from sun frame to ICRF
	function frame_transfer!(A::Matrix, b::Matrix)
		for i in 1:length(b)
			b[i] .= A*b[i]
		end
		return
	end

	SP_bary = deepcopy(SP_sun)
	frame_transfer!(pxform("IAU_SUN", "J2000", epoch), SP_bary)
end

# ╔═╡ f5dfb524-c6f9-4931-92b9-ba9be85cbe57
#determine vectors from Earth observatory surface to each patch
begin
	#determine xyz earth coordinates for lat/long of royal observatory
	obs_lat = 51.4769
	obs_long = -0.0005
	EO_earth = get_xyz(earth_radius, obs_lat, obs_long)
	#transform xyz earth coordinates from earth frame to ICRF
	EO_bary = pxform("IAU_EARTH", "J2000", epoch)*EO_earth

	#get vector from barycenter to observatory on Earth's surface
	BO_bary = earth_pv[1:3] .+ EO_bary
	#get vector from barycenter to each patch on Sun's surface
	BP_bary = deepcopy(SP_bary)
	for i in eachindex(BP_bary)
		BP_bary[i] .= sun_pv[1:3] .+ SP_bary[i]
	end
	#get vector from observatory on Earth's surface to Sun's center
	SO_bary = BO_bary .- sun_pv[1:3]

	#vectors from observatory on Earth's surface to each patch on Sun's surface
	function earth2patch_vectors!(A::Matrix, b::Vector, out::Matrix)
		for i in 1:length(A)	
			out[i] = A[i] .- b
		end
		return
	end 

	OP_bary = deepcopy(SP_bary)
	earth2patch_vectors!(SP_bary, SO_bary, OP_bary)	
end

# ╔═╡ 9eea961b-0279-4321-a83f-1e3d0930910b
#calculate mu for each patch
begin
	function calc_mu(xyz::Vector, O⃗::Vector)
	    return dot(O⃗, xyz) / (norm(O⃗) * norm(xyz))
	end

	function calc_mu_grid!(A::Matrix, B::Matrix, out::Matrix)
		for i in 1:length(A)
			out[i] = calc_mu(A[i], B[i])
			end
		return
	end	

	mu_grid = Matrix{Float64}(undef,size(SP_bary)...)
	calc_mu_grid!(SP_bary, OP_bary, mu_grid)

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
end

# ╔═╡ 5381da43-b7b1-4b42-8ca8-29c5cc6656eb
# begin
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
# end

# ╔═╡ f91d624f-63f4-4b65-a77d-9c931d9710e4
#velocities

# ╔═╡ 979cf460-8990-40a0-94a8-07e509f6a19b
#determine velocity scalar for each patch 
begin
	# rotation period (VELOCITY SCALAR NOT VELOCITY) of patch of star at latitude
	# A, B, C are differential rotation coefficients (units are degrees/day)
	function rotation_period(ϕ::T; A::T=14.713, B::T=-2.396, C::T=-1.787) where T
	    @assert -π/2 <= ϕ <= π/2
	    sinϕ = sin(ϕ)
	    return 360.0/(A + B * sinϕ^2.0 + C * sinϕ^4.0)
	end

	#grid of lats in radians
	function lat_grid_fc(num_lats::Int=100, num_lon::Int=100)
	    ϕ = deg2rad.(range(-90.0, 90.0, length=num_lats))
	    A = [ϕ for idx in 1:num_lon]
	    return hcat(A...)
	end
	lat_grid = lat_grid_fc(size(SP_bary)...)

	#get velocity scalar for each patch
	function v_scalar!(A:: Matrix, out:: Matrix)
		for i in 1:length(A)
			per = rotation_period(A[i])
			out[i] = (2*π*sun_radius*cos(A[i]))/per
		end
		return
	end
	v_scalar_grid = Matrix{Float64}(undef,size(SP_bary)...)
	v_scalar!(lat_grid, v_scalar_grid)

	# CHANGE: convert v_scalar to from km/day m/s
	v_scalar_grid ./= 86.4
end

# ╔═╡ 02c005f4-c1ed-4a92-88e8-493c52454a77
#determine velocity vector + projected velocity for each patch 
begin
	#set rotation axis pole vector 
	# CHANGE: pole vector should have sun radius at z
	pole_solar = [0.0,0.0,sun_radius]

	#determine pole vector for each patch
	# CHANGE: subtract off z component
	function pole_vector_grid!(A::Matrix, b::Vector, out::Matrix)
		for i in 1:length(A)
			out[i] = b - [0.0, 0.0, A[i][3]]
		end
		return
	end
	pole_vector_grid = deepcopy(SP_bary) #P subscript y in notes 
	pole_vector_grid!(SP_sun, pole_solar, pole_vector_grid)

	#get velocity vector direction and set magnitude
	function v_vector!(A::Matrix, B::Matrix, C::Matrix, out::Matrix)
		for i in 1:length(A)
			vel = cross(A[i],B[i])
			vel_norm = norm(vel)
			unit = vel / vel_norm
			velocity = unit.*C[i]
			out[i] = [A[i];velocity]
		end
		return
	end
	velocity_vector_solar = deepcopy(pole_vector_grid)
	v_vector!(SP_sun, pole_vector_grid, v_scalar_grid, velocity_vector_solar)

	#transform into ICRF frame 
	velocity_vector_ICRF = deepcopy(velocity_vector_solar)
	frame_transfer!(sxform("IAU_SUN", "J2000", epoch), velocity_vector_ICRF) #NaN created here

	#get projected velocity for each patch
	function projected!(A::Matrix, B:: Matrix, out::Matrix)
		for i in 1:length(A)
			vel = [A[i][4],A[i][5],A[i][6]]
			angle = dot(B[i], vel) / (norm(B[i]) * norm(vel))
    		out[i] = norm(vel) * angle
		end
		return 
	end
	projected_velocities = Matrix{Float64}(undef,size(SP_bary)...)
	projected!(velocity_vector_ICRF, OP_bary, projected_velocities)

	# # CHANGE: PLOTTING
	# cnorm = mpl.colors.Normalize(minimum(projected_velocities), maximum(projected_velocities))
	# colors = mpl.cm.seismic(cnorm(projected_velocities))

	# pcm = plt.pcolormesh(dx, dy, projected_velocities, cmap="seismic",)
	# #plt.xlabel(L"\Delta x\ {\rm (arcmin)}")
	# #plt.ylabel(L"\Delta y\ {\rm (arcmin)}")
	# cb = plt.colorbar(pcm, norm=cnorm, ax=plt.gca())
	# cb.set_label("projected velocity (m/s)")
	# plt.show()
end

# ╔═╡ 84ed7b3c-6a44-4d65-b9cb-2552604dcfde
begin
	x = getindex.(BP_bary,1)
	y = getindex.(BP_bary,2)
	z = getindex.(BP_bary,3)
	fig = plt.figure()
	ax = fig.add_subplot(projection="3d")
	ax.scatter(x,y,z)
	ax.scatter(BO_bary..., label = "earth")
	ax.scatter(moon_pv[1:3]...)
	ax.set_xlabel("x")
	ax.set_ylabel("y")
	ax.set_zlabel("z")
	plt.legend()
	plt.show()
end

# ╔═╡ 530f1e2e-aef7-4105-9e23-0a260a004654
begin
	# calculate the distance between subtile center and planet
	function calc_proj_dist2(p1, p2)
	    x1 = p1[1]
	    x2 = p2[1]
	    y1 = p1[2]
	    y2 = p2[2]
	    return (x1 - x2)^2.0 + (y1-y2)^2.0
	end
	distance = map(x -> calc_proj_dist2(x, moon_pv[1:3]), BP_bary)

	# Quadratic limb darkening law.
	# Takes μ = cos(heliocentric angle) and LD parameters, u1 and u2.
	# u1=0.4, u2=0.26
	function quad_limb_darkening(μ::T, u1::T, u2::T) where T
	    μ < zero(T) && return 0.0
	    return !iszero(μ) * (one(T) - u1*(one(T)-μ) - u2*(one(T)-μ)^2)
	end
	LD_all = quad_limb_darkening.(mu_grid, 0.4, 0.26)
	# get indices for visible patches
	idx1 = mu_grid .> 0.0
	idx2 = distance .> moon_radius^2.0
	idx3 = idx1 .& idx2
	
	# if no patches are visible, set mu, LD, projected velocity to zero 
	for i in 1:length(idx3)
		if idx3[i] == false
			mu_grid[i] = 0.0
			LD_all[i] = 0.0
			projected_velocities[i] = 0.0
		end
	end	 
end

# ╔═╡ 25da158a-0d58-44e4-ae7c-032845c06059
#determine mean weighted velocity 
begin

	#determine proper motion 
	#velocity of earth / sun center from barycenter 
	observer_proper_velocity = earth_pv[4:6]
	patch_proper_velocity = sun_pv[4:6]
	#projecting above velocites to each line of sight from observer to each patch
	function projected2!(A::Vector, B:: Vector, C:: Matrix, out::Matrix)	
		for i in 1:length(C)
			earth_angle = dot(C[i], A) / (norm(C[i]) * norm(A))
			earth_projected =  norm(A) * earth_angle

			patch_angle = dot(C[i], B) / (norm(C[i]) * norm(B))
			patch_projected =  norm(B) * patch_angle
				
    		out[i] = earth_projected + patch_projected
		end
		return 
	end
	proper_velocities = Matrix{Float64}(undef,size(projected_velocities)...)
	projected2!(observer_proper_velocity, patch_proper_velocity, OP_bary,proper_velocities)
	
	#LD weighted velocity included rotational and 'proper' motion
	v_LD = LD_all .* (projected_velocities .+ proper_velocities)  
	mean_weight_v = NaNMath.sum(v_LD) / NaNMath.sum(LD_all)
end 

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
Downloads = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
LinearAlgebra = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"
NaNMath = "77ba4419-2d1f-58cd-9bb1-8ffee604a2e3"
PyPlot = "d330b81b-6aea-500a-939a-2ce795aea3ee"
SPICE = "5bab7191-041a-5c2e-a744-024b9c3a5062"

[compat]
NaNMath = "~1.0.2"
PyPlot = "~2.11.2"
SPICE = "~0.2.3"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.9.3"
manifest_format = "2.0"
project_hash = "1c5c0493baeb9579daded542a75c5fc69efdf755"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"
version = "1.1.1"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[deps.CSPICE_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "a51bd1a409e7a95bce12e0620640dc9aaea8a689"
uuid = "07f52509-e9d9-513c-a20d-3b911885bf96"
version = "67.0.0+0"

[[deps.ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "eb7f0f8307f71fac7c606984ea5fb2817275d6e4"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.4"

[[deps.Colors]]
deps = ["ColorTypes", "FixedPointNumbers", "Reexport"]
git-tree-sha1 = "fc08e5930ee9a4e03f84bfb5211cb54e7769758a"
uuid = "5ae59095-9a9b-59fe-a467-6f913c188581"
version = "0.12.10"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "1.0.5+0"

[[deps.Conda]]
deps = ["Downloads", "JSON", "VersionParsing"]
git-tree-sha1 = "8c86e48c0db1564a1d49548d3515ced5d604c408"
uuid = "8f4d0f93-b110-5947-807f-2305c1781a2d"
version = "1.9.1"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.6.0"

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"

[[deps.FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "335bfdceacc84c5cdf16aadc768aa5ddfc5383cc"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.4"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[deps.JLLWrappers]]
deps = ["Artifacts", "Preferences"]
git-tree-sha1 = "7e5d6779a1e09a36db2a7b6cff50942a0a7d0fca"
uuid = "692b3bcd-3c85-4b1f-b108-f13ce0eb3210"
version = "1.5.0"

[[deps.JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "31e996f0a15c7b280ba9f76636b3ff9e2ae58c9a"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.4"

[[deps.LaTeXStrings]]
git-tree-sha1 = "f2355693d6778a178ade15952b7ac47a4ff97996"
uuid = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
version = "1.3.0"

[[deps.LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"
version = "0.6.3"

[[deps.LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"
version = "7.84.0+0"

[[deps.LibGit2]]
deps = ["Base64", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"

[[deps.LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"
version = "1.10.2+0"

[[deps.Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"

[[deps.LinearAlgebra]]
deps = ["Libdl", "OpenBLAS_jll", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[deps.MacroTools]]
deps = ["Markdown", "Random"]
git-tree-sha1 = "9ee1618cbf5240e6d4e0371d6f24065083f60c48"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.11"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"
version = "2.28.2+0"

[[deps.Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"
version = "2022.10.11"

[[deps.NaNMath]]
deps = ["OpenLibm_jll"]
git-tree-sha1 = "0877504529a3e5c3343c6f8b4c0381e57e4387e4"
uuid = "77ba4419-2d1f-58cd-9bb1-8ffee604a2e3"
version = "1.0.2"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"
version = "1.2.0"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.21+4"

[[deps.OpenLibm_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "05823500-19ac-5b8b-9628-191a04bc5112"
version = "0.8.1+0"

[[deps.Parsers]]
deps = ["Dates", "PrecompileTools", "UUIDs"]
git-tree-sha1 = "716e24b21538abc91f6205fd1d8363f39b442851"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.7.2"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "FileWatching", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
version = "1.9.2"

[[deps.PrecompileTools]]
deps = ["Preferences"]
git-tree-sha1 = "03b4c25b43cb84cee5c90aa9b5ea0a78fd848d2f"
uuid = "aea7be01-6a6a-4083-8856-8a6e6704d82a"
version = "1.2.0"

[[deps.Preferences]]
deps = ["TOML"]
git-tree-sha1 = "7eb1686b4f04b82f96ed7a4ea5890a4f0c7a09f1"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.4.0"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[deps.PyCall]]
deps = ["Conda", "Dates", "Libdl", "LinearAlgebra", "MacroTools", "Serialization", "VersionParsing"]
git-tree-sha1 = "43d304ac6f0354755f1d60730ece8c499980f7ba"
uuid = "438e738f-606a-5dbb-bf0a-cddfbfd45ab0"
version = "1.96.1"

[[deps.PyPlot]]
deps = ["Colors", "LaTeXStrings", "PyCall", "Sockets", "Test", "VersionParsing"]
git-tree-sha1 = "9220a9dae0369f431168d60adab635f88aca7857"
uuid = "d330b81b-6aea-500a-939a-2ce795aea3ee"
version = "2.11.2"

[[deps.REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[deps.Random]]
deps = ["SHA", "Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[deps.Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[deps.SPICE]]
deps = ["CSPICE_jll", "LinearAlgebra"]
git-tree-sha1 = "505455711ac4c9d6b190e433bac95e48c0a38329"
uuid = "5bab7191-041a-5c2e-a744-024b9c3a5062"
version = "0.2.3"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[deps.Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[deps.SparseArrays]]
deps = ["Libdl", "LinearAlgebra", "Random", "Serialization", "SuiteSparse_jll"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[deps.Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"
version = "1.9.0"

[[deps.SuiteSparse_jll]]
deps = ["Artifacts", "Libdl", "Pkg", "libblastrampoline_jll"]
uuid = "bea87d4a-7f5b-5778-9afe-8cc45184846c"
version = "5.10.1+6"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"
version = "1.0.3"

[[deps.Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"
version = "1.10.0"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[deps.VersionParsing]]
git-tree-sha1 = "58d6e80b4ee071f5efd07fda82cb9fbe17200868"
uuid = "81def892-9a0e-5fdd-b105-ffc91e053289"
version = "1.3.0"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"
version = "1.2.13+0"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"
version = "5.8.0+0"

[[deps.nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"
version = "1.48.0+0"

[[deps.p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
version = "17.4.0+0"
"""

# ╔═╡ Cell order:
# ╠═24457971-84a6-4f83-ac03-0edbdabd69c2
# ╠═7fe47b72-51c6-11ee-06b8-47ff5aeced1a
# ╠═842ac223-aa38-4fb1-956a-5eca1d6c1a0e
# ╠═f5dfb524-c6f9-4931-92b9-ba9be85cbe57
# ╠═9eea961b-0279-4321-a83f-1e3d0930910b
# ╠═5381da43-b7b1-4b42-8ca8-29c5cc6656eb
# ╠═f91d624f-63f4-4b65-a77d-9c931d9710e4
# ╠═979cf460-8990-40a0-94a8-07e509f6a19b
# ╠═02c005f4-c1ed-4a92-88e8-493c52454a77
# ╠═84ed7b3c-6a44-4d65-b9cb-2552604dcfde
# ╠═530f1e2e-aef7-4105-9e23-0a260a004654
# ╠═25da158a-0d58-44e4-ae7c-032845c06059
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
