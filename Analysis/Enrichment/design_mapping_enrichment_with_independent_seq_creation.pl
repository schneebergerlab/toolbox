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
#  Module: Analysis::Enrichment::design_mapping_enrichment_with_independent_seq_creation.pl
#  Purpose:
#  In:
#  Out:
#


my $usage = "$0 refseq marker reference reference variant variant insertion insertion SV1 SV1 SV2 SV2 referror\n";
my $refseq = shift or die $usage;
my $marker = shift or die $usage;

my $reference1 = shift or die $usage;
my $reference2 = shift or die $usage;
my $variant1 = shift or die $usage;
my $variant2 = shift or die $usage;

my $insertion1 = shift or die $usage;
my $insertion2 = shift or die $usage;
my $sv_short1 = shift or die $usage;
my $sv_short2 = shift or die $usage;
my $sv_long1 = shift or die $usage;
my $sv_long2 = shift or die $usage;
my $referror = shift or die $usage;

my %MARKER = ();
my %MARKER_REGION = ();
my %REFSEQ = ();
my %INDSEQ = ();
my %REF1 = ();
my %REF2 = ();
my %VAR1 = ();
my %VAR2 = ();
my %INS = ();
my %SV = ();
my %REFERROR = ();

###############################################
## Read in files
get_refseq(\%REFSEQ, $refseq);
get_refseq(\%INDSEQ, $refseq);
my $num_marker = 0;
get_marker(\%MARKER, $marker);
print STDERR "Got marker\n";
get_insertion(\%INS, $insertion1);
get_insertion(\%INS, $insertion2);
print STDERR "Got insertions\n";
get_sv(\%SV, $sv_short1);
get_sv(\%SV, $sv_short2);
get_sv(\%SV, $sv_long1);
get_sv(\%SV, $sv_long2);
print STDERR "Got SVs\n";
get_referror(\%REFERROR, $referror);
print STDERR "Got referrors\n";

get_qual_file(\%REF1, $reference1, 0);
print STDERR "Got reference 1\n";
get_qual_file(\%REF2, $reference2, 0);
print STDERR "Got reference 2\n";
get_qual_file(\%VAR1, $variant1, 1);
get_qual_file(\%VAR2, $variant2, 1);
print STDERR "Got variants\n";

##############################################
# Print the new sequence

open IND, ">Baits.SecondReference.TAIR8.txt";
foreach my $chr (sort {$a <=>$b} keys %INDSEQ) {
	print IND ">".$chr."\n";
	print IND $INDSEQ{$chr}."\n";
}
close IND;

print STDERR "PREEXIT\n";
exit(1);

##############################################

open BAITS, ">BaitsFile.TAIR8.txt";
open ALL, ">BaitsDesignFile.all.TAIR8.txt";
open DESIGN, ">BaitsDesignFile.TAIR8.txt"; 
open DIST, ">BaitsNeighborDist.TAIR8.txt";

###############################################
# Parse marker and filter:

my $bait_count = 0;
my $bait_lastpos = 0;
my $bait_lastchr = 0;

my %FILTERED_MARKER = ();
my $removed_referror = 0;
my $removed_sv = 0;
my $removed_insertion = 0;
my $removed_deletion = 0;

my $removed_disagree = 0;
my $removed_repetitive = 0;
my $removed_polymorphic = 0;
my $removed_gc_content = 0;
my $removed_dist = 0;
my $removed_unvalid_char = 0;

my $removed_disagree2 = 0;
my $removed_repetitive2 = 0;
my $removed_polymorphic2 = 0;
my $removed_gc_content2 = 0;
my $removed_dist2 = 0;
my $removed_unvalid_char2 = 0;


