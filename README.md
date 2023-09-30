[![Open in Visual Studio Code](https://classroom.github.com/assets/open-in-vscode-718a45dd9cf7e7f842a935f5ebbe5719a5e09af4491e668f4dbf3b35d5cca122.svg)](https://classroom.github.com/online_ide?assignment_repo_id=11858194&assignment_repo_type=AssignmentRepo)
# Astro 528 [Class Project](https://psuastro528.github.io/Fall2023/project/)

[![](https://img.shields.io/badge/docs-stable-blue.svg)](https://PsuAstro528.github.io/project-template/stable)

GitHub Actions : [![Build Status](https://github.com/PsuAstro528/project-template/workflows/CI/badge.svg)](https://github.com/PsuAstro528/project-template/actions?query=workflow%3ACI+branch%3Amain)


##  Overview
In this project, I simulate the March 20, 2015 solar eclipse from Göttingen, Germany via the sun's observered velocity with respect to the observer. I query JPL horizons using Julia package SPICE for required body parameters. The surface of the sun is gridded to allow for determination of which cells are being blocked by the moon during the eclipse and more accurate solar velocities (astrophysical reasons lie with convective blueshift activity). For a set of timestamps between 7:05UT and 12:05UT on 03/20/2015, the limb darkening weighted velocity is determined for each visual cell (not blocked by moon) on the solar surface grid along the line of sight to the observer in Göttingen. This project will then parallelize the grid size to evaluate performance and accuracy of recovered velocity with respect to grid size. 

## To Run / Use code:
1. update variable datdir in get_kernels.jl to correct directory
In terminal:
2. using Pkg
3. Pkg.develop(path= "your directory") 
4. Pkg.add(["Revise", "SPICE", "Downloads", "LinearAlgebra", "NaNMath", "BenchmarkTools", "Test", "Profile"])
    *note: you may have to download some of above package first before adding to Pkg
    *note: may have to instantiate after adding using: Pkg.instantiate()
5. using Revise
6. using MyProject
7. MyProject.getkernels()
for here can run whichever function you want via MyProject.function_name
example: to run the time loop to get recovered velocity at each timestamp with grid size 100x100
        MyProject.loop(100,100)

## Feedback
Hoping for focused feedback in optimizing functions in terms of time and memory allocations. Results from benchmarking and profiling can be found from running benchmark_profile.jl that is in test folder. For feedback, start with considering profile results for the max_epoch function to optimize single use of functions then consider profile for loop function to optimize how these function are running in time loop. These profiles should guide us to function that need our attention for optimization in terms of time and more importantly memory.
(run using: include("path to benchmark_profile.jl") )

Secondary to optimizing functions, I ask for feedback in type stability. I have not had time to evaluate stability so would appreciate feedback here. 

Lastly, unit tests. A good unit test is to check that the matrices representing the vector from sun center to each patch all have a magnitude equal to sun radius; however, I could not figure out how to call these variables in runtests.jl given that they are local variables else where - could use help doing this. Also, could use insight into other potential unit tests. 

My integration tests did bring up a bug in my code. When testing what the recovered velocity would be for the sun if the moon was 50x larger in radii, I found that the recovered velocity did not change with moon radii since in the case of a super large moon the recovered velocity should be zero at peak eclipse since the sun would be entirely not visible. I will work on this so no need to address. Once fixed the other integration test would be the other limit when the moon's radii close to zero, or no moon present. 

Sanity checks are done with figures for mu grid and projected velocity grid. These are not found within runtests.jl but when running max_epoch.jl For this module, I had difficulty getting PyPlot as a dedendency, if successfully added on your behalf can uncomment using PyPlot line in MyProject.jl and the two plotting code in max_epoch.jl for code. 

## Project Goals:  
- Put software development skills learned during class and lab exercises into practice on a real world problem
- Gain experience optimizing real scientific code
- Gain experience parallelizing a real scientific code 
- Investigate how performance scales with problem size and number of processors
- Share lessons learned with the class

Prior to the [peer code review](https://psuastro528.github.io/Fall2023/project/code_reviews/), update this readme, so as to make it easy for your peer code reviewer to be helpful.  What should they know before starting the review?  Where should they look first?  

Remember to commit often and push your repository to GitHub prior to each project deadline.

## Class Project Schedule
- Project proposal (due Sept 6)
- Serial version of code (due Oct 2)
- Peer code review (due Oct 9)
- Parallel version of code (multi-core) (due Oct 30)
- Second parallel version of code (distributed-memory/GPU/cloud) (due Nov 13)
- Completed code, documentation, tests, packaging (optional) & reflection (due Nov 29)
- Class presentations (Nov 27 - Dec 6, [detailed schedule](https://github.com/PsuAstro528/PresentationsSchedule2023) )

