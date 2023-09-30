module MyProject

using SPICE
using Downloads: download
using LinearAlgebra
using NaNMath
#import PyPlot; plt = PyPlot; mpl = plt.matplotlib; plt.ioff()

include("get_kernels.jl")
include("time_loop.jl")
include("coordinates.jl")
include("velocity.jl")
include("moon.jl")

#set required body paramters as constant global variables 
#E,S,M radii (units:km)
earth_radius = bodvrd("EARTH", "RADII")[1]	
sun_radius = bodvrd("SUN","RADII")[1]
moon_radius = bodvrd("MOON", "RADII")[1]
#lat + lon of observatory
obs_lat = 51.4769
obs_long = -0.0005

end #module