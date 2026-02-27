//
// Genome Annotation
//

include { FUNANNOTATE     } from '../modules/funannotate'
include { BUSCO_PROTEOME  } from '../modules/busco_proteome'

workflow ANNOTATION {
    take:
    ch_assembly    // channel: [ val(sample_id), path(assembly) ]
    funannotate_db // path
    busco_db       // path

    main:
    ch_versions = Channel.empty()

    FUNANNOTATE(ch_assembly, funannotate_db)
    ch_versions = ch_versions.mix(FUNANNOTATE.out.versions)

    // Annotation QC
    BUSCO_PROTEOME(FUNANNOTATE.out.proteins, busco_db)
    ch_versions = ch_versions.mix(BUSCO_PROTEOME.out.versions)

    emit:
    annotations       = FUNANNOTATE.out.annotation_dir
    busco_prot_summary= BUSCO_PROTEOME.out.summary
    versions          = ch_versions
}
