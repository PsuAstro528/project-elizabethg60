module SET_UP

using SPICE
using Downloads: download
using LinearAlgebra
using NaNMath
import PyPlot; plt = PyPlot; mpl = plt.matplotlib; plt.ioff()

include("get_kernels.jl")
include("time_loop.jl")

end #module