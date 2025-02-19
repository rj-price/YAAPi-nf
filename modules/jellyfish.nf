process JELLYFISH {
    container 'community.wave.seqera.io/library/genomescope2_jellyfish_gzip:efb795d20a6993c4'
    publishDir "${params.outdir}/${sample_id}/jellyfish", mode: 'copy'
    cpus = 4
    memory = { 6.GB * task.attempt }
    queue = 'medium'
    
    input:
    tuple val(sample_id), path(reads)
    
    output:
    tuple val(sample_id), path("${sample_id}_linear_plot.png")
    tuple val(sample_id), path("${sample_id}_log_plot.png")
    tuple val(sample_id), path("${sample_id}_summary.txt"), emit: summary
    
    script:
    """
    zcat ${reads} | jellyfish count -C -m 21 -s 1G -t 8 -o ${sample_id}.jf /dev/fd/0
    jellyfish histo -t 8 ${sample_id}.jf > ${sample_id}.histo

    genomescope2 --input ${sample_id}.histo --kmer_length 21 --ploidy 2 --max_kmercov 10000 --output . --name_prefix ${sample_id}
    """
}