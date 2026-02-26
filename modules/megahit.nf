process MEGAHIT {
    tag "MEGAHIT on $sample_id"
    container 'quay.io/biocontainers/megahit:1.2.9--h43eeafb_5'

    input:
    tuple val(sample_id), path(reads)

    output:
    tuple val(sample_id), path("${sample_id}_megahit.fasta"), emit: scaffolds
    path "versions.yml"                                    , emit: versions

    script:
    """
    megahit \\
        -t ${task.cpus} \\
        --no-mercy \\
        --min-count 3 \\
        --prune-depth 5 \\
        --min-contig-len 500 \\
        -1 ${reads[0]} -2 ${reads[1]} \\
        -o ${sample_id}_megahit_output

    mv ${sample_id}_megahit_output/final.contigs.fa ${sample_id}_megahit.fasta

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        megahit: \$(megahit --version 2>&1 | sed 's/MEGAHIT v//')
    END_VERSIONS
    """
}