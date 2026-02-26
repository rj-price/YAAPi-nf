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
    IMPORT MODULES
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

include { FASTQC as FASTQC_RAW     } from './modules/fastqc'
include { TRIMMOMATIC               } from './modules/trimmomatic'
include { FASTQC as FASTQC_TRIMMED } from './modules/fastqc'
include { JELLYFISH                 } from './modules/jellyfish'
include { MEGAHIT                   } from './modules/megahit'
include { GFASTATS                  } from './modules/gfastats'
include { QUAST                     } from './modules/quast'
include { BUSCO                     } from './modules/busco'
include { MERQURY                   } from './modules/merqury'
include { KRAKEN2                   } from './modules/kraken2'
include { MITO_CHECK                } from './modules/mito_check'
include { MULTIQC                   } from './modules/multiqc'

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    WORKFLOW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow {
    ch_versions = Channel.empty()

    // Input reads
    ch_read_pairs = Channel.fromFilePairs(params.reads, checkIfExists: true)

    // 1. Quality Control
    FASTQC_RAW(ch_read_pairs, 'raw')
    ch_versions = ch_versions.mix(FASTQC_RAW.out.versions)

    TRIMMOMATIC(ch_read_pairs)
    ch_versions = ch_versions.mix(TRIMMOMATIC.out.versions)

    FASTQC_TRIMMED(TRIMMOMATIC.out.trimmed_reads, 'trimmed')

    // 2. K-mer Analysis
    JELLYFISH(TRIMMOMATIC.out.trimmed_reads)
    ch_versions = ch_versions.mix(JELLYFISH.out.versions)

    // 3. Assembly
    MEGAHIT(TRIMMOMATIC.out.trimmed_reads)
    ch_versions = ch_versions.mix(MEGAHIT.out.versions)

    // 4. Assembly Evaluation
    GFASTATS(MEGAHIT.out.scaffolds)
    ch_versions = ch_versions.mix(GFASTATS.out.versions)

    QUAST(TRIMMOMATIC.out.trimmed_reads, MEGAHIT.out.scaffolds)
    ch_versions = ch_versions.mix(QUAST.out.versions)

    BUSCO(MEGAHIT.out.scaffolds)
    ch_versions = ch_versions.mix(BUSCO.out.versions)

    MERQURY(TRIMMOMATIC.out.trimmed_reads, MEGAHIT.out.scaffolds)
    ch_versions = ch_versions.mix(MERQURY.out.versions)

    // 5. Taxonomy & Organelles
    KRAKEN2(MEGAHIT.out.scaffolds, params.kraken2_db)
    ch_versions = ch_versions.mix(KRAKEN2.out.versions)

    MITO_CHECK(MEGAHIT.out.scaffolds, params.mito_db)
    ch_versions = ch_versions.mix(MITO_CHECK.out.versions)

    // 6. MultiQC
    ch_multiqc_files = Channel.empty()
    ch_multiqc_files = ch_multiqc_files.mix(
        FASTQC_RAW.out.fastqc_results.collect(),
        FASTQC_TRIMMED.out.fastqc_results.collect(),
        TRIMMOMATIC.out.versions.collect(),
        JELLYFISH.out.summary.collect(),
        MEGAHIT.out.versions.collect(),
        BUSCO.out.summary.collect(),
        QUAST.out.results.collect(),
        KRAKEN2.out.report.collect(),
        ch_versions.unique().collectFile(name: 'software_versions.yml', storeDir: "${params.outdir}/pipeline_info")
    )

    MULTIQC(ch_multiqc_files.collect())
}
