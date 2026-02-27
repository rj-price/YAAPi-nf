process INTERPROSCAN {
    tag "InterProScan on $sample_id"
    container 'community.wave.seqera.io/library/interproscan:5.59_91.0--6053fb17325942d2'

    input:
    tuple val(sample_id), path(proteins)

    output:
    path "*.tsv", emit: tsv
    path "*.xml", emit: xml
    path "versions.yml", emit: versions

    script:
    """
    interproscan.sh \\
        -i \$(readlink -f ${proteins}) \\
        -f tsv,xml \\
        -cpu ${task.cpus} \\
        --goterms \\
        --disable-precalc \\
        --tempdir .

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        interproscan: \$(interproscan.sh -version | grep "version" | sed 's/InterProScan //')
    END_VERSIONS
    """
}
