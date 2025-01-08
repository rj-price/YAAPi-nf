process GFASTATS {
    container 'community.wave.seqera.io/library/gfastats:1.3.7--5ddeb8c027819e41'
    publishDir "${params.outdir}/${sample_id}/gfastats", mode: 'copy'
    cpus = 1
    memory = 1.GB
    queue = 'short'

    input:
    tuple val(sample_id), path(assembly)

    output:
    path "${sample_id}_genome_stats.tsv"
    path "${sample_id}_contig_stats.tsv"

    script:
    """
    gfastats ${assembly} --threads 2 --tabular --nstar-report > ${sample_id}_genome_stats.tsv

    gfastats ${assembly} --threads 2 --tabular --nstar-report --seq-report > ${sample_id}_contig_stats.tsv
    """
}
