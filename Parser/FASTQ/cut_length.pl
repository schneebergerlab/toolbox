#! /usr/bin/perl
use strict;
use warnings;



my $usage  = "$0 file\n";
my $file   = shift or die $usage;

open IN, $file or die "Cannot open input file\n";

while( <IN> ) {
	my $h1  = $_;
	my $seq = <IN>;
	my $h2  = <IN>;
	my $qual = <IN>;

	chomp($seq);
	chomp $qual;
	my $print_qual = substr($qual, 0, length($seq));

	print "$h1$seq\n$h2$print_qual\n";
}

close IN;

exit(0);
