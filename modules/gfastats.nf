process GFASTATS {
    tag "GFAStats on $sample_id"
    container 'community.wave.seqera.io/library/gfastats:1.3.7--5ddeb8c027819e41'

    input:
    tuple val(sample_id), path(assembly)

    output:
    path "${sample_id}_genome_stats.tsv", emit: genome_stats
    path "${sample_id}_contig_stats.tsv", emit: contig_stats
    path "versions.yml"                , emit: versions

    script:
    """
    gfastats ${assembly} --threads ${task.cpus} --tabular --nstar-report > ${sample_id}_genome_stats.tsv

    gfastats ${assembly} --threads ${task.cpus} --tabular --nstar-report --seq-report > ${sample_id}_contig_stats.tsv

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        gfastats: \$(gfastats --version | sed 's/gfastats //')
    END_VERSIONS
    """
}

