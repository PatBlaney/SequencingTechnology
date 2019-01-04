#!/usr/bin/perl
use warnings;
use strict;

# Create an interleaved FASTQ file from paired Illumina read file using BioPerl.
# The interleaved sequences will be written as the longest subsequences that has
# a user-specified Phred Quality Score.

use Bio::SeqIO;
use Bio::Seq;
use Getopt::Long;
use Pod::Usage;

# Initialize variables that hold the user-specifed options for the program
my $left        = '';
my $right       = '';
my $interleaved = '';
my $qual        = 0;
my $usage       = "\n$0 [options] \n
Options:
	-left				Left FASTQ reads
	-right				Right FASTQ reads
	-interleaved		Filename for interleaved FASTQ output
	-qual				Phred Quality Score minimum
	-help 				Show this message
\n";

# Utilize the GetOptions subroutine from the Getopt::Long module to store the program
# options to accept
GetOptions(
	'left=s'        => \$left,
	'right=s'       => \$right,
	'interleaved=s' => \$interleaved,
	'qual=i'        => \$qual,
	'help'          => sub { pod2usage($usage); },
) or pod2usage($usage);

# Sanity check to make sure all options are passed to the program are valid. Print out
# warning messages for each option that is invalid
unless ( -e $left and -e $right and $interleaved and $qual ) {
	unless ( -e $left ) {
		print "Specify file for left reads\n";
	}

	unless ( -e $right ) {
		print "Specify file for right reads\n";
	}

	unless ($interleaved) {
		print "Specify file for interleaved output\n";
	}

	unless ($qual) {
		print "Specify quality score cutoff\n";
	}

	# End the program if any of the passed options are invalid or missing
	die "Missing requried options\n";
}

# Read the FASTQ file and create an Bio::SeqIO object containing each entry within
# the left reads (Sample.R1) and right reads (Sample.R2)
my $leftReads = Bio::SeqIO->new(
	-file   => "$left",
	-format => 'fastq'
);
my $rightReads = Bio::SeqIO->new(
	-file   => "$right",
	-format => 'fastq'
);

# Open a file to write the interleaved FASTQ sequences who's Phred score is above 20
my $interleavedFile = Bio::SeqIO->new(
	-file   => ">$interleaved",
	-format => 'fastq'
);

# Loop through all the FASTQ sequences in each file one sequence at a time. Write the
# entries in an interleaved fashion with paired sequences from R1 then R2
while (( my $leftSeq = $leftReads->next_seq )
	&& ( my $rightSeq = $rightReads->next_seq ) )
{

# Utlize the subroutine to write the longest subsequence of the R1 and R2 paired reads
# to an interleaved FASTQ file
	fastq_quality_trimmer( $leftSeq,  $interleavedFile );
	fastq_quality_trimmer( $rightSeq, $interleavedFile );
}

# Isolate subsequences with description and write this FASTQ entry to a file
sub fastq_quality_trimmer {

	# Input will be the Bio::Seq::Quality object created from reading FASTQ file
	# containin paired reads and the filename of the output file to write to
	my ( $seq, $filename ) = @_;

	# First isolate the longest subsequence where each base has a Phred score above the
	# user-specified value
	my $qualityReads = $seq->get_clear_range($qual);

	# Recopy the description that was removed when isolating the longest subsequence to
	# the FASTQ sequence
	$qualityReads->desc( $seq->desc() );

	# Write the FASTQ sequence with associated description to the designated interleaved file
	# starting with the R1 read
	$filename->write_seq($qualityReads);

}
