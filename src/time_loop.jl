#calculate rv / mean intensity at each timestamps for a given grid size 
function gottingen_loop(lats::T, lons::T) where T
    #array of timestamps 
    initial_epoch = utc2et("2015-03-20T07:05:00") 
    final_epoch =  utc2et("2015-03-20T12:05:00") 
    cadence = 159
    time_stamps = range(initial_epoch, final_epoch, cadence)

    obs_lat = 51.54548 
    obs_long = 9.905548
    alt = 0.15

    RV_list = Vector{Float64}(undef,size(time_stamps)...)
    intensity_list = Vector{Float64}(undef,size(time_stamps)...)
    for i in 1:length(time_stamps)
        rv, intensity = compute_rv(lats, lons, time_stamps[i], i, obs_long, obs_lat, alt)
        RV_list[i] = rv
        intensity_list[i] = intensity
    end

    @save "src/plots/rv_intensity.jld2"
    jldopen("src/plots/rv_intensity.jld2", "a+") do file
        file["RV_list"] = RV_list 
        file["intensity_list"] = intensity_list
        file["timestamps"] = et2utc.(time_stamps, "ISOC", 0)
    end
end

function kitt_loop(lats::T, lons::T) where T
    #array of timestamps 
    initial_epoch = utc2et("2023-10-14T15:00:00")  
    final_epoch =  utc2et("2023-10-14T18:10:00")  
    cadence = 159
    time_stamps = range(initial_epoch, final_epoch, cadence)

    obs_lat = 31.9583 
    obs_long = 360-111.5967  
    alt = 2.097938

    RV_list = Vector{Float64}(undef,size(time_stamps)...)
    intensity_list = Vector{Float64}(undef,size(time_stamps)...)
    for i in 1:length(time_stamps)
        rv, intensity = compute_rv(lats, lons, time_stamps[i], i, obs_long, obs_lat, alt)
        RV_list[i] = rv
        intensity_list[i] = intensity
    end

    @save "src/plots/rv_intensity.jld2"
    jldopen("src/plots/rv_intensity.jld2", "a+") do file
        file["RV_list"] = RV_list 
        file["intensity_list"] = intensity_list
        file["timestamps"] = et2utc.(time_stamps, "ISOC", 0)
    end
end

function low_loop(lats::T, lons::T) where T
    #array of timestamps 
    initial_epoch = utc2et("2023-10-14T15:00:00")  
    final_epoch =  utc2et("2023-10-14T18:10:00")  
    cadence = 159
    time_stamps = range(initial_epoch, final_epoch, cadence)

    obs_lat = 34.744444
    obs_long = 360-111.421944 
    alt = 2.359152

    RV_list = Vector{Float64}(undef,size(time_stamps)...)
    intensity_list = Vector{Float64}(undef,size(time_stamps)...)
    for i in 1:length(time_stamps)
        rv, intensity = compute_rv(lats, lons, time_stamps[i], i, obs_long, obs_lat, alt)
        RV_list[i] = rv
        intensity_list[i] = intensity
    end

    @save "src/plots/rv_intensity.jld2"
    jldopen("src/plots/rv_intensity.jld2", "a+") do file
        file["RV_list"] = RV_list 
        file["intensity_list"] = intensity_list
        file["timestamps"] = et2utc.(time_stamps, "ISOC", 0)
    end
end