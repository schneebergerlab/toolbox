#! /usr/bin/perl
use strict;
use warnings;


my $usage="$0 fastq\n";
open FILE, shift or die $usage;

my $seq = "";
my $flag = 0;

while (<FILE>) {
	if (substr($_, 0, 1) eq "@") {
		print length($seq), "\n" if ($seq ne "");
		$seq = "";
		$flag = 1;
	}
	elsif(substr($_, 0, 1) eq "+") {
		$flag = 0;
	}
	else {
		if ($flag == 1) {
			chomp();
			$seq.=$_;
		}
	}
}
print length($seq), "\n" if ($seq ne "");



