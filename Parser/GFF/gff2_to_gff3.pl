#! /usr/bin/perl
use strict;
use warnings;

my $file = shift;

open IN, $file or die "Cannot open input file\n";
my $gene_id = "";

while(<IN>) {
	chomp;

	if( $_ =~ /gene/ ) {
		print "$_\n";
    		my @features = split(/\t/, $_);
		my ($gene_id, $junk) = split(/;/, $features[8]);
		$gene_id =~ s/ID=//;

		print "$features[0]\t$features[1]\tmRNA\t$features[3]\t$features[4]\t$features[5]\t" .
			"$features[6]\t$features[7]\tID=$gene_id.1;Parent=$gene_id\n";
	}
	elsif( $_ =~ /exon/ || $_ =~ /CDS/ ) {
		print "$_.1\n";
	}
	else { print STDERR "$_\n"; }

}

exit(0);
