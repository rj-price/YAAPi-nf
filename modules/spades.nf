process SPADES {
    tag "SPAdes on $sample_id"
    container 'quay.io/biocontainers/spades:4.0.0--haf24da9_4'
    publishDir "${params.outdir}/${sample_id}/spades", mode: 'copy'
    cpus = 4
    memory = 16.GB
    queue = 'long'

    input:
    tuple val(sample_id), path(reads)

    output:
    tuple val(sample_id), path("${sample_id}_spades.fasta"), emit: scaffolds
    path "${sample_id}_spades_log.txt"

    script:
    """
    spades.py \
        -m 16 -t 8 \
        -k 21,33,55,77,99,127 \
        --careful \
        -1 ${reads[0]} -2 ${reads[1]} \
        -o ${sample_id}_spades_output

    mv ${sample_id}_spades_output/scaffolds.fasta ${sample_id}_spades.fasta
    mv ${sample_id}_spades_output/spades.log ${sample_id}_spades_log.txt
    """
}