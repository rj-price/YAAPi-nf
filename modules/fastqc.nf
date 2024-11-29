process FASTQC {
    tag "FASTQC on $sample_id"
    container "biocontainers/fastqc:v0.11.9_cv8"
    publishDir "${params.outdir}/fastqc", mode: 'copy'
    cpus = 1
    memory = 1.GB
    queue = 'short'

    input:
    tuple val(sample_id), path(reads)

    output:
    path "*_fastqc.{zip,html}", emit: fastqc_results

    script:
    """
    fastqc -q ${reads}
    """
}