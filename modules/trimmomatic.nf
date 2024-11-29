process TRIMMOMATIC {
    tag "Trimmomatic on $sample_id"
    container "quay.io/biocontainers/trimmomatic:0.39--hdfd78af_2"
    publishDir "${params.outdir}/trimmed", mode: 'copy'
    cpus = 4
    memory = 1.GB
    queue = 'medium'

    input:
    tuple val(sample_id), path(reads)

    output:
    tuple val(sample_id), path("*_paired_*.fastq.gz"), emit: trimmed_reads
    path "*_unpaired_*.fastq.gz"

    script:
    """
    trimmomatic PE -phred33 \
        ${reads[0]} ${reads[1]} \
        ${sample_id}_paired_1.fastq.gz ${sample_id}_unpaired_1.fastq.gz \
        ${sample_id}_paired_2.fastq.gz ${sample_id}_unpaired_2.fastq.gz \
        ILLUMINACLIP:TruSeq3-PE.fa:2:30:10 LEADING:3 TRAILING:3 SLIDINGWINDOW:4:20 HEADCROP:10 MINLEN:80
    """
}