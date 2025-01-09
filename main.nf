#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

// Input Parameters
params.reads        = "${launchDir}/data/*{1,2}.f*q.gz"
params.outdir       = "${launchDir}/results"
params.busco_db     = "/mnt/shared/scratch/jnprice/apps/funannotate_db/saccharomyceta_odb9"

include { FASTQC as FASTQC_RAW } from './modules/fastqc'
include { TRIMMOMATIC } from './modules/trimmomatic'
include { FASTQC as FASTQC_TRIMMED } from './modules/fastqc'
include { JELLYFISH } from './modules/jellyfish'
include { SPADES } from './modules/spades'
include { GFASTATS } from './modules/gfastats'
include { BUSCO } from './modules/busco'
include { MERQURY } from './modules/merqury'
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

    // Assemble genome
    SPADES(TRIMMOMATIC.out.trimmed_reads)

    // Assess assembly quality
    GFASTATS(SPADES.out.scaffolds)

    // Assess genome completeness
    BUSCO(SPADES.out.scaffolds)

    // Merqury
    MERQURY(TRIMMOMATIC.out.trimmed_reads, SPADES.out.scaffolds)

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

