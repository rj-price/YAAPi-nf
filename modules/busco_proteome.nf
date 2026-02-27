process BUSCO_PROTEOME {
    tag "BUSCO (proteome) on $sample_id"
    container 'community.wave.seqera.io/library/busco:5.2.2--b38cf04af6adc85b'

    input:
    tuple val(sample_id), path(proteins)
    path busco_db

    output:
    path "busco_proteome/*", emit: busco_dir
    path "busco_proteome/short_summary.*.txt", emit: summary
    path "versions.yml", emit: versions

    script:
    def lineage = params.busco_lineage ?: 'fungi_odb10'
    """
    busco \\
        -c ${task.cpus} \\
        -i ${proteins} \\
        -o busco_proteome \\
        -m proteome \\
        -l ${lineage}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        busco_proteome: \$(busco --version 2>&1 | sed 's/BUSCO //')
    END_VERSIONS
    """
}
