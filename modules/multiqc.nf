process MULTIQC {
    label 'process_low'
    container 'community.wave.seqera.io/library/multiqc:1.25.1--dc1968330462e945'

    input:
    path '*'

    output:
    path "multiqc_report.html", emit: report
    path "multiqc_data"       , emit: data
    path "versions.yml"       , emit: versions

    script:
    """
    multiqc .

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        multiqc: \$(multiqc --version | sed 's/multiqc, version //')
    END_VERSIONS
    """
}