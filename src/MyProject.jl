module MyProject

using SPICE
using Downloads: download
using LinearAlgebra
using NaNMath
#using PyPlot; plt = PyPlot; mpl = plt.matplotlib; plt.ioff()

include("get_kernels.jl")
include("time_loop.jl")
include("max_epoch.jl")
include("coordinates.jl")
include("velocity.jl")
include("moon.jl")

#set required body paramters as global variables 
#E,S,M radii (units:km)
earth_radius = bodvrd("EARTH", "RADII")[1]	
sun_radius = bodvrd("SUN","RADII")[1]
moon_radius = bodvrd("MOON", "RADII")[1]
#lat + lon of observatory
obs_lat = 51.545483
obs_long = 9.905548

include("test/runtests.jl")

end #module