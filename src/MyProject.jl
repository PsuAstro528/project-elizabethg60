module MyProject

using SPICE
using Downloads: download
using LinearAlgebra
using NaNMath
using Statistics
using JLD2
using Test

include("get_kernels.jl")
include("time_loop.jl")
include("epoch_computations.jl")
include("coordinates.jl")
include("velocity.jl")
include("moon.jl")

#set required body paramters as global variables 
#E,S,M radii (units:km)
earth_radius = bodvrd("EARTH", "RADII")[1]	
sun_radius = bodvrd("SUN","RADII")[1]
moon_radius = bodvrd("MOON", "RADII")[1] 

include("test/runtests.jl")

end #module