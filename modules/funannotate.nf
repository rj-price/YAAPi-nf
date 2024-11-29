process FUNANNOTATE {
    tag "Funannotate on $sample_id"
    container 'nextgenusfs/funannotate:v1.8.17'
    publishDir "${params.outdir}/funannotate", mode: 'copy'
    cpus = 4
    memory = 20.GB
    queue = 'long'
    
    input:
    tuple val(sample_id), path(assembly)
    path busco_db
    
    output:
    tuple val(sample_id), path("${prefix}_sorted.fasta"), emit: sorted_assembly
    tuple val(sample_id), path("${prefix}_masked.fasta"), emit: masked_assembly
    tuple val(sample_id), path("${prefix}"), emit: annotations

    script:
    prefix = assembly.baseName
    """
    # Clean
    funannotate clean -i ${assembly} -o "${prefix}_clean.fasta"

    # Sort
    funannotate sort -i "${prefix}_clean.fasta" -o "${prefix}_sorted.fasta" -b contig --minlen 500

    # Mask
    funannotate mask -i "${prefix}_sorted.fasta" -o "${prefix}_masked.fasta"

    # Predict
    funannotate predict -i "${prefix}_masked.fasta" -o ${prefix} -s "${prefix}" --cpus ${task.cpus} \
        --augustus_species yeast --busco_seed_species saccharomyces
    """
}