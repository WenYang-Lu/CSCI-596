#!/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --gres=gpu:1 
#SBATCH --time=00:00:59
#SBATCH --output=matrix_multiplication_cpu.out
#SBATCH -A anakano_429
./matrix_multiplication_cpu