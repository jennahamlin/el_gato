# Using NextFlow 
## Using NextFlow with Singularity Container

We provide a singularity container that can be run using the nextflow workflow for el_gato on a directory of either reads or assemblies. In both cases, the target directory must contain only paired reads files (in .fastq or .fastq.gz format) or assembly files (in fasta format).

```
# Reads
nextflow run_el_gato.nf --reads_dir <path/to/reads/directory> --threads <threads> --out <path/to/output/directory> -profile singularity -c nextflow.config

# Assemblies
nextflow run_el_gato.nf --assembly_dir <path/to/assemblies/directory> --threads <threads> --out <path/to/output/directory> -profile singularity -c nextflow.config
```

**Note:** To run nextflow without the singularity container, uncomment the conda environment installation on line 10 and line 47 of the run_el_gato.nf file and use the following commands:

```
# Reads
nextflow run_el_gato.nf --reads_dir <path/to/reads/directory> --threads <threads> --out <path/to/output/directory>

# Assemblies
nextflow run_el_gato.nf --assembly_dir <path/to/assemblies/directory> --threads <threads> --out <path/to/output/directory>
```
## Output files for Nextflow
After a run, the specified output directory (default: el_gato_out/) will contain a file named "all_mlst.txt" (the MLST profile of each sample) and one directory for each sample processed. Each sub-directory is named with a sample name and contains output files specific to that sample. These files include the el_gato log file and files providing more details about the sequences identified in the sample.  

Additionally, the specified output directory will contain a combined JSON file (report.json) containing all of the data from the individual sample-level JSON files and the report PDF (report.pdf).