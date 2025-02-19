process QUAST {
    container 'community.wave.seqera.io/library/quast:5.3.0--755a216045b6dbdd'
    publishDir "${params.outdir}/${sample_id}/quast", mode: 'copy'
    cpus = 4
    memory = { 8.GB * task.attempt }
    queue = 'medium'
    
    input:
    tuple val(sample_id), path(reads)
    tuple val(sample_id), path(assembly)

    output:
    path "*"

    script:
    """
    quast.py \
        --threads 8 \
        ${assembly} \
        -1 ${reads[0]} -2 ${reads[1]} \ 
        -o quast_out
    """
}
