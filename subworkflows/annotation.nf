//
// Genome Annotation
//

include { FUNANNOTATE } from '../modules/funannotate'

workflow ANNOTATION {
    take:
    ch_assembly    // channel: [ val(sample_id), path(assembly) ]
    funannotate_db // path

    main:
    ch_versions = Channel.empty()

    FUNANNOTATE(ch_assembly, funannotate_db)
    ch_versions = ch_versions.mix(FUNANNOTATE.out.versions)

    emit:
    annotations = FUNANNOTATE.out.annotation_dir
    versions    = ch_versions
}
