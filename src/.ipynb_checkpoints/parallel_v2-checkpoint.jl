function lat_grid_fc_pa2(num_lats, num_lon)
    #creates vector of latitude values reflecting solar grid size 
    ϕ = deg2rad.(range(-90.0, 90.0, length=num_lats))
    return repeat(ϕ,num_lon)
end 

function compute_solar_grid(lats::T, lons::T) where T 
    #determine xyz stellar coordinates for lat/long grid so that individual elements can be passed to compute_rv_pa2
    return get_xyz_for_surface(sun_radius, num_lats = lats, num_lons = lons)
end

function compute_rv_pa2(lats::T, lons::T, epoch, obs_long, obs_lat, alt, SP_sun, lat_index) where T
    """
    compute rv for a given grid size and timestamp - multi-processing
    rewritten to do an individual cell at a time on each available processor 
    
    lats: grid latitude size
    lons: grid longitude size
    epoch: timestamp
    obs_long: observer longtiude
    obs_lat: observer latitude
    alt: observer altitude
    SP_sun: the cell to have rv computed for
    lat_index: cell's corresponding index from original gridding 
    """
#query JPL horizons for E, S, M position (km) and velocities (km/s)
    earth_pv = spkssb(399,epoch,"J2000")[1:3]  
    sun_pv = spkssb(10,epoch,"J2000")[1:3] 
    moon_pv = spkssb(301,epoch,"J2000")[1:3] 


#determine required position vectors
    #transform xyz stellar coordinates of grid from sun frame to ICRF
    SP_bary = pxform("IAU_SUN", "J2000", epoch)*SP_sun

    #determine xyz earth coordinates for lat/long 
    EO_earth = pgrrec("EARTH", deg2rad(obs_long), deg2rad(obs_lat), alt, earth_radius, (earth_radius - earth_radius_pole) / earth_radius)
    #transform xyz earth coordinates of observatory from earth frame to ICRF
    EO_bary = pxform("IAU_EARTH", "J2000", epoch)*EO_earth

    #get vector from barycenter to observatory on Earth's surface
    BO_bary = earth_pv .+ EO_bary
    #get vector from observatory on earth's surface to moon center
    OM_bary = moon_pv .- BO_bary
    #get vector from barycenter to each patch on Sun's surface
    BP_bary = sun_pv .+ SP_bary

    #get vector from observatory on Earth's surface to Sun's center
    SO_bary = sun_pv .- BO_bary 
    #vectors from observatory on Earth's surface to each patch on Sun's surface
    OP_bary = BP_bary .- BO_bary


#calculate mu for each patch
    mu_grid = calc_mu(SP_bary, OP_bary)


#determine velocity vectors
    #determine velocity scalar for each patch 
    lat_grid = lat_grid_fc_pa2(lats, lons)
    v_scalar_grid = (2*π*sun_radius*cos(lat_grid[lat_index]))/(rotation_period(lat_grid[lat_index]))
    #convert v_scalar to from km/day m/s
    v_scalar_grid = v_scalar_grid/86.4

    #determine pole vector for each patch
    pole_vector_grid = SP_sun - [0.0, 0.0, SP_sun[3]]

    #get velocity vector direction and set magnitude
    velocity_vector_solar = [SP_sun;(cross(pole_vector_grid, [0.0,0.0,sun_radius]) / norm(cross(pole_vector_grid, [0.0,0.0,sun_radius]))).*v_scalar_grid]
    
    #transform into ICRF frame 
    velocity_vector_ICRF = sxform("IAU_SUN", "J2000", epoch) * velocity_vector_solar

    #get projected velocity for each patch
    vel = [velocity_vector_ICRF[4],velocity_vector_ICRF[5],velocity_vector_ICRF[6]]
    angle = dot(OP_bary, vel) / (norm(OP_bary) * norm(vel))
    projected_velocities = -(norm(vel) * angle)

    
#determine patches that are blocked by moon 
    #calculate the distance between tile corner and moon
    distance = calc_proj_dist2(OP_bary, OM_bary)

    #calculate limb darkening weight for each patch 
    LD_all = quad_limb_darkening(mu_grid)

    #get indices for visible patches
    idx1 = mu_grid > 0.0
    idx3 = (idx1) & (distance > atan(moon_radius/norm(OM_bary))^2)

    #calculating the area element dA for each tile
    ϕ = range(deg2rad(-90.0), deg2rad(90.0), length=lats)
    θ =range(0.0, deg2rad(360.0), length=lons)   
    dA_sub = calc_dA(sun_radius, lat_grid[lat_index], step(ϕ), step(θ))
    #get total projected, visible area of larger tile
    dp_sub = abs(dot(SP_bary, OP_bary))
    dA_total_proj = dA_sub .* dp_sub

    #if no patches are visible, set mu, LD, projected velocity to zero 
    if idx3 == false
        mu_grid = NaN
        LD_all = 0.0
        projected_velocities = NaN
    end

    return LD_all, projected_velocities, dA_total_proj
end

function parallel_v2()
    """
    for a single timestamp, determine how long multi-processing parallel version of code takes for given problem sizes (grid)
    """
    println("# Now Julia is using ", nworkers(), " workers.")
    num_workers_all = nworkers()

    #NEID location 
    obs_lat = 31.9583 
    obs_long = -111.5967  
    alt = 2.097938
    time_stamps = utc2et("2023-10-14T16:00:45") 

    #problem sizes to be benchmarked for strong scaling
    N_small = 50
    N_mid = 250
    N_large = 500
    sun_grid_small = compute_solar_grid(N_small, N_small*2)
    sun_grid_mid = compute_solar_grid(N_mid, N_mid*2)
    sun_grid_large = compute_solar_grid(N_large, N_large*2)
    
    wall_time = zeros(num_workers_all)
    wall_time_mid = zeros(num_workers_all)
    wall_time_large = zeros(num_workers_all)
    #run compute_rv_pa2 (parallel) for each grid size for strong scaling and weak scaling interating through number of workers
    for nw in num_workers_all:-1:1
        #strong scaling
        wall_time[nw] = @elapsed @distributed (vcat) for idx ∈ 1:length(sun_grid_small)
            compute_rv_pa2(N_small, N_small*2, time_stamps, obs_long, obs_lat, alt, sun_grid_small[idx], idx) 
        end 
        wall_time_mid[nw] = @elapsed @distributed (vcat) for idx ∈ 1:length(sun_grid_mid)
            compute_rv_pa2(N_mid, N_mid*2, time_stamps, obs_long, obs_lat, alt, sun_grid_mid[idx], idx) 
        end 
        wall_time_large[nw] = @elapsed @distributed (vcat) for idx ∈ 1:length(sun_grid_large)
            compute_rv_pa2(N_large, N_large*2, time_stamps, obs_long, obs_lat, alt, sun_grid_large[idx], idx) 
        end 
        if nw > 1
            rmprocs(last(workers()))            # Remove one worker
        end
        println("# Now Julia is using ", nworkers(), " workers.")
    end

    #save recovered time for each corresponding problem size strong / weak across number of workers
    jldopen("src/test/strong_scaling_v2.jld2", "a+") do file
        file["num_workers_all"] = num_workers_all 
        file["wall_time"] = wall_time
        file["wall_time_mid"] = wall_time_mid
        file["wall_time_large"] = wall_time_large
    end
end