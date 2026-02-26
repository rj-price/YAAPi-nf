process FASTQC {
    tag "FASTQC on $sample_id"
    container "biocontainers/fastqc:v0.11.9_cv8"

    input:
    tuple val(sample_id), path(reads)
    val(stage)

    output:
    path "${stage}/*", emit: fastqc_results
    path "versions.yml", emit: versions

    script:
    """
    mkdir -p ${stage}
    fastqc -q ${reads} --outdir ${stage}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        fastqc: \$(fastqc --version | sed -e "s/FastQC v//g")
    END_VERSIONS
    """
}