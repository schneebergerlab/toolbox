#! /usr/bin/perl
use strict;


my $usage = "$0 file kmer\n";

my $fasta = shift or die $usage;
my $KMER = shift or die $usage;

my %KMERCOUNT = ();

## read in fasta file

open FILE, $fasta or die $usage;
my %SEQ = ();
my $seq = "";
my $id = "";

while (<FILE>) {
	if (substr($_, 0, 1) eq ">") {
		my @a = split " ", $_;
		if ($seq ne "") {
			$SEQ{$id} = $seq;
		}
		$id = substr($a[0], 1, length($a[0])-1);
		$seq = "";
	}
	else {
		chomp($_);
		$seq .= $_;
	}
}
if ($seq ne "") {
	$SEQ{$id} = $seq;
}

close FILE;

print STDERR "got fasta FILE\n";

### count kmers

foreach my $chr (sort {$a <=> $b} keys %SEQ) {
	for (my $i = 0; $i < length($SEQ{$chr})-$KMER; $i++) {
		$KMERCOUNT{substr($SEQ{$chr}, $i, $KMER)}++;
	} 
}

print STDERR "counted kmers\n";

### print kmers

open OUT, ">".$fasta.".$KMER-mers" or die "cannot open out file\n";

foreach my $chr (sort {$a <=> $b} keys %SEQ) {
	for (my $i = 0; $i < length($SEQ{$chr})-$KMER; $i++) {
		print OUT $chr, "\t", $i, "\t", $KMERCOUNT{substr($SEQ{$chr}, $i, $KMER)}, "\n";
	}
}

print STDERR "kmer number written\n";

%KMERCOUNT = ();

close OUT;

## annotate kmer counts


open OUT, ">".$fasta.".$KMER-mers.annotate" or die "cannot open out file\n";
open FILE, $fasta.".$KMER-mers" or die "cannot open file\n";

my $cchr = 0;
#my $du = $KMER+1;
#my $dr = $KMER+1;

my $ukmer = 0;
my @UNIQUE = ();

while (my $line = <FILE>) {
	chomp($line);
	my @a = split " ", $line;
	if ($cchr ne $a[0]) {
#		$du = $KMER+1;
#		$dr = $KMER+1;

		@UNIQUE = ();
	}
	unshift @UNIQUE, $a[2];
	
	if (@UNIQUE+0 < $KMER-2) {
		print OUT $line, "\t-\n";
	}
	else {
		if (@UNIQUE+0 < $KMER-2) {
			if ($UNIQUE[$#UNIQUE] > 1) {
				$ukmer--;
			}
			pop @UNIQUE;
		}

		if ($UNIQUE[2] == 1) {
			$ukmer++;
		}

		if ($ukmer == $KMER-2) { 
			print OUT $line, "\tu\n";
		}
		elsif ($ukmer > $KMER-4) {
			print OUT $line, "\tm\n";
		}
		else {
			print OUT $line, "\tr\n";
		}

	}

print join ",", @UNIQUE, "\t$ukmer\n";

	
#	if ($a[2] == 1) {
#		if ($dr <= 3) {
#			print OUT $line, "\tr\n";
#		}
#		elsif ($dr <= $KMER) {
#			print OUT $line, "\tm\n";
#		}
#		else {
#			print OUT $line, "\tu\n";
#		}
#		$dr++;
#		$du=0;
#	}
#	else {
#		if ($du < ($KMER-3)) {
#			print OUT $line, "\tm\n"; 
#		}
#		else {
#			print OUT $line, "\tr\n"; 
#		}
#		$du++;
#		$dr = 0;
#	}

	$cchr = $a[0];
}

























