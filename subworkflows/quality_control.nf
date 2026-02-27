//
// Read QC and Trimming
//

include { FASTQC as FASTQC_RAW; FASTQC as FASTQC_TRIMMED } from '../modules/fastqc'
include { TRIMMOMATIC                                     } from '../modules/trimmomatic'
include { JELLYFISH                                       } from '../modules/jellyfish'

workflow QUALITY_CONTROL {
    take:
    ch_reads // channel: [ val(sample_id), [ path(reads) ] ]

    main:
    // Raw QC
    FASTQC_RAW(ch_reads, 'raw')

    // Trimming
    TRIMMOMATIC(ch_reads)

    // Post-trim QC
    FASTQC_TRIMMED(TRIMMOMATIC.out.trimmed_reads, 'trimmed')

    // K-mer Analysis
    JELLYFISH(TRIMMOMATIC.out.trimmed_reads)

    // Versions
    ch_versions = FASTQC_RAW.out.versions
        .mix(TRIMMOMATIC.out.versions)
        .mix(JELLYFISH.out.versions)

    emit:
    trimmed_reads = TRIMMOMATIC.out.trimmed_reads
    fastqc_raw     = FASTQC_RAW.out.fastqc_results
    fastqc_trimmed = FASTQC_TRIMMED.out.fastqc_results
    jellyfish_sum  = JELLYFISH.out.summary
    versions       = ch_versions
}
