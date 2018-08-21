#! /usr/bin/perl
use strict;
use warnings;




my $usage  = "$0 file prefix\n";
my $file   = shift or die $usage;
my $prefix = shift or die $usage;

open F1, $file or die "Cannot open input read 1 file\n";

open R1, ">$prefix.r1" or die "Cannot open output read 1 file\n";
open R2, ">$prefix.r2" or die "Cannot open output read 2 file\n";

while( <F1> ) {
	my $sh1   = $_;
	my $seq1  = <F1>;
	my $qh1   = <F1>;
	my $qual1 = <F1>;

	my $sh2   = <F1>;
	my $seq2  = <F1>;
	my $qh2   = <F1>;
	my $qual2 = <F1>;

	print R1 "$sh1$seq1$qh1$qual1";
	print R2 "$sh2$seq2$qh2$qual2";
}

close F1;
close R1;
close R2;

exit(0);