MARK: foreach my $marker (sort {$a<=>$b}keys %MARKER) {

	my @a = split "#", $marker;
	my $m_chr = int($marker/100000000);
	my $m_pos = $marker%100000000;
	# ref errors
	if (defined($REFERROR{$marker})) {
		$removed_referror++;
		next MARK;
	}
	###########################################
	# Check for severe changes
	for (my $i = $m_pos - 559; $i <= $m_pos + 560; $i++) {
		if (defined($SV{$m_chr."#".$i})) {
			$removed_sv++;
			next MARK;
		}
		if ($i >= $m_pos - 59 and $i <= $m_pos + 60) {
			if (defined($INS{$m_chr."#".$i})) {
				$removed_insertion++;
				next MARK;
			}
			if (defined($VAR1{$m_chr."#".$i})) {
				my @a = split "#", $VAR1{$m_chr."#".$i};
				if ($a[0] eq "-") {
					$removed_deletion++;
					next MARK;
				}
			}
			if (defined($VAR2{$m_chr."#".$i})) {
				my @a = split "#", $VAR2{$m_chr."#".$i};
				if ($a[0] eq "-") {
					$removed_deletion++;
					next MARK;
				}
			}
		}
	}
	###########################################
	# Check bait sequence
	# count
	my $num_calls1 = 0;
	my $num_polymorphic1 = 0;
	my $num_reference1 = 0;
	my $num_uniq1 = 0;

	my $num_calls2 = 0;
	my $num_polymorphic2 = 0;
	my $num_reference2 = 0;
	my $num_uniq2 = 0;
	
	my $num_agree = 0;
	my $num_disagree = 0;
	my $num_gc = 0;

	for (my $i = $m_pos - 59; $i <= $m_pos + 60; $i++) {
		if (substr($REFSEQ{$m_chr}, $i, 1) eq "G" or substr($REFSEQ{$m_chr}, $i, 1) eq "C" or substr($REFSEQ{$m_chr}, $i, 1) eq "g" or substr($REFSEQ{$m_chr}, $i, 1) eq "c") {
			$num_gc++;
		}
		my $call1 = "";
		my $call2 = "";
		if (defined($VAR1{$m_chr."#".$i}) or defined($REF1{$m_chr."#".$i})) {
			$num_calls1++;
			if ($i != $m_pos) {
				my $rep = -1; 
				if (defined($VAR1{$m_chr."#".$i})) {
					my @a = split "#", $VAR1{$m_chr."#".$i};
					$call1 = $a[0];
					$rep = $a[1];
					$num_polymorphic1++;
				}
				if (not defined($VAR1{$m_chr."#".$i}) and defined($REF1{$m_chr."#".$i})) {
					my @a = split "#", $REF1{$m_chr."#".$i};
					$call1 = $a[0];
					$rep = $a[1];
					$num_reference1++;
				}
				if ($rep == 1) {
					$num_uniq1++;
				}
			}
		}
		if (defined($VAR2{$m_chr."#".$i}) or defined($REF2{$m_chr."#".$i})) {
			$num_calls2++;
			if ($i != $m_pos) {
				my $rep = -1; 
				if (defined($VAR2{$m_chr."#".$i})) {
					my @a = split "#", $VAR2{$m_chr."#".$i};
					$call2 = $a[0];
					$rep = $a[1];
					$num_polymorphic2++;
				}
				if (not defined($VAR2{$m_chr."#".$i}) and defined($REF2{$m_chr."#".$i})) {
					my @a = split "#", $REF2{$m_chr."#".$i};
					$call2 = $a[0];
					$rep = $a[1];
					$num_reference2++;
				}
				if ($rep == 1) {
					$num_uniq2++;
				}
			}
		}
		if ($call1 eq $call2) {
			$num_agree++;
		}
		elsif ($call1 ne "" and $call2 ne "" and $call1 ne $call2) {
			$num_disagree++;
		}
	}

	# get distance to see what rule shall be applied
	if ($bait_lastchr != $m_chr) {
		$bait_lastpos = 0;
	}
	my $dist = $m_pos - $bait_lastpos + 1;
	my $gc_perc = ($num_gc/120)*100;

	if ($dist < 10000) {	
		if ($num_agree == 120) {
			if ($num_polymorphic1 <= 3 and $num_polymorphic2 <= 3) {
				if ($num_uniq1 == 119 and $num_uniq2 == 119) {
					if ($gc_perc >= 30 and $gc_perc <=50) {
	
						if ($dist >= 250) { 

							my $bait_ref_seq = get_ref_seq($m_chr, $m_pos - 59);
							my $bait_allele_seq = get_allele_seq($m_chr, $m_pos - 59);

							if (check_seq( $bait_ref_seq) == 0 and check_seq($bait_allele_seq) == 0) {

								print DIST $m_chr, "\t", $bait_lastpos, "\t", $m_pos, "\t", $dist, "\n";
								$bait_lastpos = $m_pos;
								$bait_lastchr = $m_chr;
			
								my $loc = "chr".$m_chr.":".($m_pos - 59)."-".($m_pos + 60);					
			
								$bait_count++;
								print DESIGN $bait_count, "\t", $m_chr, "\t", $m_pos, "\t", int($gc_perc), "\t", $num_agree, "\t", $num_disagree, "\t", $num_calls1, "\t", $num_polymorphic1, "\t", $num_reference1, "\t", $num_uniq1, "\t", $num_calls2, "\t", $num_polymorphic2, "\t", $num_reference2, "\t", $num_uniq2, "\n";
								print BAITS $bait_count, "\t", $bait_ref_seq, "\t", $loc, "\t", $loc, "\t\t\t\t+\n";
								$bait_count++;
								print BAITS $bait_count, "\t", $bait_allele_seq, "\t", $loc, "\t", $loc, "\t\t\t\t+\n";
							}
							else {
								$removed_unvalid_char++;
							}
						}
						else {
							$removed_dist++;
						}
					}
					else {
						$removed_gc_content++;
					}
				}
				else {
					$removed_repetitive++;
				}
			}
			else {
				$removed_polymorphic++;
			}
		}
		else {
			$removed_disagree++;
		}
	}
	else {
		if ($num_agree >= 118) {
			if ($num_polymorphic1 <= 5 and $num_polymorphic2 <= 5) {
				if ($num_uniq1 >= 117 and $num_uniq2 >= 117) {
					if ($gc_perc >= 27 and $gc_perc <=55) {
	
						if ($dist >= 250) { 


							my $bait_ref_seq = get_ref_seq($m_chr, $m_pos - 59);
							my $bait_allele_seq = get_allele_seq($m_chr, $m_pos - 59);

							if (check_seq($bait_ref_seq) == 0 and check_seq($bait_allele_seq) == 0) {

								print DIST $m_chr, "\t", $bait_lastpos, "\t", $m_pos, "\t", $dist, "\n";
								$bait_lastpos = $m_pos;
								$bait_lastchr = $m_chr;
			
								my $loc = "chr".$m_chr.":".($m_pos - 59)."-".($m_pos + 60);					
			
								$bait_count++;
								print DESIGN $bait_count, "\t", $m_chr, "\t", $m_pos, "\t", int($gc_perc), "\t", $num_agree, "\t", $num_disagree, "\t", $num_calls1, "\t", $num_polymorphic1, "\t", $num_reference1, "\t", $num_uniq1, "\t", $num_calls2, "\t", $num_polymorphic2, "\t", $num_reference2, "\t", $num_uniq2, "\n";
	
								print BAITS $bait_count, "\t", $bait_ref_seq, "\t", $loc, "\t", $loc, "\t\t\t\t+\n";
								$bait_count++;
								print BAITS $bait_count, "\t", $bait_allele_seq, "\t", $loc, "\t", $loc, "\t\t\t\t+\n";
							}
							else {
								$removed_unvalid_char2++;
							}
						}
						else {
							$removed_dist2++;
						}
					}
					else {
						$removed_gc_content2++;
					}
				}
				else {
					$removed_repetitive2++;
				}
			}
			else {
				$removed_polymorphic2++;
			}
		}
		else {
			$removed_disagree2++;
		}
	}
	print ALL $bait_count, "\t", $m_chr, "\t", $m_pos, "\t", int($gc_perc), "\t", $num_agree, "\t", $num_disagree, "\t";
	print ALL $num_calls1, "\t", $num_polymorphic1, "\t", $num_reference1, "\t", $num_uniq1, "\t";
	print ALL $num_calls2, "\t", $num_polymorphic2, "\t", $num_reference2, "\t", $num_uniq2, "\n";
}

