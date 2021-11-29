#!/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=12
#SBATCH --time=00:01:00
#SBATCH --output=openmp5000.out
#SBATCH -A anakano_429

export OMP_NUM_THREADS=2
./openmp_5000
