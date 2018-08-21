#! /usr/bin/perl
use strict;
use warnings;



my $usage = "$0 minsize fasta\n";

my $size = shift or die $usage;

open FILE, shift or die $usage;

my $seq = "";
my $id = "";

while (my $line = <FILE>) {

	chomp($line);

	if (substr($line, 0, 1) eq ">") {
		if ($seq ne "" and $size <= length($seq)) {
			print $id, "\n", $seq, "\n";
		}
		$id = $line;
		$seq = "";
	}
	else {
		$seq .= $line;
	}
}

if ($seq ne "" and $size <= length($seq)) {
	print $id, "\n", $seq, "\n";
}
