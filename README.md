# YAAPi-nf
A yeast assembly and annotation pipeline for use with Illumina PE reads.

Pull Metschnikowia aff. pulcherrima strain UCD127 Illumina PE WGS data from ENA (https://pmc.ncbi.nlm.nih.gov/articles/PMC6013633/).
```bash
wget -nc ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR159/098/SRR15987198/SRR15987198_2.fastq.gz
wget -nc ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR159/098/SRR15987198/SRR15987198_1.fastq.gz
```

Test run using SLURM submission script
```bash
sbatch yaapi.sh
```

## Workflow

### Read QC
- FastQC (pre & post trimming)
- Trimmomatic
- Jellyfish & GenomeScope2 (kmer analysis)
- clumpify (read deduplications)?

### Assembly
- SPAdes
- ABySS ?
- MEGAHIT ?

### Assembly QC
- QUAST
- GFAstats
- BUSCO
- KAT
- Kraken2 (contamination check)
- BLAST (organelle check)
- ITSx (identify ITS region)
- BLAST (species estimation)

### Annotation
- RepeatMasker
- Funannotate
- InterProScan

## To do:
- Add kmer analysis (pre & post assembly)
- Add contamination check (kraken2)
- Add organelle check (mito blast)
- Add QUAST
- Add ITSx
- Add ITS BLAST
- Add clumpify
- Add similar species proteomes download
- Add ABySS
- Add MEGAHIT
- Add assembly comparisons
- Add InterProScan
- Add additional parameters
- Add help message in `main.nf` and documentation of usage in repo
- Add setup script (check & install conda/nextflow on hpc), config file, conditionals to submission script (needed? write simple bash pipeline to check)
- Add samplesheet integration to process multiple samples

### Test:

### Done:
- Add funannotate
- Add fastqc (pre & post filter)
