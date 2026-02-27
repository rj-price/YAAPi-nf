#!/usr/bin/env bash
#SBATCH -J nf-YAAPi
#SBATCH --partition=long
#SBATCH --mem=16G
#SBATCH --cpus-per-task=2
#SBATCH --output=logs/yaapi_%j.log

# Ensure log directory exists
mkdir -p logs

# Load Nextflow environment (adjust if using a different method like 'module load')
source activate nextflow

# Run the pipeline
nextflow run main.nf \
    --input samplesheet.csv \
    --outdir results \
    -profile slurm,singularity \
    -resume
