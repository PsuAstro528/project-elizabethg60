#query needed parameters relative to solar system barycenter
#collect E,S,M radii (units:km)
earth_radius = bodvrd("EARTH", "RADII")[1]	
sun_radius = bodvrd("SUN","RADII")[1]
moon_radius = bodvrd("MOON", "RADII")[1]
#collect E,S,M position (km) & velocities (km/s)
earth_pv = spkssb(399,epoch,"J2000") 
sun_pv = spkssb(10,epoch,"J2000")
moon_pv = spkssb(301,epoch,"J2000")

#set current epoch 
epoch = utc2et("2015-03-20T09:42:00")

