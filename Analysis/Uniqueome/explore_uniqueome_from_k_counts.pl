#! /usr/bin/perl
use strict;


my $usage = "$0 file kmer\n";

my $file = shift or die $usage;
my $KMER = shift or die $usage;

my %KMERCOUNT = ();

open OUT, ">".$file.".$KMER-mers.reannotate" or die "cannot open out file\n";
open FILE, $file or die "cannot open file\n";

my $cchr = 0;
#my $du = $KMER+1;
#my $dr = $KMER+1;

my $ukmer = 0;
my @UNIQUE = ();

while (my $line = <FILE>) {
	chomp($line);
	my @a = split " ", $line;
	if ($cchr ne $a[0]) {
		@UNIQUE = ();
		$ukmer=0;
	}
	unshift @UNIQUE, $a[2];
	if ($UNIQUE[2] == 1) {
       		$ukmer++;
        }
	
	if (@UNIQUE+0 < $KMER-2) {
		print OUT "$a[0]\t$a[1]\t$a[2]\t-\n";
	}
	else {
		if (@UNIQUE+0 > $KMER-2) {
			if ($UNIQUE[$#UNIQUE] == 1) {
				$ukmer--;
			}
			pop @UNIQUE;
		}

		if ($ukmer == $KMER-4) {
			print OUT "$a[0]\t$a[1]\t$a[2]\tu\n";
		}
		elsif ($ukmer > $KMER-8) {
			print OUT "$a[0]\t$a[1]\t$a[2]\tm\n";
		}
		else {
			print OUT "$a[0]\t$a[1]\t$a[2]\tr\n";
		}
	}

#print join ",", @UNIQUE, "\t$ukmer\n";
	
	$cchr = $a[0];
}

























