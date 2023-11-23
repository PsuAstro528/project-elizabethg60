import h5py
import matplotlib.pyplot as plt

"""
plot summary benchmarks between serial, parallel v1, and parallel v2
"""

#compare serial to parallel v1 (multi-threading) 
#read in data
serial_intro = h5py.File("serial_upto500.jld2", "r")
serial_N_intro = serial_intro["N_steps"][()]
serial_time_intro = serial_intro["time_vector"][()]
parallel_intro = h5py.File("parallel_upto500.jld2", "r")
parallel_N_intro = parallel_intro["N_steps"][()]
parallel_time_intro = parallel_intro["time_vector"][()]
serial_mid = h5py.File("serial_middle.jld2", "r")
serial_N_mid = serial_mid["N_steps"][()]
serial_time_mid = serial_mid["time_vector"][()]
parallel_mid = h5py.File("parallel_middle.jld2", "r")
parallel_N_mid = parallel_mid["N_steps"][()]
parallel_time_mid = parallel_mid["time_vector"][()]
serial_end = h5py.File("serial_beyond1000.jld2", "r")
serial_N_end = serial_end["N_steps"][()]
serial_time_end = serial_end["time_vector"][()]
parallel_end = h5py.File("parallel_beyond1000.jld2", "r")
parallel_N_end = parallel_end["N_steps"][()]
parallel_time_end = parallel_end["time_vector"][()]
parallel_midX = h5py.File("parallel_middleX.jld2", "r")
parallel_N_midX = parallel_midX["N_steps"][()]
parallel_time_midX = parallel_midX["time_vector"][()]
parallel_mid5 = h5py.File("parallel_middle_5cpus.jld2", "r")
parallel_N_mid5 = parallel_mid5["N_steps"][()]
parallel_time_mid5 = parallel_mid5["time_vector"][()]
parallel_mid3 = h5py.File("parallel_middle_3cpus.jld2", "r")
parallel_N_mid3 = parallel_mid3["N_steps"][()]
parallel_time_mid3 = parallel_mid3["time_vector"][()]

#figures for presentation
#figure one - comparing small problem sizes between serial and parallel v1
plt.scatter(serial_N_intro, serial_time_intro, color = "r", label = "Serial")
plt.scatter(parallel_N_intro, parallel_time_intro, color = "b", label = "Parallel")
plt.xlabel("Problem Size (# of latitude cells)")
plt.ylabel("Time (seconds)")
plt.legend()
plt.yscale("log")
plt.savefig("figure_one.png")
plt.show()
plt.clf()
#figure two - comparing all problem sizes between serial and parallel v1
plt.scatter(serial_N_intro, serial_time_intro, color = "r", label = "Serial")
plt.scatter(parallel_N_intro, parallel_time_intro, color = "b", label = "Parallel")
plt.scatter(serial_N_mid, serial_time_mid, color = "r")
plt.scatter(parallel_N_mid, parallel_time_mid, color = "b")
plt.scatter(serial_N_end, serial_time_end, color = "r")
plt.scatter(parallel_N_end, parallel_time_end, color = "b")
plt.xlabel("Problem Size (# of latitude cells)")
plt.ylabel("Time (seconds)")
plt.legend()
plt.yscale("log")
plt.savefig("figure_two.png")
plt.show()
plt.clf()
#figure three - comparing mid problem sizes between serial and parallel v1
plt.scatter(serial_N_mid, serial_time_mid, color = "r", label = "Serial")
plt.scatter(parallel_N_mid, parallel_time_mid, color = "b", label = "Parallel")
plt.xlabel("Problem Size (# of latitude cells)")
plt.ylabel("Time (seconds)")
plt.legend()
plt.yscale("log")
plt.savefig("figure_three.png")
plt.show()
plt.clf()
#figure four - comparing mid problem sizes between serial and parallel v1 and mixed version of v1
plt.scatter(serial_N_mid, serial_time_mid, color = "r", label = "Serial")
plt.scatter(parallel_N_mid, parallel_time_mid, color = "b", label = "Parallel")
plt.scatter(parallel_N_midX, parallel_time_midX, color = "g", label = "Parallel - mixed")
plt.xlabel("Problem Size (# of latitude cells)")
plt.ylabel("Time (seconds)")
plt.legend()
plt.yscale("log")
plt.savefig("figure_four.png")
plt.show()
plt.clf()
#figure five - comparing mid problem sizes between serial and parallel v1 using 3,4,5 cpus
plt.scatter(serial_N_mid, serial_time_mid, color = "r", label = "Serial")
plt.scatter(parallel_N_mid, parallel_time_mid, color = "b", label = "Parallel - 4 cpus")
plt.scatter(parallel_N_mid5, parallel_time_mid5, color = "g", label = "Parallel - 5 cpus")
plt.scatter(parallel_N_mid3, parallel_time_mid3, color = "y", label = "Parallel - 3 cpus")
plt.xlabel("Problem Size (# of latitude cells)")
plt.ylabel("Time (seconds)")
plt.legend()
plt.yscale("log")
plt.savefig("figure_five.png")
plt.show()
plt.clf()

#strong scaling benchmark for parallel v2 (multi-processing) 
#read in data
parallel_v2 = h5py.File("strong_scaling_v2.jld2", "r")
num_workers_all = parallel_v2["num_workers_all"][()] 
wall_time = parallel_v2["wall_time"][()] 
wall_time_mid = parallel_v2["wall_time_mid"][()] 
wall_time_large = parallel_v2["wall_time_large"][()] 

#figure six - strong scaling from parallel v2 for 3 sets of problem sizes
plt.scatter(range(1,num_workers_all+1), wall_time, label = "50x100")
plt.scatter(range(1,num_workers_all+1), wall_time_mid, label = "250x500")
plt.scatter(range(1,num_workers_all+1), wall_time_large, label = "500x1000")
plt.xlabel("Number of Workers")
plt.ylabel("Time (seconds)")
plt.legend()
plt.yscale("log")
plt.savefig("figure_six.png")
plt.show()