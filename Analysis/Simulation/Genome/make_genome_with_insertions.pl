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
#  Module: Simulation::Polymorphic_genome::make_genome_with_insertions.pl
#  Purpose:
#  In:
#  Out:
#


my $usage = "\n$0 reffasta\n\n";

my $file = shift or die $usage;

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


my %num_dels = ();
$num_dels{1} = 10000;
$num_dels{11} =  5000;
$num_dels{21} =  5000;
$num_dels{51} =  1000;
$num_dels{101} =  1000;
$num_dels{201} =  1000;
my %sizes = ();
$sizes{1} = 10;
$sizes{11} = 20;
$sizes{21} = 50;
$sizes{51} = 100;
$sizes{101} = 200;
$sizes{201} = 1000;

open OUT, "> simulated_insertions.txt";

my $len = length($chrseq);
my %DEL = ();

foreach my $min (sort {$a <=> $b} keys %sizes) {
	print STDERR $min, "\t", $sizes{$min}, "\n";
	for (my $k = 0; $k < $num_dels{$min}; $k++) {
		my $max = $sizes{$min};
		my $range = $max - $min + 1;
		my $dellen = int(rand($range)) + $min;

		# place deletion where no other deletion was before
		# if genomeseq is short this wont terminate!
		my $set = 0;
		my $loc = 0;
		while ($set == 0) {
			$set = 1;
			$loc = int(rand($len-$dellen)) + 1;
			for (my $i = $loc; $i <= $loc+1; $i++) {
				if (defined($DEL{$i})) {
					$set = 0;
				}
			}
		}

		# set parts as inserted 
		print OUT $id, "\t", $loc, "\t", $loc+1, "\t", $dellen, "\n";
		#print STDERR $id, "\t", $loc, "\t", $loc+1, "\t", $dellen, "\n";

		$DEL{$loc} = $dellen;
		$DEL{$loc+1} = -1;

	}
}

close OUT;
open OUT, "> simulated_genome_insertions.fa";
print OUT ">", $id, "\n";
my $count = 0;
for (my $i = 1; $i <= length($chrseq); $i++) {
	print OUT substr($chrseq, $i-1, 1);
	$count++;
        if ($count%79 == 0) {
	        print OUT "\n";
        }
	if (defined($DEL{$i})) { 
		if ($DEL{$i} != -1) {
			my $randseq = get_rand_seq($DEL{$i});
			for (my $s = 0; $s < length($randseq); $s++) {
				print OUT substr($randseq, $s, 1);	
				$count++;
				if ($count%79 == 0) {
					print OUT "\n";
				}
			}
		}
	}	
}
print OUT "\n";



sub get_rand_seq {
	my ($len) = @_;

	my $rs = "";
	
	for (my $i = 0; $i < $len; $i++) {
		$rs .= get_rand_nuc();
	}
	
	return $rs;
}

sub get_rand_nuc {
	
	my @nu = ("A", "C", "G", "T");
	my $t = int(rand(4));

	return $nu[$t];
}



