#! /usr/bin/perl

use strict;

my $usage = "RefFasta Marker\n";
my $fastafile = shift or die $usage;
my $markerfile = shift or die $usage;


my $PRIMER3 = "/projects/dep_coupland/grp_nordstrom/bin/primer3/primer3-2.3.1/src/primer3_core";
my $SEQ_LENGTH = 500; # for primer3 to work on


# Parse chromosome file
my %chromosomes = ();
open FASTA, $fastafile or die "Cannot open $fastafile\n";
my $id = "";
while(<FASTA>) {
        chomp;
        if(substr($_, 0, 1) eq ">") { 
		my @a = split " ";
		$id = substr($a[0], 1); 
	}
        else { $chromosomes{$id} .= $_; }
}
close FASTA;

# Parse marker file and print Bolder-IO file
open IN, $markerfile or die "cannot open $markerfile\n";
open OUT, ">$markerfile.primer3in" or die "cannot open $markerfile.primer3\n";
my $id = 0;
while (<IN>) {
	my ($chr, $target) = split " ";
	
	# print id
	$id++;
	print OUT "PRIMER_SEQUENCE_ID=$id\n";

	# print sequence
	die "cannot find chr identifier $chr in fasta file\n" if not defined ($chromosomes{$chr});
	my $start = max(0, $target - ($SEQ_LENGTH/2));
	my $end = min(length($chromosomes{$chr}), $target + ($SEQ_LENGTH/2));
	my $seq = substr($chromosomes{$chr}, $start, $end);
	print OUT "SEQUENCE_TEMPLATE=$seq\n";
	
	# print target
	print OUT "TARGET=".(($SEQ_LENGTH/2)-2).",".(($SEQ_LENGTH/2)+2)."\n";

	# print primer specific sizes	
	#print OUT "PRIMER_OPT_SIZE=18\n";
	#print OUT "PRIMER_MIN_SIZE=15\n";
	#print OUT "PRIMER_MAX_SIZE=21\n";
	#print OUT "PRIMER_NUM_NS_ACCEPTED=1\n";
	#print OUT "PRIMER_PRODUCT_SIZE_RANGE=100-200\n";
	#print OUT "PRIMER_FILE_FLAG=1\n";
	#print OUT "PRIMER_PICK_INTERNAL_OLIGO=1\n";
	#print OUT "PRIMER_EXPLAIN_FLAG=1\n";
	print OUT "=\n";

}
close OUT;
close IN;

#my $cmd = "$PRIMER3 -io_version=3 -format_output -output $markerfile.primer3out < $markerfile.primer3in";
my $cmd = "$PRIMER3 -io_version=3 -output $markerfile.primer3out < $markerfile.primer3in";
system($cmd);

#-format_output
#This argument indicates that primer3_core should generate user-oriented (rather than program-oriented) output.

#-io_version=n
#3 or 4

#-output=file_path
#This argument specifies the file where the output should be written. If omitted, stdout is used.



# Run primer3
# /soft/bin/primer3_core -io_version=3 PCR_sequences.txt > primer3_output.txt




sub max {
	my ($a, $b) = @_;
	return $a if $a > $b;
	return $b;
}

sub min {
        my ($a, $b) = @_;
        return $a if $a < $b;
        return $b;
}





