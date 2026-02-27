//
// Assembly and Evaluation
//

include { MEGAHIT   } from '../modules/megahit'
include { GFASTATS  } from '../modules/gfastats'
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
    // 1. Assembly
    MEGAHIT(ch_reads)

    // 2. Statistics
    GFASTATS(MEGAHIT.out.scaffolds)

    // 3. Completeness
    BUSCO(MEGAHIT.out.scaffolds)
    MERQURY(ch_reads, MEGAHIT.out.scaffolds)

    // 4. Contamination & Organelles
    KRAKEN2(MEGAHIT.out.scaffolds, kraken2_db)
    MITO_CHECK(MEGAHIT.out.scaffolds, mito_db)

    // 5. Versions
    ch_versions = MEGAHIT.out.versions
        .mix(GFASTATS.out.versions)
        .mix(BUSCO.out.versions)
        .mix(MERQURY.out.versions)
        .mix(KRAKEN2.out.versions)
        .mix(MITO_CHECK.out.versions)

    emit:
    scaffolds     = MEGAHIT.out.scaffolds
    busco_summary = BUSCO.out.summary
    kraken_report = KRAKEN2.out.report
    versions      = ch_versions
}