print STDERR "Initial number of markers:\t", $num_marker, "\n";
print STDERR "Removed errors:\t", $removed_referror, "\n";
print STDERR "Removed SVs:\t", $removed_sv, "\n";
print STDERR "Removed insertions:\t", $removed_insertion, "\n";
print STDERR "Removed deletions:\t", $removed_deletion, "\n";
print STDERR "Short dist:\n";
print STDERR "Removed disagree:\t", $removed_disagree, "\n";
print STDERR "Removed polymorphic\t", $removed_polymorphic, "\n";
print STDERR "Removed repetitive\t", $removed_repetitive, "\n";
print STDERR "Removed gc content\t", $removed_gc_content, "\n";
print STDERR "Removed marker dist\t", $removed_dist, "\n";
print STDERR "Removed unvalid char\t", $removed_unvalid_char, "\n";
print STDERR "Long dist:\n";
print STDERR "Removed disagree:\t", $removed_disagree2, "\n";
print STDERR "Removed polymorphic\t", $removed_polymorphic2, "\n";
print STDERR "Removed repetitive\t", $removed_repetitive2, "\n";
print STDERR "Removed gc content\t", $removed_gc_content2, "\n";
print STDERR "Removed marker dist\t", $removed_dist2, "\n";
print STDERR "Removed unvalid char\t", $removed_unvalid_char2, "\n";


