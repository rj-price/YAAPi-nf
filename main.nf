#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

// Input Parameters
params.reads        = "${launchDir}/data/*{1,2}.f*q.gz"
params.outdir       = "${launchDir}/results"
params.busco_db     = "/mnt/shared/scratch/jnprice/apps/funannotate_db/saccharomyceta_odb9"

include { FASTQC } from './modules/fastqc'
include { TRIMMOMATIC } from './modules/trimmomatic'
include { SPADES } from './modules/spades'
include { GFASTATS } from './modules/gfastats'
include { FUNANNOTATE } from './modules/funannotate'
include { BUSCO } from './modules/busco'
include { MULTIQC } from './modules/multiqc'

workflow {
    // Create channel for input reads
    read_pairs_ch = Channel.fromFilePairs(params.reads, checkIfExists: true)

    // Run FastQC on raw reads
    FASTQC(read_pairs_ch)

    // Trim reads
    TRIMMOMATIC(read_pairs_ch)

    // Assemble genome
    SPADES(TRIMMOMATIC.out.trimmed_reads)

    // Assess assembly quality
    GFASTATS(SPADES.out.scaffolds)

    // Predict genes
    FUNANNOTATE(SPADES.out.scaffolds, params.busco_db)

    // Assess genome completeness
    BUSCO(SPADES.out.scaffolds)

    // Aggregate QC reports
    MULTIQC(FASTQC.out.fastqc_results.collect().mix(
        BUSCO.out.collect()
    ).collect())
}

