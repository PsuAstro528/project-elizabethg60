#calculate rv / mean intensity at each timestamps for a given grid size 
function loop(lats::T, lons::T) where T

    #compute_rv(lats, lons, utc2et("2023-10-14T15:34:01"), 0)

    #array of timestamps 
    initial_epoch = utc2et("2023-10-14T15:00:00") #"2023-10-14T15:00:00" 2015-03-20T07:05:00
    final_epoch =  utc2et("2023-10-14T18:10:00") #"2023-10-14T18:10:00" 2015-03-20T12:05:00
    cadence = 159
    time_stamps = range(initial_epoch, final_epoch, cadence)

    RV_list = Vector{Float64}(undef,size(time_stamps)...)
    intensity_list = Vector{Float64}(undef,size(time_stamps)...)
    for i in 1:length(time_stamps)
        rv, intensity = compute_rv(lats, lons, time_stamps[i], i)
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