process FUNANNOTATE {
    tag "Funannotate on $sample_id"
    container 'nextgenusfs/funannotate:v1.8.17'

    input:
    tuple val(sample_id), path(assembly)
    path funannotate_db
    
    output:
    tuple val(sample_id), path("${sample_id}_sorted.fasta"), emit: sorted_assembly
    tuple val(sample_id), path("${sample_id}_masked.fasta"), emit: masked_assembly
    tuple val(sample_id), path("${sample_id}/"),           emit: annotation_dir
    path "versions.yml"                                   , emit: versions

    script:
    """
    # Set FUNANNOTATE_DB environment variable
    export FUNANNOTATE_DB=\$(readlink -f ${funannotate_db})

    # Clean
    funannotate clean -i ${assembly} -o "${sample_id}_clean.fasta"

    # Sort
    funannotate sort -i "${sample_id}_clean.fasta" -o "${sample_id}_sorted.fasta" -b contig --minlen 500

    # Mask
    funannotate mask -i "${sample_id}_sorted.fasta" -o "${sample_id}_masked.fasta"

    # Predict
    funannotate predict \\
        -i "${sample_id}_masked.fasta" \\
        -o ${sample_id} \\
        -s "${sample_id}" \\
        --cpus ${task.cpus} \\
        --augustus_species yeast \\
        --busco_seed_species saccharomyces

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        funannotate: \$(funannotate --version 2>&1 | sed 's/funannotate v//')
    END_VERSIONS
    """
}
