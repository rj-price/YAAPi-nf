#!/usr/bin/env bash
#SBATCH -J nf-YAAPi
#SBATCH --partition=long
# Use 16G for initial run 
#SBATCH --mem=4G
#SBATCH --cpus-per-task=2

# INPUTS
Reads=$1
OutDir=$2

export MYCONDAPATH=/mnt/shared/scratch/jnprice/apps/conda
source ${MYCONDAPATH}/bin/activate nextflow

nextflow run main.nf -c ~/cropdiv.config -resume
#    --reads $ReadsDir \
#    --outdir $OutDir