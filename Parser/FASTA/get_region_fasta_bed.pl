#!/usr/bin/perl

use strict;
use warnings;

my $usage = "$0 fasta_file bed_file\n";

my $fasta_file = shift or die $usage;
my $bed_file = shift or die $usage;


open FASTA, $fasta_file or die "Cannot open $fasta_file\n";
open BED, $bed_file or die "Cannot open $bed_file\n";

my %seq = ();
my $id = "";

print STDERR "start reading fasta file\n";

### Get genome sequence
while( <FASTA> ) {
	chomp;

	if (substr($_, 0, 1) eq ">") {
		$id = substr($_, 1);
		$id =~ s/ .*//g;
		print STDERR "$id\n";
		$seq{$id} = "";
	}
	else {
		$seq{$id} .= $_;
	}
}


while( <BED> ) {
	chomp;

	my @a = split(/\s+/, $_);

	my $reglen = $a[2] - $a[1] + 1;
	my $regseq = substr($seq{$a[0]}, $a[1] - 1, $reglen);
	
	#if($a[3] eq "-") {
	#	$regseq = revcomp($regseq);
	#}

	print ">" . $a[0] . " | " . $a[1] . " | " . $a[2] . "\n$regseq\n";
	#print $a[0] . "\t" . $a[1] . "\t" . $a[2] . "\t$regseq\n";
}

exit(0);

sub revcomp {
	my ($seq) = @_;

	my $newseq = reverse $seq;
	$newseq =~ tr/ACTGactgMRVHmrvhKYBDkybd/TGACtgacKYBDkybdMRVHmrvh/;

	return $newseq;
}

