import h5py
import matplotlib.pyplot as plt

serial = h5py.File("grid_serial.jld2", "r")
serial_N = serial["N_steps"][()]
serial_time = serial["time_vector"][()]

pa = h5py.File("grid_parallel.jld2", "r")
pa_N = pa["N_steps"][()]
pa_time = pa["time_vector"][()]
  
plt.scatter(serial_N, serial_time, label = "Serial Code")
plt.scatter(pa_N, pa_time, label = "Parallel Code")
plt.xlabel("Grid Size - N")
plt.ylabel("Time (seconds)")
plt.legend()
plt.savefig("gridvstime.png")
plt.show()