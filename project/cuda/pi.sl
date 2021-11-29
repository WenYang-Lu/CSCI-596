#!/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --gres=gpu:1 
#SBATCH --time=00:00:59
#SBATCH --output=pi.out
#SBATCH -A anakano_429
./pi