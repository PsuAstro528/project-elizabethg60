#calculating mean weighted velocity at at max epoch given a grid size (to be parallelized)
function max_epoch_v(lats::T, lons::T; moon_r::Float64=moon_radius) where T
    epoch = utc2et("2015-03-20T09:42:00") 

    #query JPL horizons for E, S, M position (km) and velocities (km/s)
    earth_pv = spkssb(399,epoch,"J2000") 
    sun_pv = spkssb(10,epoch,"J2000")
    moon_pv = spkssb(301,epoch,"J2000")


    #determine required position vectors (following functions are found in coordinates.jl)
    #determine xyz stellar coordinates for lat/long grid
    SP_sun = get_xyz_for_surface(sun_radius, num_lats = lats, num_lons = lons)
     #transform xyz stellar coordinates of grid from sun frame to ICRF
    SP_bary = deepcopy(SP_sun)
    frame_transfer!(pxform("IAU_SUN", "J2000", epoch), SP_bary)

    #determine vectors from Earth observatory surface to each patch
    #determine xyz earth coordinates for lat/long of royal observatory
    EO_earth = get_xyz(earth_radius, obs_lat, obs_long)
    #transform xyz earth coordinates of observatory from earth frame to ICRF
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
    OP_bary = deepcopy(SP_bary)
    earth2patch_vectors!(SP_bary, SO_bary, OP_bary)	


    #calculate mu for each patch
    mu_grid = Matrix{Float64}(undef,size(SP_bary)...)
    calc_mu_grid!(SP_bary, OP_bary, mu_grid)
		
    # #mu_grid figure check  
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
	# cb = plt.colorbar(norm=cnorm, ax=plt.gca())
	# plt.show()


    #determine velocity vectors (following functions are found in velocity.jl)
    #determine velocity scalar for each patch 
    lat_grid = lat_grid_fc(size(SP_bary)...)
    v_scalar_grid = Matrix{Float64}(undef,size(SP_bary)...)
    v_scalar!(lat_grid, v_scalar_grid)
    #convert v_scalar to from km/day m/s
    v_scalar_grid ./= 86.4

    #determine velocity vector + projected velocity for each patch 
    #set rotation axis pole vector 
    pole_solar = [0.0,0.0,sun_radius]
    #determine pole vector for each patch
    pole_vector_grid = deepcopy(SP_bary)
    pole_vector_grid!(SP_sun, pole_solar, pole_vector_grid)

    #get velocity vector direction and set magnitude
    velocity_vector_solar = deepcopy(pole_vector_grid)
    v_vector!(SP_sun, pole_vector_grid, v_scalar_grid, velocity_vector_solar)

    #transform into ICRF frame 
    velocity_vector_ICRF = deepcopy(velocity_vector_solar)
    frame_transfer!(sxform("IAU_SUN", "J2000", epoch), velocity_vector_ICRF)

    #get projected velocity for each patch
    projected_velocities = Matrix{Float64}(undef,size(SP_bary)...)
    projected!(velocity_vector_ICRF, OP_bary, projected_velocities)

	#projected velocity grid check
	# cnorm = mpl.colors.Normalize(minimum(projected_velocities), maximum(projected_velocities))
	# colors = mpl.cm.seismic(cnorm(projected_velocities))
	# pcm = plt.pcolormesh(dx, dy, projected_velocities, cmap="seismic",)
	# cb = plt.colorbar(pcm, norm=cnorm, ax=plt.gca())
	# cb.set_label("projected velocity (m/s)")
	# plt.show()


    #determine patches that are blocked by moon (following functions in moon.jl) 
    #calculate the distance between tile corner and moon
    distance = map(x -> calc_proj_dist2(x, moon_pv[1:3]), BP_bary)

    #calculate limb darkening weight for each patch 
    LD_all = quad_limb_darkening.(mu_grid, 0.4, 0.26)

    #get indices for visible patches
    idx1 = mu_grid .> 0.0
    idx2 = distance .> moon_r^2.0
    idx3 = idx1 .& idx2

    #if no patches are visible, set mu, LD, projected velocity to zero 
    for i in 1:length(idx3)
        if idx3[i] == false
            mu_grid[i] = 0.0
            LD_all[i] = 0.0
            projected_velocities[i] = 0.0
        end
    end


    #determine mean weighted velocity from sun given blocking from moon 
    #determine proper motion velocity from earth and sun patches 
    observer_proper_velocity = earth_pv[4:6]
    patch_proper_velocity = sun_pv[4:6]
    #projecting above velocites to each line of sight from observer to each patch
    proper_velocities = Matrix{Float64}(undef,size(projected_velocities)...)
    projected2!(observer_proper_velocity, patch_proper_velocity, OP_bary,proper_velocities)

    #determine LD weighted velocity included rotational and proper motion velocities 
    v_LD = LD_all .* (projected_velocities .+ proper_velocities)  
    mean_weight_v = NaNMath.sum(v_LD) / NaNMath.sum(LD_all)
    return mean_weight_v
end