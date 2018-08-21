#! /usr/bin/perl
use strict;
use warnings;


my $usage = "$0 fastafile\n";

my $in = shift or die $usage;

open IN, $in or die $usage;

my $seq = "";
my $id  = "";

while (my $line = <IN>) {
	chomp($line);

	if (substr($line, 0, 1) eq ">") {

		if ($seq ne "") {
			print "$id\n$seq\n";
		}
		$seq = "";
		$id = $line;
	}
	else {
		$seq .= $line;
	}
}

if ($seq ne "") {
	print "$id\n$seq\n";
}

	

