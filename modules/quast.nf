process QUAST {
    tag "QUAST on $sample_id"
    container 'community.wave.seqera.io/library/quast:5.3.0--755a216045b6dbdd'
    
    input:
    tuple val(sample_id), path(reads)
    tuple val(sample_id), path(assembly)

    output:
    path "quast_out/*"  , emit: results
    path "versions.yml" , emit: versions

    script:
    """
    quast.py \\
        --threads ${task.cpus} \\
        ${assembly} \\
        -1 ${reads[0]} -2 ${reads[1]} \\
        -o quast_out

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        quast: \$(quast.py --version | sed 's/QUAST v//')
    END_VERSIONS
    """
}

