#!/usr/bin/perl

use strict;
use warnings;

my $file = shift||die "Usage: $0 fastq-file batch-size\n";
my $size = shift||die "Usage: $0 fastq-file batch-size\n";
#$size = $size*4;

open(IN, "gunzip -c $file|");

my $count = 1;
my $f_c = 0;
open(OUT, ">$f_c\.fastq");
while(<IN>){
	my $l = $_;
	if($l =~ /^\@HWI/){
		if($count % $size == 0){
			close(OUT);
			$f_c++;
			open(OUT, ">$f_c\.fastq");
		}
		$count++;
	}
	print OUT $l;
}
close(IN);
