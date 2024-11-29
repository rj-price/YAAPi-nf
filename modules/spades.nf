process SPADES {
    tag "SPAdes on $sample_id"
    container 'biocontainers/spades:v3.13.1_cv1'
    publishDir "${params.outdir}/assembly", mode: 'copy'
    cpus = 8
    memory = 32.GB
    queue = 'long'

    input:
    tuple val(sample_id), path(reads)

    output:
    tuple val(sample_id), path("${sample_id}_scaffolds.fasta"), emit: scaffolds
    path "${sample_id}_spades_log.txt"

    script:
    """
    spades.py -m 30 -t 16 -1 ${reads[0]} -2 ${reads[1]} -o ${sample_id}_spades_output
    mv ${sample_id}_spades_output/scaffolds.fasta ${sample_id}_scaffolds.fasta
    mv ${sample_id}_spades_output/spades.log ${sample_id}_spades_log.txt
    """
}