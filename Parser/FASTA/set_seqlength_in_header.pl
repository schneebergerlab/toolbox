#! /usr/bin/perl
use strict;
use warnings;



### User params
my $contig_file = shift;
my $min_length  = shift;

my $id = -1;
my %ctg_seq = ();

open CONTIG, $contig_file or die "Cannot open $contig_file\n";

while(<CONTIG>) {
	chomp($_);

	if (substr($_, 0, 1) eq ">") {
		$id = substr($_, 1);
	}
	else {
		$ctg_seq{$id} .= $_;
	}
}
close CONTIG;

### Print validated contigs
foreach my $id (sort keys %ctg_seq) {
	my $len = length($ctg_seq{$id});

	if($len >= $min_length) {
		print ">$id | $len\n" . $ctg_seq{$id} . "\n";
	}
}

exit(0);
