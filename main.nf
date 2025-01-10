#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

// Input Parameters
params.reads        = "${launchDir}/data/*{1,2}.f*q.gz"
params.outdir       = "${launchDir}/results"
params.busco_db     = "/mnt/shared/scratch/jnprice/apps/funannotate_db/saccharomyceta_odb9"
params.kraken2_db   = "/mnt/apps/users/jnprice/databases/k2_pluspf_16gb_20240112"
params.mito_db      = "/mnt/apps/users/jnprice/databases/organelle_blast_db"

include { FASTQC as FASTQC_RAW } from './modules/fastqc'
include { TRIMMOMATIC } from './modules/trimmomatic'
include { FASTQC as FASTQC_TRIMMED } from './modules/fastqc'
include { JELLYFISH } from './modules/jellyfish'
include { MEGAHIT } from './modules/megahit'
include { GFASTATS } from './modules/gfastats'
include { BUSCO } from './modules/busco'
include { MERQURY } from './modules/merqury'
include { KRAKEN2 } from './modules/kraken2'
include { MITO_CHECK } from './modules/mito_check'
//include { FUNANNOTATE } from './modules/funannotate'
include { MULTIQC } from './modules/multiqc'

workflow {
    // Create channel for input reads
    read_pairs_ch = Channel.fromFilePairs(params.reads, checkIfExists: true)

    // Run FastQC on raw reads
    FASTQC_RAW(read_pairs_ch, 'raw')

    // Trim reads
    TRIMMOMATIC(read_pairs_ch)

    // Run FastQC on trimmed reads
    FASTQC_TRIMMED(TRIMMOMATIC.out.trimmed_reads, 'trimmed')

    // Jellyfish and GenomeScope2
    JELLYFISH(TRIMMOMATIC.out.trimmed_reads)

    // Assemble with MEGAHIT
    MEGAHIT(TRIMMOMATIC.out.trimmed_reads)

    // Assess assembly quality
    GFASTATS(MEGAHIT.out.scaffolds)

    // Assess genome completeness
    BUSCO(MEGAHIT.out.scaffolds)

    // Merqury
    MERQURY(TRIMMOMATIC.out.trimmed_reads, MEGAHIT.out.scaffolds)

    // Kraken2 for contamination check
    KRAKEN2(MEGAHIT.out.scaffolds, params.kraken2_db)

    // BLASTn for organelle check
    MITO_CHECK(MEGAHIT.out.scaffolds, params.mito_db)

    // Predict genes
    //FUNANNOTATE(SPADES.out.scaffolds, params.busco_db)

    // Collect QC reports
    multiqc_files = Channel.empty()
    multiqc_files = multiqc_files.mix(
        FASTQC_RAW.out.fastqc_results.collect(),
        FASTQC_TRIMMED.out.fastqc_results.collect(),
        BUSCO.out.summary.collect()
    )

    // MultiQC
    MULTIQC(multiqc_files.collect())
}

