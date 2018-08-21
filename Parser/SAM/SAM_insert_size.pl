#! /usr/bin/perl
use strict;
use warnings;



my $usage = "\n\nUsage: $0 min max SAMfile\n\n";

my $min = shift or die $usage;
my $max = shift or die $usage;
my $file = shift or die $usage;


open FILE, $file;

while(<FILE>) {
	if(substr($_, 0, 1) eq "@") {
		print $_;
	}
	else {
		my @a = split("\t", $_);

		my $in_range = 0;

		if( abs($a[8]) >= $min && abs($a[8]) <= $max) {
			$in_range = 1;
		}

		if($in_range == 1) {
			print $_;
		}
	}
}

close FILE;

exit(0);
