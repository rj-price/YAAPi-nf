process BUSCO {
    tag "BUSCO on $sample_id"
    container 'community.wave.seqera.io/library/busco:5.2.2--b38cf04af6adc85b'

    input:
    tuple val(sample_id), path(scaffolds)

    output:
    path "${sample_id}_busco"                                 , emit: busco_dir
    path "${sample_id}_busco/short_summary.*${sample_id}*.txt", emit: summary
    path "versions.yml"                                       , emit: versions

    script:
    // params.busco_lineage defaults to fungi_odb10 if not set
    def lineage = params.busco_lineage ?: 'fungi_odb10'
    """
    busco \\
        -c ${task.cpus} \\
        -i ${scaffolds} \\
        -o ${sample_id}_busco \\
        -m genome \\
        -l ${lineage}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        busco: \$(busco --version 2>&1 | sed 's/BUSCO //')
    END_VERSIONS
    """
}