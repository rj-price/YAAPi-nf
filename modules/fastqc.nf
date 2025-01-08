process FASTQC {
    tag "FASTQC on $sample_id"
    container "biocontainers/fastqc:v0.11.9_cv8"
    publishDir "${params.outdir}/${sample_id}/fastqc", mode: 'copy'
    cpus = 1
    memory = 1.GB
    queue = 'short'

    input:
    tuple val(sample_id), path(reads)
    val(stage)

    output:
    path "*", emit: fastqc_results

    script:
    """
    mkdir ./${stage}
    fastqc -q ${reads} --outdir ./${stage}
    """
}