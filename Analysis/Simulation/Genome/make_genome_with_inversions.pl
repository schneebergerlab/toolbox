#! /usr/bin/perl
use strict;
use warnings;

###### 
# NGSbox - bioinformatics analysis tools for next generation sequencing data
#
# Copyright 2007-2011 Stephan Ossowski, Korbinian Schneeberger
# 
# NGSbox is free software: you can redistribute it and/or modify it under the 
# terms of the GNU General Public License as published by the Free Software 
# Foundation, either version 3 of the License, or any later version.
#
# NGSbox is distributed in the hope that it will be useful, but WITHOUT ANY 
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS 
# FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# Please find the GNU General Public License at <http://www.gnu.org/licenses/>.
#
#  -------------------------------------------------------------------------
#
#  Module: Simulation::Polymorphic_genome::make_genome_with_inversions.pl
#  Purpose:
#  In:
#  Out:
#


my $usage = "\n$0\n";

my $file = "/ebio/abt6_analysis/nobackup/data/Shore/Plants/ATH/TAIR8_Masked/TAIR8.v1.Masked.fa";
open FILE, $file or die $usage;

my $chrseq = "";
my $id = "";

while (my $line = <FILE>) {
	chomp($line);
	if (substr($line, 0, 1) eq ">") {
		if ($chrseq ne "") {
			last;
		}
		else {
			my @a = split " ", $line;
			$id = substr($a[0], 1, length($a[0])-1);
		}
	}
	else {
		$chrseq .= $line;
	}
}

close FILE;

open OUT, "> simulated_inversions.txt";

my $len = length($chrseq);
my %INV = ();

my $min = 100;
my $max = 500000;

for (my $i = 0; $i < 20; $i++) {
	my $invlen = int(rand($max)) + $min;

	# place inversion where no other deletion was before
	# if genomeseq is short this wont terminate!
	my $set = 0;
	my $loc = 0;
	while ($set == 0) {
		$set = 1;
		$loc = int(rand($len-$invlen)) + 1;
		for (my $i = $loc-100; $i < $loc+$invlen+100; $i++) {
			if (defined($INV{$i})) {
				$set = 0;
			}
		}
	}

	# set parts as deleted 
	print OUT $id, "\t", $loc, "\t", $loc+$invlen-1, "\t", $invlen, "\n";
	for (my $i = $loc-100; $i < $loc+$invlen+100; $i++) {
		$INV{$i} = 1;
	}
	
	my $new_string = substr($chrseq, 0, $loc) . rev_comp(substr($chrseq, $loc, $invlen)) . substr($chrseq, $loc+$invlen, length($chrseq)-($loc+$invlen));
	print STDERR length($chrseq), "\t", length($new_string), "\n";
	$chrseq = $new_string;

}

close OUT;
open OUT, "> simulated_genome_inversions.fa";
print OUT ">", $id, "\n";
my $count = 0;
for (my $i = 1; $i <= length($chrseq); $i++) {
	print OUT substr($chrseq, $i-1, 1);
	$count++;
	if ($count%79 == 0) {
		print OUT "\n";
	}
}
print OUT "\n";

sub rev_comp {
        my ($seq) = @_;
        my $new = reverse($seq);
        $new =~ tr/acgtACGT/tgcaTGCA/;

        return $new;
}





