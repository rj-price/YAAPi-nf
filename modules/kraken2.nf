process KRAKEN2 {
    container 'community.wave.seqera.io/library/kraken2:2.1.3--de40043c074a5c69'
    publishDir "${params.outdir}/${sample_id}/kraken2", mode: 'copy'
    cpus = 2
    memory = { 18.GB * task.attempt }
    queue = 'medium'

    input:
    tuple val(sample_id), path(assembly)
    path kraken2_db

    output:
    path "${sample_id}_kraken2_report.txt", emit: report
    path "${sample_id}_kraken2_output.txt", emit: classifications

    script:
    """   
    kraken2 --db ${kraken2_db} \
        --threads 4 \
        --use-names \
        --output ${sample_id}_kraken2_output.txt \
        --report ${sample_id}_kraken2_report.txt \
        ${assembly}
    """
}