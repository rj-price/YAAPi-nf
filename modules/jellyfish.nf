process JELLYFISH {
    tag "Jellyfish on $sample_id"
    container 'community.wave.seqera.io/library/genomescope2_jellyfish_gzip:efb795d20a6993c4'
    
    input:
    tuple val(sample_id), path(reads)
    
    output:
    tuple val(sample_id), path("${sample_id}_linear_plot.png"), emit: linear_plot
    tuple val(sample_id), path("${sample_id}_log_plot.png")   , emit: log_plot
    path "${sample_id}_summary.txt"                          , emit: summary
    path "versions.yml"                                      , emit: versions
    
    script:
    def kmer_length = params.kmer_length ?: 21
    def ploidy      = params.ploidy      ?: 2
    """
    zcat ${reads} | jellyfish count -C -m ${kmer_length} -s 1G -t ${task.cpus} -o ${sample_id}.jf /dev/fd/0
    jellyfish histo -t ${task.cpus} ${sample_id}.jf > ${sample_id}.histo

    genomescope2 \\
        --input ${sample_id}.histo \\
        --kmer_length ${kmer_length} \\
        --ploidy ${ploidy} \\
        --max_kmercov 10000 \\
        --output . \\
        --name_prefix ${sample_id}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        jellyfish: \$(jellyfish --version | sed 's/jellyfish //')
        genomescope2: \$(genomescope2 --version | sed 's/GenomeScope 2.0 //')
    END_VERSIONS
    """
}