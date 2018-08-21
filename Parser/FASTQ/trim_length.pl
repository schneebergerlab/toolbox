#! /usr/bin/perl
use strict;
use warnings;




my $usage  = "$0 start end minlength file\n";
my $beg    = shift or die $usage;
my $end    = shift or die $usage;
my $min    = shift or die $usage;
my $file   = shift or die $usage;

open IN, $file or die "Cannot open input file\n";

while( <IN> ) {
	my $h1  = $_;
	my $seq = <IN>;
	my $h2  = <IN>;
	my $qual = <IN>;

	chomp $seq;
	chomp $qual;
	my $print_seq  = substr( $seq, $beg - 1, ($end - $beg + 1) );
	my $print_qual = substr( $qual, $beg - 1, ($end - $beg + 1) );

	if( length($print_seq) >= $min ) {
		print "$h1$print_seq\n$h2$print_qual\n";
	}
}

close IN;

exit(0);
