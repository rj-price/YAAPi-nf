//
// Read QC and Trimming
//

include { FASTQC as FASTQC_RAW     } from '../modules/fastqc'
include { TRIMMOMATIC               } from '../modules/trimmomatic'
include { FASTQC as FASTQC_TRIMMED } from '../modules/fastqc'
include { JELLYFISH                 } from '../modules/jellyfish'

workflow QUALITY_CONTROL {
    take:
    ch_reads // channel: [ val(sample_id), [ path(reads) ] ]

    main:
    ch_versions = Channel.empty()

    // Raw QC
    FASTQC_RAW(ch_reads, 'raw')
    ch_versions = ch_versions.mix(FASTQC_RAW.out.versions)

    // Trimming
    TRIMMOMATIC(ch_reads)
    ch_versions = ch_versions.mix(TRIMMOMATIC.out.versions)

    // Post-trim QC
    FASTQC_TRIMMED(TRIMMOMATIC.out.trimmed_reads, 'trimmed')

    // K-mer Analysis
    JELLYFISH(TRIMMOMATIC.out.trimmed_reads)
    ch_versions = ch_versions.mix(JELLYFISH.out.versions)

    emit:
    trimmed_reads = TRIMMOMATIC.out.trimmed_reads
    fastqc_raw     = FASTQC_RAW.out.fastqc_results
    fastqc_trimmed = FASTQC_TRIMMED.out.fastqc_results
    jellyfish_sum  = JELLYFISH.out.summary
    versions       = ch_versions
}
