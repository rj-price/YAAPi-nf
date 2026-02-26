//
// Check input samplesheet and get read channels
//

workflow INPUT_CHECK {
    take:
    samplesheet // file: /path/to/samplesheet.csv

    main:
    ch_input_rows = Channel
        .fromPath(samplesheet, checkIfExists: true)
        .splitCsv(header:true, sep:',')
        .map { row -> validate_row(row) }

    emit:
    reads = ch_input_rows // channel: [ val(sample_id), [ path(fastq_1), path(fastq_2) ] ]
}

def validate_row(LinkedHashMap row) {
    def sample_id = row.sample
    def fastq_1   = file(row.fastq_1, checkIfExists: true)
    def fastq_2   = file(row.fastq_2, checkIfExists: true)

    if (sample_id == null || sample_id == "") {
        error "ERROR: Sample ID is missing in samplesheet."
    }

    return [ sample_id, [ fastq_1, fastq_2 ] ]
}