# Up to 57.000 baits allowed 
#
# eArray supports these file formats:
# Minimal – Two columns:
# 
# Bait ID – A unique identifier for the bait sequence, containing up to 15 characters. Bait ID cannot be blank.
# 
# Bait sequence – The base sequence of the bait, in 5' to 3' orientation. The sequence must be 120 nucleotides in length, and must only contain the capital characters A, C, G, and T. All baits in the file must have the same length. Sequence cannot be blank. If Agilent hasenabled additional bait lengths for your account, you may be also able to upload baits with lengths of  90, 150, and/or 170 nucleotides.
# 
# Complete – Eight columns:
# 
# Bait ID – A unique identifier for the bait sequence, containing up to 15 characters. Bait ID cannot be blank.
# 
# Bait sequence – The base sequence of the bait, in 5' to 3' orientation. The sequence must be 120 nucleotides in length, and must only contain the capital characters A, C, G, and T. All baits in the file must have the same length. Sequence cannot be blank. If Agilent hasenabled additional bait lengths for your account, you may be also able to upload baits with lengths of 90, 150, and/or 170 nucleotides.
# 
# Genomic interval – The segment of the genome associated with the bait, for example chr1:1-10000. This column can be blank.
# 
# Bait genomic location – The exact position of the bait in the genome, for example chr1:1-169. This column can be blank.
# 
# Accessions – Unique identifier(s) that refer to a nucleotide sequence that is a target for the associated bait and/or a protein sequence that is a product of the target. Accessions are represented in a <source>|<ID> pair format. <source> is the symbol of the database from which the accession was derived and <ID> is the unique identifier accession. For example, ref|NM_015752 is a <source>|<ID> pair where ref (NCBI RefSeq) is the source and NM_015752 is the unique identifier for that source. The Accessions field can contain multiple <source>|<ID> pairs, delimited by pipe "|" characters.  For example, gi|7657630|ref|NM_015752 is an allowable accession that gives both an NCBI gene identifier (gi), and a RefSeq identifier (ref) for the same bait sequence. Accessions can be blank.
# 
# GeneSymbols – A unique abbreviation for a gene name. GeneSymbols can be blank.
# 
# Description – A description of a phenotype, gene product, or its function. Description can be blank.
# 
# Strand – The orientation of the bait, which can be + (for sense orientation) or – (for antisense orientation). If an orientation is not specified for a bait, eArray assumes sense orientation. Your bait file can contain both sense and antisense baits.
# 






###################################################
# subroutines

sub check_seq {
	my ($seq) = @_; 
	for (my $i = 0; $i < length($seq); $i++) {
		my $a = substr($seq, $i, 1);
		if ($a ne "A" and $a ne "C" and $a ne "G" and $a ne "T" and $a ne "a" and $a ne "c" and $a ne "g" and $a ne "t") {
			return 1;
		}
	}
	return 0;
}

