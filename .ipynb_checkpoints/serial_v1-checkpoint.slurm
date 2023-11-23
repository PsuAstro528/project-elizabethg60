#!/bin/bash 
## Submit job to our class's allocation
#SBATCH --partition=sla-prio
#SBATCH --account=ebf11-fa23
## Alternatively could comment out the two lines above (by adding a second # at the beginning of each line)
# and uncomment the lines below (by removing one #) to use the "Open" allocation
##SBATCH --partition=open 

## Time requested: 4 hours, 0 minutes, 0 seconds
#SBATCH --time=4:00:00 

## Ask for one core on one node
#SBATCH --nodes=1 
#SBATCH --ntasks=1 

## Promise that each processor will use no more than 100GB of RAM
#SBATCH --mem-per-cpu=100GB

## Save STDOUT and STDERR into one file (%j will expand to become the SLURM job id)
#SBATCH --output=serial_v1_%j.log
## Optionally could uncomment line below to write STDERR to a separate file
##SBATCH --error=serial_v1_%j.stderr  

## Specificy job name, so easy to find using squeue –u
#SBATCH --job-name=serial_v1

## Uncomment next two lines (by removing one of #'s in each line) and replace with your email if you want to be notifed when jobs start and stop
##SBATCH --mail-user=efg5335@psu.edu
## Ask for emails when jobs begins, ends or fails (options are ALL, NONE, BEGIN, END, FAIL)
#SBATCH --mail-type=ALL

echo "Starting job $SLURM_JOB_NAME"
echo "Job id: $SLURM_JOB_ID"
date

echo "Activing environment with that provides Julia 1.9.2"
source /storage/group/RISE/classroom/astro_528/scripts/env_setup

echo "About to change into $SLURM_SUBMIT_DIR"
cd $SLURM_SUBMIT_DIR            # Change into directory where job was submitted from

date
echo "About to start Julia"
julia --project=. serial_v1.jl
echo "Julia exited"
date