module MyProject 

using SPICE
using Downloads: download
using LinearAlgebra
using NaNMath
using Statistics
using JLD2
using Test
using ThreadsX

include("get_kernels.jl")
include("epoch_computations.jl")
include("epoch_computations_pa.jl")
include("coordinates.jl")
include("coordinates_pa.jl")
include("velocity.jl")
include("velocity_pa.jl")
include("moon.jl")
include("time_loop.jl")

#set required body paramters as global variables 
#E,S,M radii (units:km)
earth_radius = bodvrd("EARTH", "RADII")[1]	
sun_radius = bodvrd("SUN","RADII")[1]
earth_radius_pole = bodvrd("EARTH", "RADII")[3]	
moon_radius = bodvrd("MOON", "RADII")[1] 

#include("test/runtests.jl")

end #module