[![Open in Visual Studio Code](https://classroom.github.com/assets/open-in-vscode-718a45dd9cf7e7f842a935f5ebbe5719a5e09af4491e668f4dbf3b35d5cca122.svg)](https://classroom.github.com/online_ide?assignment_repo_id=11858194&assignment_repo_type=AssignmentRepo)
# Astro 528 [Class Project](https://psuastro528.github.io/Fall2023/project/)

[![](https://img.shields.io/badge/docs-stable-blue.svg)](https://PsuAstro528.github.io/project-template/stable)

GitHub Actions : [![Build Status](https://github.com/PsuAstro528/project-template/workflows/CI/badge.svg)](https://github.com/PsuAstro528/project-template/actions?query=workflow%3ACI+branch%3Amain)


## Completed Project

##  Overview
In this project, I simulate the October 14th, 2023 solar eclipse as viewed from NEID via the Sun's observed velocity with respect to the observer. I query JPL horizons using SPICE for required body parameters and then set up the system orientation via vector algebra. The surface of the Sun is gridded to allow for determination of which cells are blocked by the moon during the eclipse and to collect a more accurate solar velocity. Accounting for differential rotation and weighting for limb darkening and cell projected surface area along the line of sight to the observer, I collect the average radial velocity of the Sun during the solar eclipse. This code is written in Julia and can be run in the terminal as follows: 
using MyProject
MyProject.get_kernels()
MyProject.neid_loop(num_lats, num_lons)

The user must input the number of latitudes and longitudes to be used for the solar grid into neid_loop, which does not return anything but rather saves the computed radial velocity for each timestamp into a .jld2 file under src/plots/NEID/data. Using python I then create a simulated movie of what the eclipse looked like from NEID and also the corresponding RM curve with make_plots.py in src/plots/NEID. This is done to support the project visually and not apart of the main project which is all found in src outside of the plots folder. 

Above are the instructions on how to simulate the entire eclipse, if interested in determining the radial velocity for a single timestamp for the 10/14 eclispe from NEID do as follows:
using SPICE, MyProject
MyProject.get_kernels()
obs_lat = 31.9583 
obs_long = -111.5967  
alt = 2.097938
index = 0 
time_stamp = utc2et("2023-10-14T16:00:45")
MyProject.compute_rv(num_lats, num_lons, time_stamp, index, obs_long, obs_lat, alt)

time_stamp can be changed to any time using the above format; obs_long, obs_lat, alt are set for NEID but can be changed to another observatory, index = 0 so it does not save a .jld2 file
compute_rv returns the calculated radial velcotity for the given information and also a benchmark timing for how long the portion of the code that eventually will be parallized takes - this is the first method of benchmarking which will be further explained later on along with other benchmarks

As mentioned the project code can be found in the src folder excluding the plots folder which just makes the visual support for the project. The module is created in MyProject.jl and the downloading of JPL horizons data is done in get_kernels.jl. The main computations are all done in epoch_computations with the dependent functions separated into coordinates.jl, velocity.jl, and moon.jl that respectively hold the functions related to the orientation, velocity calculation, and eclisping moon. The multi-threading parallel version of this is found in the same files with name ending in _pa. The main computation is then called within a time for-loop to capture the entire eclipse and also a problem size for-loop to capture variation in benchmarking with problem size inside of time_loop.jl. The multi-processing parallel version is found in parallel_v2.jl where I had to restructure my code from using matrices to array in order to take advantage of @distributed - so rather than working on the entire grid at a time it distributes individual cells to avaible processors. 

Inside the test folder, you will find my test file along with the benchmark results in .jld2 files so I can make figures capturing the change of performance - this again will be further explained below. My test file, runtests.jl, will be automatically ran when compiling MyProject with "using MyProject" but if interested in reruning the tests simply include("runtests.jl").  

The jobs submitted for the benchmark results are all found outside of the src folder inside project-elizabethg60. These slurm files were ran to collect the benchmark results - process explained below. 

## Benchmarking Results: 

## Parallel Code V1
This project will parallelize over the grid size (the problem size) to evaluate performance with respect to grid size. For now my parallel code is over multiple cores using a shared memory system making use of Threads.@threads - I found that when mixing Threads and ThreadsX the performance was not impacted. My most inner functions in coordinates.jl, moon.jl, and velocity.jl have been duplicated to have a parallel version using Threads. The main script that computes the RVs is the compute_rv function in epoch_computations.jl has also been duplicated in epoch_computations_pa. So compute_rv in epoch_computations.jl is my serial code and compute_rv_pa in epoch_computations_pa.jl is my multi-threading parallel code. I determine the time taken for the serial and parallel version to run for a range of latitudes from 50 to 2000. Let N = number latitudes then the problem size is 2N^2 since number of longitudes is doubled N. The benchmark time used here is the returned duration from compute_rv and compute_rv_pa as to only compare the duration of the portion of the code that is parallelized. To get this run parallel_loop() and serial_loop(). I ran these via the slurm files found outside the src folder under project-elizabethg60. 

The results are found in figures one-four under src/test; these highlight how performance varies with problem size for a fixed number of workers. As you can see the parallel code has a shorter compute time than the serial code as the problem size increases. figure_two.png shows how the gap in compute time increases slightly with problem size between the serial and parallel code. However, the improvement in performance is very small - likely because the compute time for the parallized functions is already small in serial so cumulative parallelization over these functions still has small improvement. Below is the benchmark results for the parallelized functions in serial for the smallest grid size 50x100. 
frame_transfer: 0.000669931 seconds
for loop BP_bary: 0.000357 seconds
earth2patch_vectors: 0.000345 seconds
calc_mu_grid: 0.000369 seconds
v_scalar: 0.000214 seconds
pole_vector_grid: 0.000553 seconds
v_vector: 0.001499937 seconds
projected: 0.0005456 seconds
calc_dA: 0.033330095 seconds

Regardless an improvement in performance is found from cumulative parallelization of these functions for the problem sizes tested. These effect should be larger for higher problem sizes and even more so when ran for all timestamps rather than just a single timestamp. Also, as expect the compute time improves with increased cpus as seen in figure five. 

## Parallel Code V2
Version one of my parallel code used multi-threading and is described above. For version two, I use multi-processing. This parallel code can be found in parallel_v2.jl where I have rewritten the computation function compute_rv for a single patch so that I can distribute individual patches to available processors. The function parallel_v2 computes the grid for a given problem size and then distributes individual patches of the solar grid to compute_rv_pa2 so the components of the velocity can be done on separate processors. For this parallel code I use a single timestamp during the eclipse - I have confirmed that the restructured computation returns the expected velocity. I have determined the strong scaling for three problems sizes: 50x100 and 250x500 and 500x1000. To run in a julia terminal, follow: 
using Distributed
addprocs(num_processor)
@everywhere using MyProject
@everywhere MyProject.get_kernels()
MyProject.parallel_v2()

This will save the compute time for each case into a .jld2 file under src/test where I then use python to create the figure visually how performance varies with number of workers for the fixed problem sizes. Figure six shows the strong scaling results for these selected problem sizes. As expected larger problem sizes take longer and as seen an increase from one to five workers reduces the computation time. After five workers the computation time flattens. 

## Lessons Learned: 
One of the most crucial lessons I learned with this project is the importance of planning ahead as to avoid increasing my work load. For example, when starting my project I made use of matrices to grid the sun but eventually ran into an issue implementing this code with multi-processing parallelization. As a result, I had to restructure my script for my parallel version two. This emphasizes the importance of knowing end goals so that present work can be tailored accordingly. Similarly, I also learned how to break up my thinking to create flow maps between serial and parallel code to best transition between the two. 

With respect to github, I learned the importance of using .gitignore! I was not aware of this feature early-on and ending up commiting several large files to github which quickly filled my repo and forced me to update the buffer settings so I could successfully continue to push my files. With these specific lessons in mind, I learned to appreciate having my code well organized and saved. 

This project also showed me how important it is to include both unit and integral tests. Throughout the project I found myself consistently creating units tests to confirm simple geometry and algebra. Eventually I was able to develop better insight to additional tests that could be performed. Overall, I took away how critical tests, both unit and integral, are to creating successful code. 
