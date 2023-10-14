import h5py
import numpy as np
from datetime import datetime
import matplotlib.pyplot as plt
import matplotlib.dates as mdates
mpl = plt.matplotlib

for i in range(1,156):
    f = h5py.File("data/timestamp_{}.jld2".format(i), "r")
    projected_velocities = f["projected_velocities"][()]
    ra = f["ra"][()]
    dec = f["dec"][()]
    ra_moon = f["ra_moon"][()]
    dec_moon = f["dec_moon"][()]
    mu_grid = f["mu_grid"][()]
    LD_all = f["LD_all"][()]
    date_strings = f["timestamp"][()]

    #projected velocity rotation 
    cnorm = mpl.colors.Normalize(np.min(projected_velocities), np.max(projected_velocities))
    colors = mpl.cm.seismic(cnorm(projected_velocities))
    pcm = plt.pcolormesh(ra, dec, projected_velocities, cmap="seismic",vmin=-2000, vmax=2000)
    #plt.scatter(ra_moon, dec_moon)
    cb = plt.colorbar(pcm, norm=cnorm, ax=plt.gca())
    plt.gca().invert_xaxis()
    cb.set_label("projected velocity (m/s)")
    #plt.gca().set_aspect("equal")
    plt.title(date_strings)
    plt.savefig("movie/projected_vel_{}.png".format(i))
    plt.clf()

#     # #code for projected mu_grid / intensity sphere 
#     # cnorm = mpl.colors.Normalize(np.min(mu_grid), np.max(mu_grid))
#     # colors = mpl.cm.viridis(cnorm(mu_grid))
#     # pcm = plt.pcolormesh(ra, dec, mu_grid, vmin=-1, vmax=1)
#     # cb = plt.colorbar(norm=cnorm, ax=plt.gca())
#     # cb.set_label("mu")
#     # plt.gca().invert_xaxis()
#     # plt.show()

f = h5py.File("rv_intensity.jld2", "r")
RV_list = f["RV_list"][()]
intensity_list = f["intensity_list"][()]
date_strings = f["timestamps"][()]

time_stamps = []
for i in date_strings:
    time_stamps.append(datetime.strptime(i, "%Y-%m-%dT%H:%M:%S"))

fig = plt.figure()
ax1 = fig.add_subplot()
ax1.scatter(time_stamps, RV_list)  
ax1.xaxis.set_major_formatter(mdates.DateFormatter("%H:%M:%S"))
ax1.set_xlabel("Time (UTC)")
ax1.set_ylabel("RV [m/s]")
plt.show()

fig = plt.figure()
ax1 = fig.add_subplot()
ax1.scatter(time_stamps, intensity_list)  
ax1.xaxis.set_major_formatter(mdates.DateFormatter("%H:%M:%S"))
ax1.set_xlabel("Time (UTC)")
ax1.set_ylabel("Relative Intensity") 
plt.show()