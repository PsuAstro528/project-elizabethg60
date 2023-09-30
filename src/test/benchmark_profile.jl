#file benchmarking and profiling code for grid size 100x100
using BenchmarkTools, Profile, MyProject

print("benchmarks: \n")
print("at max epoch: MyProject.max_epoch_v: ")
print(@benchmark MyProject.max_epoch_v(100,100))
print("\n")
print("for all timestamps: MyProject.time_loop: ")
print(@benchmark MyProject.loop(100,100))
print("\n")
#individual functions to potentially be optimized 
print("Individal Functions For Potential Optimization: \n")
print("MyProject.get_xyz_for_surface: ")
print(@benchmark MyProject.get_xyz_for_surface(696000.0))
print("\n")
matrix_bench = MyProject.get_xyz_for_surface(696000.0)
print("MyProject.lat_grid_fc: ")
print(@benchmark MyProject.lat_grid_fc())
print("\n")
print("MyProject.v_scalar: ")
grid_bench = MyProject.lat_grid_fc()
print(@benchmark MyProject.v_scalar!(grid_bench, Matrix{Float64}(undef,size(matrix_bench)...)))
print("\n")

#profile 
print("Max Epoch Profile: ")
@profile MyProject.max_epoch_v(100,100)
Profile.print()
print("\n")
print("\n")
@profile MyProject.loop(100,100)
Profile.print()