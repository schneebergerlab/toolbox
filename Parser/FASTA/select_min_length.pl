#! /usr/bin/perl
use strict;
use warnings;


my $usage="$0 min_length fasta\n";
my $min_len = shift or die $usage;
my $fasta = shift or die $usage;

open FILE, $fasta or die $usage;

my $seq = "";
my $header = "";

while (<FILE>) {
	if (substr($_, 0, 1) eq ">") {
		if( ($seq ne "") && (length($seq) >= $min_len) ) {
			print $header . $seq . "\n";
		}
		$seq = "";
		$header = $_;
	}
	else {
		chomp();
		$seq.=$_;
	}
}

if( ($seq ne "") && (length($seq) >= $min_len) ) {
	print $header . $seq . "\n";
}



