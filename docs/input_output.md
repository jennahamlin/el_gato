# Input and Output
* [Input and Output](docs/input_output.md)
  * [Input files](#input-files)
     * [Paired-end reads](#pair-end-reads)
     * [Genome assemblies](#genome-assemblies)      
  * [Output files](docs/input_output.md/output-files)
     * [standard out](docs/input_output.md/standard-out)
     * [possible_mlsts.txt](docs/input_output.md/possible_mlststxt)
     * [intermediate_outputs.txt](docs/input_output.md/intermediate_outputstxt)
     * [identified_alleles.fna](docs/input_output.md/identified_allelesfna)
     * [run.log](docs/input_output.md/runlog)
     * [reads_vs_all_ref_filt_sorted.bam](docs/input_output.md/reads_vs_all_ref_filt_sortedbam-reads-only)
     * [report.json](docs/input_output.md/reportjson)
     
## Input files

If available, we recommend using raw or trimmed reads instead of assemblies, as the extra data contained in reads is valuable for the process used by el_gato to identify sample ST. When run with reads, el_gato can use read quality and coverage information to apply quality control rules. When run using assemblies, el_gato cannot identify errors incorporated into the assembly and may report incorrect results. For example, while many isolates encode two copies of mompS, in some cases, the assembly includes only one copy of the locus. If the assembly consists of only the secondary mompS locus, el_gato will report that allele.

#### Pair-end reads
When running on a directory of reads, files are associated as pairs using the pattern `R{1,2}.fastq`. i.e., filenames should be identical except for containing either "R1" or "R2" and can be .fastq or .fastq.gz format. el_gato will not process any files for which it cannot identify a pair using this pattern.

#### Genome assemblies
When running on a directory of assemblies, el_gato will process all files in the target directory, and no filename restrictions exist.

## Output files
After a run, el_gato will print the identified ST of your sample to your terminal ([stdout](#standard-out)) and write several files to the specified output directory (default: out/). el_gato creates a subdirectory for each processed sample, including five output files with specific information.

### The files included in the output directory for a sample are: 

### standard out
ST profile is written as a tab-delimited table without the headings. Headings are included if el_gato.py is run with `-e` flag and are displayed like so:

`Sample  ST flaA  pilE  asd   mip   mompS proA  neuA_neuAH`    

 The sample column contains the user-provided or inferred sample name. The ST column contains the overall sequence type of the sample. 

The ST column can contain two kinds of values. If the identified ST corresponds to a profile found in the database, the corresponding number is given. If no matching ST profile is found or el_gato was unable to make a confident call, then this will be reflected in the value displayed in the ST column.

The corresponding allele number is reported for each gene if an exact allele match is found in the database. Alternatively, el_gato may also note the following symbols:

| Symbol | Meaning |
|:------:|:---------|
|Novel ST    | Novel Sequence Type: All 7 target genes were found, but not present in the profile - most likely a novel sequence type. |
|Novel ST*    | Novel Sequence Type due to novel allele: One or multiple target genes have a novel allele found. |
|MD-     | Missing Data: ST is  unidentifiable as a result of or more of the target genes that are unidentifiable.  |
|MA?     | Multiple Alleles: ST is ambiguous due to multiple alleles that could not be resolved. |
| NAT    | Novel Allele Type: BLAST cannot find an exact allele match - most likely a new allele. |
| -      | Missing Data: Both percent and length identities are too low to return a match or N's in sequence. |
| ?      | Multiple Alleles: More than one allele was found and could not be resolved. |

If symbols are present in the ST profile, the other output files produced by el_gato will provide additional information to understand what is being communicated.

### possible_mlsts.txt
This file would contain all possible ST profiles if el_gato identified multiple possible alleles for any ST loci. In addition, if multiple *mompS* alleles were found, the information used to determine the primary allele is reported in two columns: "mompS_reads_support" and "mompS_reads_against." mompS_reads_support indicates the number of reads associated with each allele that contains the reverse sequencing primer in the expected orientation, which suggests that this is the primary allele. mompS_reads_against indicates the number of reads containing the reverse sequencing primer in the wrong orientation and thus demonstrates that this is the secondary allele. These values are used to infer which allele is the primary *mompS* allele, and their values can be considered to represent the confidence of this characterization. [See Approach subsection for more details](#reads).

### intermediate_outputs.txt
el_gato calls other programs to perform intermediate analyses. The outputs of those programs are provided in this file. In addition, to help with troubleshooting issues, important log messages are also written in this file. The following information may be contained in this file, depending on if the input is reads or assembly:

* Reads-only - Samtools coverage command output. [See samtools coverage documentation for more information about headers](https://www.htslib.org/doc/samtools-coverage.html) or [below.](#samtools-coverage-headers)
* Reads-only - Information about the orientation of *mompS* sequencing primer in reads mapping to biallelic sites. [See Approach subsection for more details](#reads).
* BLAST output indicating the best match for identified alleles. [See BLAST output documentation for more information about headers](https://www.ncbi.nlm.nih.gov/books/NBK279684/table/appendices.T.options_common_to_all_blast/) or [below.](#blastn-output-headers)

Headers are included in outputs for the samtools coverage command and blast results. Header definitions are as follows:

#### samtools coverage headers

| Column header | Meaning 
|:-------------:|:---------------------------------------------------:|
| rname         | Locus name                                          |
| numreads      | Number reads aligned to the region (after filtering)|
| covbases      | Number of covered bases with depth >= 10             |
| coverage      | Percentage of covered bases [0..100]                |
| meandepth     | Mean depth of coverage                              |
| meanbaseq     | Mean baseQ in covered region                        |
| meanmapq      | Mean mapQ of selected reads                         | 

### BLASTn output headers

| Column header | Meaning                             |
|:-------------:|:-----------------------------------:|
| qseqid        | Query sequence id                   |
| sseqid        | Subject (matched allele) id         |
| pident        | Percentage of identical matches     |
| length        | Alignment length (sequence overlap) |
| mismatch      | Number of mismatches                |
| gapopen       | Mumber of gap openings              |
| qstart        | Start of alignment in query         |
| qend          | End of alignment in query           |
| sstart        | Start of alignment in subject       |
| send          | End of alignment in subject         |
| evalue        | Expect value                        |
| bitscore      | Bit score                           |
| qlen          | Query sequence length               |
| slen          | Subject sequence length             |


### identified_alleles.fna
The nucleotide sequence of all identified alleles is written in this file. If more than one allele is determined for the same locus, they are numbered arbitrarily. Fasta headers of sequences in this file correspond to the query IDs in the BLAST output reported in the intermediate_outputs.txt file.

### run.log
A detailed log of the steps taken during el_gato's running includes the outputs of any programs called by el_gato and any errors encountered. Some command outputs include headers (e.g., samtools coverage and BLAST).

### reads_vs_all_ref_filt_sorted.bam (reads only)
el_gato maps the provided reads to [a set of reference sequences in the el_gato db directory](https://github.com/appliedbinf/el_gato/blob/main/el_gato/db/ref_gene_regions.fna). The mapped reads are then used to extract the sequences present in the sample for identifying the alleles and, ultimately, the ST. reads_vs_all_ref_filt_sorted.bam and its associated file reads_vs_all_ref_filt_sorted.bai contains the mapping information that was used by el_gato. The BAM file can be viewed using software such as [IGV](https://software.broadinstitute.org/software/igv/) to understand better the data used by el_gato to make allele calls. Additionally, this file is a good starting point for investigating the cause of incorrectly resolved loci.

**Note:** A SAM file is also present, which has the same information as in the BAM file.

### report-json
Each sample outputs a json file that contains relevant information about the run that will be included in the report PDF.   

Summary page metadata: Complete MLST profile of the sample and the abbreviation key for the symbols.  

Run-specific data:  

Paired-end reads: Locus coverage information and *mompS* primer information.  

Assembly: BLAST hit length and sequence identity thresholds and locus location information.  
