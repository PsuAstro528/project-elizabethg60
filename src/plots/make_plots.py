import h5py
from datetime import datetime
import matplotlib.pyplot as plt
import numpy as np
import matplotlib.dates as mdates
mpl = plt.matplotlib

f = h5py.File("max_epoch.jld2", "r")

projected_velocities = f["projected_velocities"][()]
ra = f["ra"][()]
dec = f["dec"][()]
ra_moon = f["ra_moon"][()]
dec_moon = f["dec_moon"][()]
date_strings = "2015-03-20 09:42:00"

dt = datetime.strptime(date_strings, "%Y-%m-%d %H:%M:%S")
print(type(dt))

cnorm = mpl.colors.Normalize(np.min(projected_velocities), np.max(projected_velocities))
colors = mpl.cm.seismic(cnorm(projected_velocities))
pcm = plt.pcolormesh(ra, dec, projected_velocities, cmap="seismic",vmin=-2000, vmax=2000)
plt.scatter(ra_moon, dec_moon)
cb = plt.colorbar(pcm, norm=cnorm, ax=plt.gca())
plt.gca().invert_xaxis()
cb.set_label("projected velocity (m/s)")
#plt.gca().set_aspect("equal")
plt.title(dt)
plt.legend()
plt.show()

# f = h5py.File("rv_intensity.jld2", "r")
# RV_list = f["RV_list"][()]
# intensity_list = f["intensity_list"][()]
# date_strings = f["timestamps"][()]

# time_stamps = []
# for i in date_strings:
#     time_stamps.append(datetime.strptime(i, "%Y-%m-%dT%H:%M:%S"))

# fig = plt.figure()
# ax1 = fig.add_subplot()
# ax1.scatter(time_stamps, RV_list) #intensity_list 
# ax1.xaxis.set_major_formatter(mdates.DateFormatter("%H:%M:%S"))
# ax1.set_xlabel("Time (UTC)")
# ax1.set_ylabel("RV [m/s]") #Relative Intensity
# plt.show()

# fig = plt.figure()
# ax1 = fig.add_subplot()
# ax1.scatter(time_stamps, intensity_list)  
# ax1.xaxis.set_major_formatter(mdates.DateFormatter("%H:%M:%S"))
# ax1.set_xlabel("Time (UTC)")
# ax1.set_ylabel("Relative Intensity") 
# plt.show()