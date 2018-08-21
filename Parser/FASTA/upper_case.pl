#! /usr/bin/perl
use strict;
use warnings;


my $usage = "$0 fasta\n";
my $file = shift or die $usage;
open FILE, $file or die $usage;

while (my $line = <FILE>) {
	chomp($line);
	if (substr($line, 0, 1) ne ">") {
		$line = uc($line);
		print $line, "\n";
	}
	else {
		print $line, "\n";
	}
}


