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
#  Module: Simulation::Polymorphic_genome::make_random_genome_with_rep_deletions.pl
#  Purpose:
#  In:
#  Out:
#


#################################################################################
# For the repetitive genome:
my $genome_length = 1000000;
my $te_length = 1000;
my $spacer = 200;

my $genome_seq = get_rand_seq($genome_length);
my %genome_changed = ();

my $num_TEs = 10;
my $num_insertions = 5; # insertions per te


#################################################################################
# For the deletions within the genome:
my %te_loc = ();
my %del_loc = ();
my $num_deletions = 10;


#################################################################################
# File handling
open REF, "> reference_seq.txt";
open POLY, "> sample_seq.txt";
open STAT, "> te_locations.txt";
open DEL, "> deletion_locations.txt";


#################################################################################
# This will create the genome with TE insertions
for (my $te = 0; $te < $num_TEs; $te++) {
	my $te_seq = get_rand_seq($te_length);
	print "################\n";
	print $te_seq, "\n";	

	for (my $inst = 0; $inst < $num_insertions; $inst++) {
		my $insert_pos = get_insert_pos();

		my $genome_seq_tmp = $genome_seq;
		$genome_seq = substr($genome_seq_tmp, 0, $insert_pos).$te_seq.substr($genome_seq_tmp, $insert_pos+$te_length, $genome_length-($insert_pos+$te_length));
	
		$te_loc{$insert_pos} = $insert_pos + $te_length;	
	}
}

# print
my $print_genome_seq = get_print_seq("reference", $genome_seq);
print REF $print_genome_seq, "\n";

foreach my $loc (sort {$a <=> $b} keys %te_loc) {
	print STAT $loc, "\t", $te_loc{$loc}, "\n";
}

print STDERR "FINISHED genome\n";

#################################################################################
# Insert deletions for a polymorphic sample
my @keys = keys(%te_loc);
my %taken = ();
for (my $del; $del < $num_deletions; $del++) {
	# select TE to be partially deleted
	my $selected = -1;
	while ($selected == -1) {
		$selected = int(rand(keys(%te_loc)));
		if (defined($taken{$selected})) {
			$selected = -1;
		}
		else {
			$taken{$selected} = 1;
		}
	}

	# select which end of the te should be deleted
	my $end = int(rand(2));	

	# insert deletion flags in sequence
	my $start;
	my $end;
	if ($end == 0) { # set deletion to begining of TE
		$start = $keys[$selected];
		$end = $start + ($te_length/2);
	}
	else { # set deletion to the end of TE
		$end = $te_loc{$keys[$selected]};
		$start = $end - ($te_length/2);
	}

	for (my $i = $start; $i <= $end; $i++) {
		substr($genome_seq, $i, 1) = "D";
	}

	$del_loc{$start} = $end;

}

# print
my $print_sample_seq = get_print_seq("polymorphic sample", $genome_seq);
print POLY $print_sample_seq, "\n";

foreach my $loc (sort {$a <=> $b} keys %del_loc) {
        print DEL $loc, "\t", $del_loc{$loc}, "\n";
}


exit(0);






sub get_print_seq {
	my ($header, $seq) = @_;
	my $print_seq =  ">1 $header\n";
	my $count = 0;
	for (my $i  = 0; $i < length($seq); $i++) {
		if (substr($seq, $i, 1) ne "D") {
			$count++;
			$print_seq .= substr($seq, $i, 1);
			$print_seq .= "\n" if $count%60==0;
		}
	}
	
	return $print_seq;
}

# Make sure insertions do not overlap (with space at either end)
sub get_insert_pos {

	my $insert_pos = -1;
	while ($insert_pos == -1) {
		$insert_pos = int(rand($genome_length));
		for (my $i = $insert_pos - $spacer; $i < $insert_pos+$te_length+$spacer; $i++) {
			if (defined($genome_changed{$i})) {
				$insert_pos = -1; 
				$i = -1;
			}
		}
	}

	for (my $i = $insert_pos - $spacer; $i < $insert_pos+$te_length+$spacer; $i++) {
		$genome_changed{$i} = 1;
	}

	return $insert_pos;
}

sub get_rand_seq {
	my ($length) = @_;;
	my $seq = "";

	for (my $i = 0; $i < $length; $i++) {
		my $q = int(rand(4));
		$seq .= "A" if $q == 0;
		$seq .= "C" if $q == 1;
		$seq .= "G" if $q == 2;
		$seq .= "T" if $q == 3;
	}


	return $seq;
}


