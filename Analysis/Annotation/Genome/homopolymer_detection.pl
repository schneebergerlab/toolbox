#! /usr/bin/perl
use strict;
use warnings;


my $usage = "$0 min_length fastafile\n";

my $len = shift or die $usage;
my $in  = shift or die $usage;

open IN, $in or die $usage;

my $seq = "";
my $id  = "";
my %genome = ();

while (my $line = <IN>) {
	chomp($line);

	if (substr($line, 0, 1) eq ">") {

		if ($seq ne "") {
			$genome{$id} = $seq;
		}
		$seq = "";
		$id = substr($line, 1);
	}
	else {
		$seq .= $line;
	}
}

if ($seq ne "") {
	$genome{$id} = $seq;
}

### Find homo
foreach my $id_key ( sort keys %genome) {

	$seq=uc($genome{$id_key});

	while ($seq =~ /(A{$len,}|C{$len,}|G{$len,}|T{$len,})/g) {
		my $homopolymer_length = length($1);
		my $beg = length($`);
		my $end = $beg + $homopolymer_length - 1;
		print "$id_key\t$beg\t$end\t$1\n";
	}
}

