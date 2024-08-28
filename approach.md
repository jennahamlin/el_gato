# Approach

At its core, el_gato uses BLAST to identify the closest match to each allele in your input data. For the loci *flaA*, *pilE*, *asd*, *mip*, and *proA*, this process is straight forward. Whereas loci *mompS* and *neuA/neuAh* require more involved processing, neuA/neuAh being an issue only when processing reads—the specifics of these loci are discussed in the corresponding sections below. 


First for the simple loci (*flaA*, *pilE*, *asd*, *mip*, and *proA*), the following processes are used:

## Reads

When processing reads, identification of both *mompS* and *neuA*/*neuAh* requires additional analyses (described below). The other five loci are processed by mapping the provided reads to reference loci from *L. pneumophila* strain Paris and identifying the consensus sequence. Then, all alleles are determined using BLAST against the SBT allele database.

A couple of quality control steps are applied when processing the reads:

   1. **Base quality:** Any bases with quality scores below 20 are not included when calculating coverage at each position or identifying alternate base calls. The lowest number of bases with quality over 20 that map to a single position is reported in the log for each locus [add exact name of the identifier].
   2. **Coverage:** After excluding low-quality bases, if there is not at least one read covering 100% of the locus (<99% for *neuA*/*neuAh* - see below), then no attempt to identify the allele is made, and a "-" will be reported. A minimum depth of 10 is applied as a cutoff. 

### *neuA/neuAh*

[The sequence of *neuA*/*neuAh* loci can differ dramatically.](https://doi.org/10.1111/1469-0691.12459) The differences in sequence between *neuA*/*neuAh* alleles are sufficient that reads from some alleles will not map to others. Accordingly, we map reads to [X number of] reference sequences that cover the sequence variation currently represented in the SBT database. The [X number of] reference alleles used are the *neuA* allele from strain Paris (neuA_1), the *neuAh* allele from strain Dallas-1E (neuA_201), and [description of other reference sequences]. The reference sequence with the best mapping [what defines best? Is it the number of reads?] is identified using `samtools coverage` with the caveat that >99% of the *neuA*/*neuAh* locus must have coverage of at least one read (some alleles contain small indels, so 100% is too strict); otherwise a "-" will be reported. Once the reference sequence is selected, the BLAST processing is the same as described above.

### *mompS*

[As described in the assembly section](#assembly), *mompS* is sometimes present in multiple copies in the genome of *L. pneumophila* isolates though, it is typically two copies. Duplicate gene copies pose an obvious challenge for a read-mapping approach: if two similar sequence copies are present in a genome, reads from both copies may map to the same reference sequence.

el_gato resolves this issue by taking advantage of the proximity of the genome's two copies of *mompS* [(a schematic of the organization of the two *mompS* copies can be found in Fig. 1 in this paper).](https://doi.org/10.1016/j.cmi.2017.01.002). The sequence context of the two *mompS* copies is such that the correct copy is immediately upstream of the incorrect copy. Only the right copy is flanked on either side by sequences corresponding to primers (*mompS*-450F and *mompS*-1116R) used for conventional SBT. In contrast, while *mompS*-450F sequences are present upstream of the incorrect copy, the corresponding *mompS*-1116R sequences are not found downstream. For this reason, only the correct copy is amplified in conventional SBT [(See below schematic.)](#momps-read-mapping-schematic)

The sequence of the two copies of *mompS* and the identity of the correct allele is then resolved through the following process:

1. Reads from both *mompS* copies are mapped to a single *mompS* reference sequence flanked by the *mompS*-450F and *mompS*-1116R primer sequences. 

2. The nucleotide sequence of reads is recorded for each position within the *mompS* sequence. If the base at a particular position is heterogeneous in more than 30% of reads mapped to that position, the position is considered biallelic, and both bases are recorded. If the sequence contains only one copy of *mompS* or no sequence variation between the duplicate copies, no biallelic sites will be found. Then, the sequence will be extracted, and an allele can be identified using BLAST. 

3. If multiple biallelic positions are identified, all sequences are recorded, and individual read pairs are identified that map to each of the biallelic position(s). 

4. Once the two alleles have been resolved, the correct allele for SBT is identified by analyzing the reads associated with each allele. Reads from each allele are searched for the *mompS*-1116R sequence. The orientation of the reads that contain the primer sequence is assessed. If the primer maps 3'-5' relative to the reference sequence (i.e., in the reverse direction), this is consistent with the read pair originating from the correct copy of *mompS*. However, if the read containing the primer maps 5'-3' (i.e., in the forward direction) relative to *mompS*, this is consistent with the read pair originating from the wrong copy of *mompS*. 

5. The number of reads associated with each allele that contains the primer in the correct orientation relative to *mompS* is counted and compared. The correct allele is then chosen using the following criteria:  

   a. Only one allele has associated reads with primer *mompS*-1116R correctly oriented.  

   b. One allele has more than three times as many reads with correctly oriented primer as the other.  

   c. One allele has no associated reads with the primer *mompS*-1116R in either orientation, but the other allele has associated reads with the primer in only the wrong orientation. In this case, the allele with no associated reads with the primer in either orientation is considered the primary locus by the process of elimination.

6. The number associated with a particular allele variant is then determined using BLAST, and the ST is generated using the identified alleles for the seven genes. 

Note that as the above process depends upon read pairs mapping to biallelic sites and the primer region, sequence data characteristics such as read length and insert size can impact the ability of el_gato to determine *mompS* alleles. 

If the above process cannot identify the correct sequence, a ? will be returned as the *mompS* allele, and el_gato will report information about the steps in this process in the [output files](#output-files).

## *momps* Read Mapping Schematic
![mompS read mapping schematic](https://github.com/appliedbinf/el_gato/blob/images/images/mompS_allele_assignment.png)

## Assembly

Six of the seven loci (*flaA*, *pilE*, *asd*, *mip*,*proA*, and *neuA/neuAh*) are identified using BLAST. For each, the best BLAST result is returned as the allele. The closest match is returned with an \* if loci have no exact match. Only *mompS* requires extra when processing an assembly.

### *mompS*

[*mompS* is sometimes present in multiple copies in *Legionella pneumophila*, though typically two copies.](https://doi.org/10.1016/j.cmi.2017.01.002) When typing *L. pneumophila* using Sanger sequencing, primers amplify only the correct *mompS* locus. We, therefore, use *in silico* PCR to extract the correct *mompS* locus sequence from the assembly. The primers used for *in silico* PCR are *mompS*-450F (TTGACCATGAGTGGGATTGG) and *mompS*-1116R (TGGATAAATTATCCAGCCGGACTTC) [as described in this protocol](https://doi.org/10.1007/978-1-62703-161-5_6). The *mompS* allele is then identified using BLAST.