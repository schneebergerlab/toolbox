#! /usr/bin/perl
use strict;
use warnings;


# Blat the reads against the vector sequences
# blat bur-0.vectors.fa Bur-0.shot_gun.fas out
# parse out file with perl script


my $usage = "$0 fastafile blatoutput\n";
my $fasta = shift or die $usage;
my $blat = shift or die $usage;

####################################################################
### Read in Fasta

open FILE, $fasta or die "Cannot open file\n";
my %SEQ = ();

my $id = "";
my $seq = "";
while (my $line = <FILE>) {
	if (substr($line, 0, 1) eq ">") {
		my @a = split " ", $line;
		if ($seq ne "") {
			$SEQ{$id} = $seq;
		}
		$seq = "";
		$id = substr($a[0], 1, length($a[0])-1);
	}
	else {
		chomp($line);
		$seq .= $line;
	}
}
if ($seq ne "") {
	$SEQ{$id} = $seq;
}
close FILE;

####################################################################

my %START = ();
my %END = ();

open FILE, $blat or die "Cannot open file\n";

my $f = 0;
while (my $line = <FILE>) {
	if ($f == 1) {
		my @a = split " ", $line;
		my $id = $a[9];
		my $length = $a[10];
		my $start = $a[11];
		my $end = $a[12];
		# 3' or 5' hit ?
		if ($start < $length-$end) { # => vector at the beginning:
			if ((not defined($START{$id}) or $START{$id} < $end) and ($end-$start+1) >= 50) {
				$START{$id} = $end;
			}
		}
		else {                        # => vector at the end
			if ((not defined($END{$id}) or $END{$id} > $start) and ($end-$start+1) >= 50) {
				$END{$id} = $start;
			}
		}
	}
	if (substr($line, 0, 1) eq "-") {
		$f = 1;
	}
}

close FILE;


####################################################################

open LOG, ">log.out";
foreach my $seq (keys %SEQ) {
	my $start = 0;
	my $end = length($SEQ{$seq});
	$start = $START{$seq} if defined($START{$seq});
	$end = $END{$seq} if defined($END{$seq});
	my $sequence = "";
	if ($end > $start) {
		$sequence = substr($SEQ{$seq}, $start, $end-$start+1);
	}
	if (length($sequence) >= 50) {
		print ">", $seq, "\n";
		if ($start <= $end) {
			print substr($SEQ{$seq}, $start, $end-$start+1), "\n";
		}
	}
	print LOG $seq, "\t", $start, "\t", $end, "\n";
}




