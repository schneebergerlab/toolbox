#! /usr/bin/perl
use strict;
use warnings;

my $usage="$0 fasta\n";
my $file = shift or die $usage;

open FILE, $file or die "Cannot open input file\n";

my $seq = "";
my $id = "";

while (<FILE>) {
	if (substr($_, 0, 1) eq ">") {
		print $id, "\t", length($seq), "\n" if ($seq ne "");
		$seq = "";
		my @a = split " ", $_;
		$id = substr($a[0], 1);
	}
	else {
		chomp();
		$seq.=$_;
	}
}
print $id, "\t", length($seq), "\n" if ($seq ne "");



