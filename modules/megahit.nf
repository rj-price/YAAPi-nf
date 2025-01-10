process MEGAHIT {
    tag "MEGAHIT on $sample_id"
    container 'quay.io/biocontainers/megahit:1.2.9--h43eeafb_5'
    publishDir "${params.outdir}/${sample_id}/megahit", mode: 'copy'
    cpus = 4
    memory = 16.GB
    queue = 'long'

    input:
    tuple val(sample_id), path(reads)

    output:
    tuple val(sample_id), path("${sample_id}_megahit.fasta"), emit: scaffolds

    script:
    """
    megahit \
        -t 8 \
        --no-mercy \
        --min-count 3 \
        --prune-depth 5 \
        --min-contig-len 500 \
        -1 ${reads[0]} -2 ${reads[1]} \
        -o ${sample_id}_megahit_output

    mv ${sample_id}_megahit_output/final.contigs.fa ${sample_id}_megahit.fasta
    """
}