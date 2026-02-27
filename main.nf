#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

// Help message
def helpMessage() {
    log.info"""
    YAAPi-nf: Yeast Assembly and Annotation Pipeline
    ================================================
    Usage:
    nextflow run main.nf --input '/path/to/samplesheet.csv' --outdir '/path/to/results'

    Mandatory arguments:
      --input [path]                Path to input samplesheet (CSV: sample,fastq_1,fastq_2)

    Optional arguments:
      --outdir [path]               The output directory [default: ./results]
      --busco_db [path]             Path to BUSCO database
      --kraken2_db [path]           Path to Kraken2 database
      --mito_db [path]              Path to Organelle BLAST database
      --funannotate_db [path]       Path to Funannotate database
      --busco_lineage [str]         BUSCO lineage [default: fungi_odb10]
      --kmer_length [int]           K-mer length for Jellyfish/Merqury [default: 21]
      --ploidy [int]                Ploidy for Jellyfish/GenomeScope2 [default: 2]
      --skip_annotation [bool]      Skip Funannotate gene prediction [default: false]
      --help                        Display this help message
    """.stripIndent()
}

// Show help message if requested
if (params.help) {
    helpMessage()
    exit 0
}

// Validate mandatory parameters
if (!params.input) {
    log.error "ERROR: Mandatory parameter '--input' is not defined."
    helpMessage()
    exit 1
}

// Log parameter summary
log.info """
    ========================================================================
    YAAPi-nf  ~  Yeast Assembly and Annotation Pipeline
    ========================================================================
    input            : ${params.input}
    outdir           : ${params.outdir}
    busco_db         : ${params.busco_db}
    kraken2_db       : ${params.kraken2_db}
    mito_db          : ${params.mito_db}
    funannotate_db   : ${params.funannotate_db}
    busco_lineage    : ${params.busco_lineage}
    kmer_length      : ${params.kmer_length}
    ploidy           : ${params.ploidy}
    skip_annotation  : ${params.skip_annotation}
    ========================================================================
    """.stripIndent()

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT SUBWORKFLOWS / MODULES
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

include { INPUT_CHECK         } from './subworkflows/input_check'
include { QUALITY_CONTROL     } from './subworkflows/quality_control'
include { ASSEMBLY_EVALUATION } from './subworkflows/assembly_evaluation'
include { ANNOTATION          } from './subworkflows/annotation'
include { MULTIQC             } from './modules/multiqc'

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    WORKFLOW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow {
    // 0. Input check
    INPUT_CHECK(params.input)
    ch_reads = INPUT_CHECK.out.reads

    // 1. Run Quality Control
    QUALITY_CONTROL(ch_reads)

    // 2. Run Assembly and Evaluation
    ASSEMBLY_EVALUATION(
        QUALITY_CONTROL.out.trimmed_reads,
        params.kraken2_db,
        params.mito_db
    )

    // 3. Run Annotation (optional)
    ch_annotation_versions = Channel.empty()
    if (!params.skip_annotation) {
        ANNOTATION(
            ASSEMBLY_EVALUATION.out.scaffolds,
            params.funannotate_db
        )
        ch_annotation_versions = ANNOTATION.out.versions
    }

    // 4. Software Versions
    QUALITY_CONTROL.out.versions
        .mix(ASSEMBLY_EVALUATION.out.versions, ch_annotation_versions)
        .unique()
        .collectFile(name: 'software_versions.yml', storeDir: "${params.outdir}/pipeline_info")
        .set { ch_collated_versions }

    // 5. MultiQC
    ch_multiqc_files = Channel.empty()
    ch_multiqc_files = ch_multiqc_files.mix(
        QUALITY_CONTROL.out.fastqc_raw.collect(),
        QUALITY_CONTROL.out.fastqc_trimmed.collect(),
        QUALITY_CONTROL.out.jellyfish_sum.collect(),
        ASSEMBLY_EVALUATION.out.busco_summary.collect(),
        ASSEMBLY_EVALUATION.out.kraken_report.collect(),
        ch_collated_versions
    )

    MULTIQC(ch_multiqc_files.collect())
}
