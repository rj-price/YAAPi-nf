process BUSCO {
    tag "BUSCO on $sample_id"
    container 'community.wave.seqera.io/library/busco:5.2.2--b38cf04af6adc85b'
    publishDir "${params.outdir}/busco", mode: 'copy'
    cpus = 8
    memory = 3.GB
    queue = 'medium'

    input:
    tuple val(sample_id), path(scaffolds)

    output:
    path "${sample_id}_busco"
    path "${sample_id}_busco/short_summary.*${sample_id}.txt", emit: summary

    script:
    """
    busco -i ${scaffolds} -o ${sample_id}_busco -m genome -l fungi_odb10
    """
}