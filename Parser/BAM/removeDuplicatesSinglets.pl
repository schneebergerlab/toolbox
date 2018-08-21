#!/usr/bin/perl

use strict;
use warnings;

my $usage = "Usage: $0 bam-file!\n";

my $bam = shift||die $usage;

my %unique = ();
my %data = ();
my %reads = ();

open(IN, "samtools view $bam|")||die "Cannot open $bam!\n";
while(<IN>){
	my $l = $_;
	chomp($l);
	my @l = split /\s\s*/, $l;
	my $id = $l[0];
	#my @id = split /\//, $id;
	my $chr = $l[2];
	my $pos = $l[3];
	my $read_length = length($l[9]);
	my $strand = $l[11];
	my $conv = $l[12];
	my $cigar = $l[5];
	my $clipped = 0;
	if($cigar =~ /S/){
		$clipped = 1;
		next;
	}
	if($cigar =~ /M$/){
		$cigar = 0;
	}
	else{
		$cigar = 1;
	}
	if($strand !~ /XO/ || $conv !~ /XS/){
		print STDERR "Wrong column for XO or XS flag?\n";
		exit(0);
	}
	if($strand =~ /-FW/){
		$strand = "rev";
	}
	elsif($strand =~ /\+FW/){
		$strand = "fwd";
	}
	else{
		print STDERR "$strand does not contain expected strand information!\n";
		exit(0);
	}
	my @tmp = split /:/, $conv;
	$conv = $tmp[2];
	if($strand eq "rev"){
		$pos += $read_length;
	}
	if(defined $unique{$chr}{$pos}{$strand}){
		my @tt = split /#/, $unique{$chr}{$pos}{$strand};
		if($tt[3] == 1 && $conv == 0){
			$unique{$chr}{$pos}{$strand} = "$id#$read_length#$cigar#$conv";
		}
		elsif($tt[2] == 1 && $cigar == 0){
			$unique{$chr}{$pos}{$strand} = "$id#$read_length#$cigar#$conv";
		}
		elsif($tt[3] == $conv && $tt[2] == $cigar && $read_length > $tt[1]){
			$unique{$chr}{$pos}{$strand} = "$id#$read_length#$cigar#$conv";
		}
	}
	elsif(!defined $unique{$chr}{$pos}{$strand}){
		$unique{$chr}{$pos}{$strand} = "$id#$read_length#$cigar#$conv";
	}
	$data{$id} = $l;
}

foreach my $c(sort keys(%unique)){
	foreach my $p(sort {$a <=> $b} keys(%{$unique{$c}})){
			foreach my $s(keys(%{$unique{$c}{$p}})){
				my @tt = split /#/, $unique{$c}{$p}{$s};
				print $data{$tt[0]}."\n";
			}
	}
}
