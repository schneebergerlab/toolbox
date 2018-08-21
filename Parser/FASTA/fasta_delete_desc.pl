#! /usr/bin/perl
use strict;
use warnings;


my $usage = "$0 file\n";
my $file= shift or die $usage;
open FILE, $file or die $usage;

while (my $line = <FILE>) {
	if (substr($line, 0, 1) eq ">") {
		my @a = split " ", $line;
		print $a[0], "\n";
	}
	else {
		print $line;
	}
}