sub get_ref_seq {
	my ($chr, $begin) = @_; 
	return substr($REFSEQ{$chr}, $begin-1, 120);
}

sub get_allele_seq {
	my ($chr, $begin) = @_; 
	my $seq = "";
	for (my $i = $begin; $i < $begin + 120; $i++) {
		if (defined($VAR1{$chr."#".$i}) or defined($REF1{$chr."#".$i}) or defined($VAR2{$chr."#".$i}) or defined($REF2{$chr."#".$i})) {
			my $w = "";
			if (defined($VAR1{$chr."#".$i})) {
				$w = $VAR1{$chr."#".$i};
			}
			elsif (defined($VAR2{$chr."#".$i})) {
				$w = $VAR2{$chr."#".$i};
			}
			elsif (defined($REF1{$chr."#".$i})) {
				$w = $REF1{$chr."#".$i};
			}
			elsif (defined($REF2{$chr."#".$i})) {
				$w = $REF2{$chr."#".$i};
			}
			my @a = split "#", $w;
			$seq .= $a[0];
		}
		else {
			$seq .= substr($REFSEQ{$chr}, $i, 1);
		}
	}
	return $seq;
}

sub get_insertion {
	my ($ref, $file) = @_;

	open FILE, $file;
	while (my $line = <FILE>) {
		my @a = split " ", $line;
		${$ref}{$a[1]."#".$a[2]} = $a[4];
		# set independent sequence
		substr($INDSEQ{$a[1]}, $a[2]-1, 1) = "N";
	}
	close FILE;
}

sub get_sv {
	my ($ref, $file) = @_;

	open FILE, $file or die "Cannot open file\n";
	while (my $line=<FILE>) {
		my @a = split " ", $line;
		for (my $i = $a[4]; $i <= $a[5]; $i++) {
			${$ref}{$a[3]."#".$i} = "";
			# set independent sequence
			substr($INDSEQ{$a[3]}, $i-1, 1) = "N";
		}
	}
	close FILE;
}

sub get_referror {
	my ($ref, $file) = @_;

	open FILE, $file;
	while (my $line = <FILE>) {
		my @a = split " ", $line;
		${$ref}{$a[0]."#".$a[1]} = 1;
		# set independent sequence
		substr($INDSEQ{$a[0]}, $a[1]-1, 1) = "N";
	}
	close FILE;
}

sub get_qual_file {
	my ($ref, $file, $mask) = @_;
	
	open FILE, $file or die "Cannot open file: $file\n";
	while (my $line=<FILE>) {
		my @a = split " ", $line;
		if ($a[5] >= 32) {
			${$ref}{$a[1]."#".$a[2]} = $a[4]."#".$a[8];
			# set independent sequence
			if ($mask == 1) {
				substr($INDSEQ{$a[1]}, $a[2]-1, 1) = "N";
			}
		}
	}
	close FILE;
}

sub get_refseq {
	my ($ref, $file) = @_;

        open FILE, $file or die "Cannot open file: $file\n";
	my $seq = "";
	my $id =  "";
        while (my $line=<FILE>) {
		chomp($line);
		if (substr($line, 0, 1) eq ">") {
	                if ($seq ne "" and $id ne "") {
		                ${$ref}{$id} = $seq;
		        }
			$seq = "";
			my @a = split " ", $line;
			$id = substr($a[0], 1, length($a[0])-1);
		}
		else {
			$seq .= $line;
		}
        }
	if ($seq ne "" and $id ne "") {
		${$ref}{$id} = $seq;
	}
        close FILE;
}

sub get_marker {
	my ($m_ref, $marker) = @_;

	open MARKERFILE, $marker or die "Cannot open marker file\n";
	while (my $line=<MARKERFILE>) {
		my @a = split " ", $line;
		my $id = $a[1]*100000000 + $a[2];
		${$m_ref}{$id} = $a[4];
		$num_marker++;
		# set independent sequence
		substr($INDSEQ{$a[1]}, $a[2]-1, 1) = "N";
	}
	close MARKERFILE or die "Marker file won't close\n";
}

