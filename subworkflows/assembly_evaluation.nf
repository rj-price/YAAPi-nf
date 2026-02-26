//
// Assembly and Evaluation
//

include { MEGAHIT   } from '../modules/megahit'
include { GFASTATS  } from '../modules/gfastats'
include { QUAST     } from '../modules/quast'
include { BUSCO     } from '../modules/busco'
include { MERQURY   } from '../modules/merqury'
include { KRAKEN2   } from '../modules/kraken2'
include { MITO_CHECK} from '../modules/mito_check'

workflow ASSEMBLY_EVALUATION {
    take:
    ch_reads     // channel: [ val(sample_id), [ path(reads) ] ]
    kraken2_db   // path
    mito_db      // path

    main:
    ch_versions = Channel.empty()

    // 1. Assembly
    MEGAHIT(ch_reads)
    ch_versions = ch_versions.mix(MEGAHIT.out.versions)

    // 2. Statistics
    GFASTATS(MEGAHIT.out.scaffolds)
    ch_versions = ch_versions.mix(GFASTATS.out.versions)

    QUAST(ch_reads, MEGAHIT.out.scaffolds)
    ch_versions = ch_versions.mix(QUAST.out.versions)

    // 3. Completeness
    BUSCO(MEGAHIT.out.scaffolds)
    ch_versions = ch_versions.mix(BUSCO.out.versions)

    MERQURY(ch_reads, MEGAHIT.out.scaffolds)
    ch_versions = ch_versions.mix(MERQURY.out.versions)

    // 4. Contamination & Organelles
    KRAKEN2(MEGAHIT.out.scaffolds, kraken2_db)
    ch_versions = ch_versions.mix(KRAKEN2.out.versions)

    MITO_CHECK(MEGAHIT.out.scaffolds, mito_db)
    ch_versions = ch_versions.mix(MITO_CHECK.out.versions)

    emit:
    scaffolds     = MEGAHIT.out.scaffolds
    busco_summary = BUSCO.out.summary
    quast_results = QUAST.out.results
    kraken_report = KRAKEN2.out.report
    versions      = ch_versions
}
