#! /usr/bin/perl
use strict;
use warnings;


my $usage = "$0 fasta\n";
my $file = shift or die $usage;
open FILE, $file or die $usage;

while (my $line = <FILE>) {
	chomp($line);
	if (substr($line, 0, 1) ne ">") {
		for (my $i = 0; $i < length($line); $i++) {
			if (	substr($line, $i, 1) eq "A" or substr($line, $i, 1) eq "C" or substr($line, $i, 1) eq "G" or substr($line, $i, 1) eq "T" or
				substr($line, $i, 1) eq "a" or substr($line, $i, 1) eq "c" or substr($line, $i, 1) eq "g" or substr($line, $i, 1) eq "t"
			) {
				print substr($line, $i, 1);
			}
		}
		print "\n";
	}
	else {
		print $line, "\n";
	}
}


