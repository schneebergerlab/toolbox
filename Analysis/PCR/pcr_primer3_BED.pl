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
#  Module: Analysis::Validation::PCR::pcr_primer3_BED.pl
#  Purpose:
#  In:
#  Out:
#

use DBI;

my $usage = "\n$0 extension BED_file ref_fasta\n\n";
my $extension = shift or die $usage;
my $bed       = shift or die $usage;
my $fasta     = shift or die $usage;

if($extension < 100) { print "Please choose a sequence extension length >= 100 to allow primer3 enough sequence for primer design\n"; exit(0); }

my %refseq  = ();
my $chr = "";


### Read fasta sequence
open FASTA, $fasta or die "Cannot open $fasta\n";
while(<FASTA>) {
	chomp;

	if($_ =~ />/) {
		my @tmp = split(" ", $_);
		$chr = substr($tmp[0], 1);
	}
	else { 
		$refseq{$chr} .= $_; 
	}
}


### Read BED file and write primer3 input
open BED, $bed or die "Cannot open $bed\n";

while(<BED>) {
        chomp;
	my @a = split(/\t/, $_);
	my $chr = $a[0];
	my $beg = $a[1];
	my $end = $a[2];

	my $validation_beg = $beg - $extension;
	my $validation_end = $end + $extension;
	my $target = $end - $beg + 1;
	my $length = $validation_end - $validation_beg + 1;

	my $exclude_start  = $extension - 50;
	my $exclude_length = $target + 100;

	my $seq = substr($refseq{$chr}, $validation_beg - 1, $length);

	print "PRIMER_SEQUENCE_ID=$chr-$validation_beg-$validation_end\n";
	print "SEQUENCE=$seq\n";
	print "TARGET=$exclude_start,$exclude_length\n";
	#print "PRIMER_OPT_SIZE=20\n";
	#print "PRIMER_MIN_SIZE=18\n";
	#print "PRIMER_MAX_SIZE=27\n";
	print "PRIMER_PRODUCT_SIZE_RANGE=100-250\n";
	print "=\n";
}

exit(0);

### PRIMER3 DOC ###

# Primer3 Bolder-IO Format:
#PRIMER_SEQUENCE_ID=example
#SEQUENCE=GTAGTCAGTAGACNATGACNACTGACGATGCAGACNACACACACACACACAGCACACAGGTATTAGTGGGCCATTCGATCCCGACCCAAATCGATAGCTACGATGACG
#TARGET=37,21
#PRIMER_OPT_SIZE=18
#PRIMER_MIN_SIZE=15
#PRIMER_MAX_SIZE=21
#PRIMER_NUM_NS_ACCEPTED=1
#PRIMER_PRODUCT_SIZE_RANGE=75-100
#PRIMER_FILE_FLAG=1
#PRIMER_PICK_INTERNAL_OLIGO=1
#PRIMER_INTERNAL_OLIGO_EXCLUDED_REGION=37,21
#PRIMER_EXPLAIN_FLAG=1
#=

# Run primer3
# /soft/bin/primer3_core -io_version=3 PCR_sequences.txt > primer3_output.txt

# Primer3 Websites:
# http://frodo.wi.mit.edu/primer3/
# http://www.genome.iastate.edu/bioinfo/resources/manuals/primer3intr.html
#
