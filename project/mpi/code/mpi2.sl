#!/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=24
#SBATCH --time=00:01:00
#SBATCH --output=mpi3.out
#SBATCH -A anakano_429

mpirun -n 1 ./mpi3
mpirun -n 2 ./mpi3
mpirun -n 4 ./mpi3
mpirun -n 8 ./mpi3
mpirun -n 16 ./mpi3
mpirun -n 24 ./mpi3
