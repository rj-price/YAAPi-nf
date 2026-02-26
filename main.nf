#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

// Help message
def helpMessage() {
    log.info"""
    YAAPi-nf: Yeast Assembly and Annotation Pipeline
    ================================================
    Usage:
    nextflow run main.nf --reads '/path/to/data/*{1,2}.fastq.gz' --outdir '/path/to/results'

    Mandatory arguments:
      --reads [path]                Path to input reads (must be quoted)

    Optional arguments:
      --outdir [path]               The output directory [default: ./results]
      --busco_db [path]             Path to BUSCO database
      --kraken2_db [path]           Path to Kraken2 database
      --mito_db [path]              Path to Organelle BLAST database
      --busco_lineage [str]         BUSCO lineage [default: fungi_odb10]
      --kmer_length [int]           K-mer length for Jellyfish/Merqury [default: 21]
      --ploidy [int]                Ploidy for Jellyfish/GenomeScope2 [default: 2]
      --help                        Display this help message
    """.stripIndent()
}

// Show help message if requested
if (params.help) {
    helpMessage()
    exit 0
}

// Validate mandatory parameters
if (!params.reads) {
    log.error "ERROR: Mandatory parameter '--reads' is not defined."
    helpMessage()
    exit 1
}

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT SUBWORKFLOWS / MODULES
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

include { QUALITY_CONTROL     } from './subworkflows/quality_control'
include { ASSEMBLY_EVALUATION } from './subworkflows/assembly_evaluation'
include { MULTIQC             } from './modules/multiqc'

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    WORKFLOW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow {
    ch_versions = Channel.empty()

    // Input reads
    ch_read_pairs = Channel.fromFilePairs(params.reads, checkIfExists: true)

    // 1. Run Quality Control
    QUALITY_CONTROL(ch_read_pairs)
    ch_versions = ch_versions.mix(QUALITY_CONTROL.out.versions)

    // 2. Run Assembly and Evaluation
    ASSEMBLY_EVALUATION(
        QUALITY_CONTROL.out.trimmed_reads,
        params.kraken2_db,
        params.mito_db
    )
    ch_versions = ch_versions.mix(ASSEMBLY_EVALUATION.out.versions)

    // 3. MultiQC
    ch_multiqc_files = Channel.empty()
    ch_multiqc_files = ch_multiqc_files.mix(
        QUALITY_CONTROL.out.fastqc_raw.collect(),
        QUALITY_CONTROL.out.fastqc_trimmed.collect(),
        QUALITY_CONTROL.out.jellyfish_sum.collect(),
        ASSEMBLY_EVALUATION.out.busco_summary.collect(),
        ASSEMBLY_EVALUATION.out.quast_results.collect(),
        ASSEMBLY_EVALUATION.out.kraken_report.collect(),
        ch_versions.unique().collectFile(name: 'software_versions.yml', storeDir: "${params.outdir}/pipeline_info")
    )

    MULTIQC(ch_multiqc_files.collect())
}
