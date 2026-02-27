# YAAPi-nf: Yeast Assembly and Annotation Pipeline

**YAAPi-nf** is a modular, production-ready bioinformatics pipeline built with **Nextflow (DSL2)**. It is specifically designed for the de novo assembly and annotation of yeast genomes using Illumina paired-end reads.

The pipeline is highly portable, supporting **Docker**, **Singularity**, and **Conda**, and is optimized for High-Performance Computing (HPC) environments using the **SLURM** scheduler.

---

## 🧬 Pipeline Overview

The pipeline is organized into three main subworkflows:

1.  **Quality Control & Preprocessing** (`QUALITY_CONTROL`)
    *   Raw read QC (**FastQC**)
    *   Adapter trimming and quality filtering (**Trimmomatic**)
    *   Post-trimming QC (**FastQC**)
    *   K-mer analysis for genome size and ploidy estimation (**Jellyfish** & **GenomeScope2**)
2.  **Assembly & Evaluation** (`ASSEMBLY_EVALUATION`)
    *   De novo assembly (**MEGAHIT**)
    *   Assembly statistics (**GFAStats**)
    *   Genome completeness Assessment (**BUSCO** in Genome mode)
    *   Reference-free assembly evaluation (**Merqury**)
    *   Taxonomic contamination check (**Kraken2**)
    *   Mitochondrial/Organelle identification (**Mito Check** - BLAST-based)
3.  **Genome Annotation** (`ANNOTATION`)
    *   Gene prediction and functional annotation (**Funannotate**)
    *   Annotation Quality Control (**BUSCO** in Proteome mode)
4.  **Reporting**
    *   Aggregation of all QC metrics and logs into a single interactive report (**MultiQC**)
    *   Automatic collection of software versions for reproducibility.

---

## 🚀 Quick Start

1.  **Prepare your samplesheet** (see [Inputs](#-inputs) below).
2.  **Run the pipeline**:
    ```bash
    nextflow run main.nf --input samplesheet.csv --outdir ./results -profile singularity
    ```

For HPC users (SLURM), use the provided wrapper script:
```bash
sbatch yaapi.sh
```

---

## 📥 Inputs

### Samplesheet Requirement
The pipeline requires a mandatory CSV samplesheet provided via the `--input` flag.

**Format (`samplesheet.csv`):**
```csv
sample,fastq_1,fastq_2
SampleA,reads/sampleA_R1.fastq.gz,reads/sampleA_R2.fastq.gz
SampleB,reads/sampleB_R1.fastq.gz,reads/sampleB_R2.fastq.gz
```

---

## ⚙️ Parameters

### Mandatory
| Parameter | Description |
| :--- | :--- |
| `--input` | Path to the CSV samplesheet. |

### Database Paths (Configured in `nextflow.config`)
| Parameter | Description |
| :--- | :--- |
| `--busco_db` | Path to BUSCO database lineages. |
| `--kraken2_db` | Path to Kraken2 standard/custom database. |
| `--mito_db` | Path to BLAST database for organelle checking. |
| `--funannotate_db` | Path to the Funannotate database root. |

### Optional Tool Settings
| Parameter | Description | Default |
| :--- | :--- | :--- |
| `--outdir` | Output directory for results. | `./results` |
| `--single_out` | If true, omits sample subfolders in output. | `false` |
| `--busco_lineage` | Lineage to use for BUSCO. | `fungi_odb10` |
| `--kmer_length` | K-mer size for Jellyfish/Merqury. | `21` |
| `--ploidy` | Expected ploidy for GenomeScope2. | `2` |
| `--skip_annotation`| Skips the Funannotate and Proteome QC steps. | `false` |

---

## 📂 Outputs

Results are organized by **sample** and then by **process/tool**:

```text
results/
├── SampleA/
│   ├── fastqc/           # Read QC reports
│   ├── trimmomatic/      # Trimmed FASTQ files
│   ├── megahit/          # Assembly (fasta)
│   ├── busco/            # Genome-level BUSCO results
│   ├── kraken2/          # Taxonomic reports
│   ├── funannotate/      # GFF3, Proteins, and Transcripts
│   └── busco_proteome/   # Protein-level BUSCO results
├── pipeline_info/        # Execution reports, timelines, and software_versions.yml
└── multiqc_report.html   # Final aggregated report
```

---

## 🛠️ Infrastructure Support

### Profiles
*   `-profile singularity`: Uses Singularity/Apptainer containers (recommended for HPC).
*   `-profile docker`: Uses Docker containers.
*   `-profile conda`: Uses Conda environments (less reproducible).
*   `-profile slurm`: Enables the SLURM executor for cluster job submission.

### Resource Management
The pipeline uses a dynamic resource allocation strategy defined in `conf/base.config`. If a task fails due to memory limits (Exit 137), it will automatically retry once with doubled resources.
