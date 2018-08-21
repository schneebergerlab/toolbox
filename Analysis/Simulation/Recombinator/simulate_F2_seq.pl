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
#  Module: Analysis::AssociationMapping::Recombinator::simulate_F2_seq.pl
#  Purpose:
#  In:
#  Out:
#


use FindBin;
use lib $FindBin::Bin;
use Genome;

my $usage = "\n$0 num_F2_plants markerfile\n";
my $NUM_F2_PLANTS = shift or die $usage;
my $MARKER_FILE = shift or die $usage;

my $PARENT1 = "Col-0";
my $PARENT2 = "Ler-1";

my %MARKER_P1 = ();
my %MARKER_P2 = ();
get_marker();

my @chr1 = ();
my @chr2 = ();
my @chr3 = ();
my @chr4 = ();
my @chr5 = ();
my @chr1p = ();
my @chr2p = ();
my @chr3p = ();
my @chr4p = ();
my @chr5p = ();

my $NUMBER_OF_MUTANTS = 1;
my $PHENOTYPING_ERROR = 0;

my $num_mutants = 0;

for (my $f2 = 0; $f2 < $NUM_F2_PLANTS; $f2++) {
	print "Plant: ", $f2+1, "\n";

	my $genome = new Genome($PARENT1, $PARENT2);

	#$genome->selfed_F2();
	$genome->backcrossed_F2();
	$genome->recombine();

	my $mutant = $genome->phenotype("Col-0", 4, 16240000, 0, 1);

	if ($mutant == 1) {
		$num_mutants++;

 		#my $genotypes = $genome->get_rough_genotypes();
 		#parse_rough_genotypes($genotypes);

		foreach my $chr (keys %MARKER_P1) {
			foreach my $marker (keys %{$MARKER_P1{$chr}}) {
				my $genotype = $genome->genotype($PARENT1, $chr, $marker);
				$MARKER_P1{$chr}{$marker}+=$genotype;
				$MARKER_P2{$chr}{$marker}+=(2-$genotype);
			}
		}
	}
	
 	#print $genome->get_rough_genotypes();

}
print "Num mutants: ", $num_mutants, "\n";

print_genotyping();

#print "\nNumber of Mutants: ", $num_mutants, "\n";
#print "Chr1:\n";
#print join("-", @chr1), "\n";
#print join("-", @chr1p), "\n";
#print "Chr2:\n";
#print join("-", @chr2), "\n";
#print join("-", @chr2p), "\n";
#print "Chr3:\n";
#print join("-", @chr3), "\n";
#print join("-", @chr3p), "\n";
#print "Chr4:\n";
#print join("-", @chr4), "\n";
#print join("-", @chr4p), "\n";
#print "Chr5:\n";
#print join("-", @chr5), "\n";
#print join("-", @chr5p), "\n";


sub print_genotyping {
	open FILE, "> genotyping.txt";
	foreach my $chr (sort{$a <=> $b} keys %MARKER_P1) {
		foreach my $marker (sort{$a <=> $b} keys %{$MARKER_P1{$chr}}) {
			print FILE $chr, "\t", $marker, "\t", $MARKER_P1{$chr}{$marker}, "\t", $MARKER_P2{$chr}{$marker}, "\n";
		}
	}
	close FILE;
}

sub get_marker {
	open FILE, $MARKER_FILE or die "Cannot find file\n";
	
	while (my $line = <FILE>) {
		my @a = split " ", $line;
		if (exists($MARKER_P1{$a[0]})) {
			$MARKER_P1{$a[0]}{$a[1]} = 0;
		}
		else {
			my %tmp = ();
			$MARKER_P1{$a[0]} = \%tmp;
			$MARKER_P1{$a[0]}{$a[1]} = 0;
		}
		if (exists($MARKER_P2{$a[0]})) {
			$MARKER_P2{$a[0]}{$a[1]} = 0;
		}
		else {
			my %tmp = ();
			$MARKER_P2{$a[0]} = \%tmp;
			$MARKER_P2{$a[0]}{$a[1]} = 0;
		}
	}
	close FILE;
}

sub parse_rough_genotypes {
	my ($str) = @_;

	my @a = split "\n", $str;
	my $chr = 0;

	for (my $l = 0; $l < @a; $l++) {
		if (substr($a[$l], 0, 3) ne "Chr") {
			for (my $i = 0; $i < length($a[$l]); $i++) {
				if ($chr == 1) {
					$chr1[$i]++ if substr($a[$l], $i, 1) eq substr($PARENT1, 0, 1);
					$chr1p[$i]++ if substr($a[$l], $i, 1) eq substr($PARENT2, 0, 1);
				}
				if ($chr == 2) {
                                        $chr2[$i]++ if substr($a[$l], $i, 1) eq substr($PARENT1, 0, 1);
                                        $chr2p[$i]++ if substr($a[$l], $i, 1) eq substr($PARENT2, 0, 1);
                                }
				if ($chr == 3) {
                                        $chr3[$i]++ if substr($a[$l], $i, 1) eq substr($PARENT1, 0, 1);
                                        $chr3p[$i]++ if substr($a[$l], $i, 1) eq substr($PARENT2, 0, 1);
                                }
				if ($chr == 4) {
                                        $chr4[$i]++ if substr($a[$l], $i, 1) eq substr($PARENT1, 0, 1);
                                        $chr4p[$i]++ if substr($a[$l], $i, 1) eq substr($PARENT2, 0, 1);
                                }
				if ($chr == 5) {
                                        $chr5[$i]++ if substr($a[$l], $i, 1) eq substr($PARENT1, 0, 1);
                                        $chr5p[$i]++ if substr($a[$l], $i, 1) eq substr($PARENT2, 0, 1);
                                }
			}
		}
		else {
			$chr++;
		}
	}

}


