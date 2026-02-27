#!/usr/bin/env bash
#SBATCH -J nf-YAAPi
#SBATCH --partition=long
#SBATCH --mem=16G
#SBATCH --cpus-per-task=2
#SBATCH --output=logs/yaapi_%j.log

# This script is a wrapper for running the YAAPI-nf pipeline on a SLURM cluster.
# Usage: sbatch yaapi.sh <samplesheet.csv> <output_dir> [extra nextflow flags]
# Example: sbatch yaapi.sh samplesheet.csv ./output -resume

SAMPLESHEET=$1
OUT_DIR=$2
shift 2 # Move past the first two arguments

# Check if mandatory arguments are provided
if [[ -z "$SAMPLESHEET" || -z "$OUT_DIR" ]]; then
    echo "Usage: sbatch yaapi.sh <samplesheet.csv> <output_dir> [extra nextflow flags]"
    exit 1
fi

# Ensure log directory exists
if [[ ! -d logs ]]; then
    mkdir -p logs
fi

source activate nextflow

nextflow run main.nf \
    -profile slurm,singularity \
    --input "$SAMPLESHEET" \
    --outdir "$OUT_DIR" \
    "$@"

