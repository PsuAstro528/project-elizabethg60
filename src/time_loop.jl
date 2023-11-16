function neid_loop(lats::T, lons::T) where T
    """
    computes RV for each timestamp for the NEID eclipse - serial

    lats: number of latitude grid cells
    lons: number of longitude grid cells
    """

    #convert from utc to et as needed by SPICE
    time_stamps = utc2et.(neid_timestamps)

    #NEID location 
    obs_lat = 31.9583 
    obs_long = -111.5967  
    alt = 2.097938

    RV_list = Vector{Float64}(undef,size(time_stamps)...)
    #run compute_rv (serial) for each timestamp
    for i in 1:length(time_stamps)
        RV_list[i] = compute_rv(lats, lons, time_stamps[i], i, obs_long, obs_lat, alt, obs = "NEID")[1]
    end

    #save recovered RV for each corresponding timestamp
    @save "src/plots/NEID/rv_intensity.jld2"
    jldopen("src/plots/NEID/rv_intensity.jld2", "a+") do file
        file["RV_list"] = RV_list 
        file["timestamps"] = et2utc.(time_stamps, "ISOC", 0)
    end
end


#dont need to run neid_loop again, just parallel_loop and serial_loop
function parallel_loop()
    """
    for a single timestamp, determine how long parallel version of code takes for a range of problem size (grid)
    """

    #NEID location 
    obs_lat = 31.9583 
    obs_long = -111.5967  
    alt = 2.097938

    #problem sizes to be benchmarked
    initial_N = 200
    final_N = 375
    N_steps = range(initial_N, final_N, step = 2)
    N_steps = Int.(N_steps)

    time_vector = Vector{Float64}(undef,size(N_steps)...) 
    #run compute_rv_pa (parallel) for each grid size 
    for i in 1:length(N_steps)
        time_vector[i] = compute_rv_pa(N_steps[i], N_steps[i]*2, utc2et("2023-10-14T16:00:45"), obs_long, obs_lat, alt)[2]                       
    end
        
    #save recovered time for each corresponding problem size
    @save "src/test/grid_parallel.jld2"
    jldopen("src/test/grid_parallel.jld2", "a+") do file
        file["N_steps"] = N_steps 
        file["time_vector"] = time_vector
    end
end
    
function serial_loop()
    """
    for a single timestamp, determine how long serial version of code takes for a range of problem size (grid)
    """

    #NEID location 
    obs_lat = 31.9583 
    obs_long = -111.5967  
    alt = 2.097938

    #problem sizes to be benchmarked
    initial_N = 200
    final_N = 375
    N_steps = range(initial_N, final_N, step = 2)
    N_steps = Int.(N_steps)

    time_vector = Vector{Float64}(undef,size(N_steps)...)
    #run compute_rv (serial) for each grid size 
    for i in 1:length(N_steps)
        time_vector[i] = compute_rv(N_steps[i], N_steps[i]*2, utc2et("2023-10-14T16:00:45"), 0, obs_long, obs_lat, alt)[2]
    end
        
    #save recovered time for each corresponding problem size
    @save "src/test/grid_serial.jld2"
    jldopen("src/test/grid_serial.jld2", "a+") do file
        file["N_steps"] = N_steps 
        file["time_vector"] = time_vector
    end
end
