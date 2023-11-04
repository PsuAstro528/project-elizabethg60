import h5py
import numpy as np
import pandas as pd
from datetime import datetime
import matplotlib.pyplot as plt
import matplotlib.dates as mdates
mpl = plt.matplotlib 

# #projected solar velocities at each timestamp for eclipse movie
# for i in range(1,160):
#     f = h5py.File("data/timestamp_{}.jld2".format(i), "r")
#     projected_velocities = f["projected_velocities"][()]
#     ra = f["ra"][()]
#     dec = f["dec"][()]
#     ra_moon = f["ra_moon"][()]
#     dec_moon = f["dec_moon"][()]
#     mu_grid = f["mu_grid"][()]
#     LD_all = f["LD_all"][()]
#     date_strings = f["timestamp"][()]

#     #projected velocity rotation 
#     cnorm = mpl.colors.Normalize(np.min(projected_velocities), np.max(projected_velocities))
#     colors = mpl.cm.seismic(cnorm(projected_velocities))
#     pcm = plt.pcolormesh(ra, dec, projected_velocities, cmap="seismic",vmin=-2000, vmax=2000)
#     cb = plt.colorbar(pcm, norm=cnorm, ax=plt.gca())
#     plt.gca().invert_xaxis()
#     cb.set_label("projected velocity (m/s)")
#     #plt.title(date_strings)
#     plt.xlabel("RA")
#     plt.ylabel("dec")
#     plt.savefig("movie/projected_vel_{}.png".format(i))
#     plt.clf()

#plotting rm curve and corresponding intensity over time 
f = h5py.File("rv_intensity.jld2", "r")
RV_list = f["RV_list"][()]
intensity_list = f["intensity_list"][()]
date_strings = f["timestamps"][()]
fig = plt.figure()
ax1 = fig.add_subplot()

# #gottingen 2015
# f=open("got_2015.txt","r")
# lines=f.readlines()[1:]
# time=[]
# rv=[]
# for x in lines:
#     time.append(datetime.strptime("2015-03-20 {}".format((x.split()[1])), "%Y-%m-%d %H:%M:%S.%f"))
#     rv.append(float(x.split()[4])-200)
# f.close()
# fig = plt.figure()
# ax1 = fig.add_subplot()
# ax1.scatter(time, rv, label = "Rieners RVs") 

#for NEID
data = pd.read_csv("NEID_10_14_data.csv")
time_stamps = []
for i in data["obsdate"]:
    time_stamps.append(datetime.strptime(i, "%Y-%m-%d %H:%M:%S"))
fig = plt.figure()
ax1 = fig.add_subplot()
ax1.scatter(time_stamps[15:-150], data["ccfrvmod"][15:-150]*1000+630, label = "NEID RVs") 

# #for EXPRES
# data = pd.read_csv("expres_10_14_data.csv")
# time_stamps = []
# for i in data["tobs"]:
#     time_stamps.append(datetime.strptime(i, "%Y-%m-%d %H:%M:%S"))
# fig = plt.figure()
# ax1 = fig.add_subplot()
# ax1.scatter(time_stamps, data["rv"], label = "EXPRESS RVs") 

# #for Boulder
# from datetime import datetime, timedelta
# import numpy as np
# data_time = np.loadtxt("rvs_101423_bin.txt")[:, 0]
# data_rv = np.loadtxt("rvs_101423_bin.txt")[:, 1] * (1.565*10**(-6))
# time_stamps = []
# for i in data_time:
#     time_stamps.append(datetime.fromtimestamp(i) + timedelta(hours=4))
# fig = plt.figure()
# ax1 = fig.add_subplot()
# ax1.scatter(time_stamps[1:-10], data_rv[1:-10], label = "Boulder RVs") 

time_stamps = []
for i in date_strings:
    time_stamps.append(datetime.strptime(i, "%Y-%m-%dT%H:%M:%S"))
ax1.scatter(time_stamps, RV_list, label = "Model")
ax1.xaxis.set_major_formatter(mdates.DateFormatter("%H:%M:%S"))
ax1.set_xlabel("Time (UTC)")
ax1.set_ylabel("RV [m/s]")
plt.legend()
plt.show()

fig = plt.figure()
ax1 = fig.add_subplot()
ax1.scatter(time_stamps, intensity_list)  
ax1.xaxis.set_major_formatter(mdates.DateFormatter("%H:%M:%S"))
ax1.set_xlabel("Time (UTC)")
ax1.set_ylabel("Relative Intensity") 
plt.show()