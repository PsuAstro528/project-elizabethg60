using Pkg
Pkg.activate(".")
using GRASS
disk = DiskParams(N=25, Nt = 3, Nsubgrid = 3)
