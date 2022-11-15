#!/usr/bin/env nextflow
nextflow.enable.dsl=2

params.reads_dir = false

process RUN_EL_GATO_READS {
  
  conda "-c bioconda -c appliedbinf elgato=0.1.0"
  cpus 1

  input:
    tuple val(sampleId), file(reads)

  output:
    stdout

  script:
  
  r1 = reads[0]
  r2 = reads[1]

  """
  el_gato.py \
  -1 $r1 \
  -2 $r2 \
  -o out \
  -t 1 \
  -e -w 2>&1
  """
}

workflow {
  if (params.reads_dir) {

  readPairs = Channel.fromFilePairs(params.reads_dir + "/*R{1,2}*.fastq.gz", checkIfExists: true)

  RUN_EL_GATO_READS(readPairs) | view

  } else {
    print "Please provide the path to a directory containing paired reads using --reads_dir."
  }


}
