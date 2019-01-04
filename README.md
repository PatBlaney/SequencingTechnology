# Quality Trimmer

The purpose of the program is to create an interleaved FASTQ file using paired Illumina readswithin a user-defined FASTQ file. The interleaved sequences will be the longest subsequence of the read where all quality scores are above a user-defined threshold.

## Running the Program

This program requires the user to define four separate options:
```
-left ~/SampleData/Sample.R1.fastq
```
* The file containing the R1 or left FASTQ reads
```
-right ~/SampleData/Sample.R2.fastq
```
* The file containing the R2 or right FASTQ reads
```
-interleaved Interleaved.fastq
```
* The desired name of the interleaved FASTQ output file
```
-qual 30
```
* The quality thrershold for each nucleotide

If the user fails to properly define any of these options the program will terminate and display an appropriate error message.

