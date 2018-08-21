#! /usr/bin/perl
use strict;
use warnings;



my $file = shift;
my $reffile = shift;

open FILE, $file;

my %CTPOS = ();
my %GAPOS = ();
while (<FILE>) {
	my @a = split " ";
	if ($a[3] > $a[2] and $a[3] > 5) {
#print $a[0], "#", $a[1], "\n";
		$CTPOS{$a[0]."#".$a[1]} = 1;
	}	
	if ($a[5] >= 5 and $a[5] > $a[4]) {
                $GAPOS{$a[0]."#".$a[1]} = 1;
        }
}

close FILE;

open FILE, $reffile;
my $chr = 0;
my $pos = 0;

open GAFILE, ">conv.ga.fa";
open CTFILE, ">conv.ct.fa";

my $count_ct = 0;
my $count_ga = 0;

while (my $line = <FILE>) {
	chomp($line);
	my @a = split " ", $line;
	if (substr($line, 0, 1) eq ">") {
		$chr = substr($a[0], 1, length($a[0]) -1);
		print STDERR $chr, "\n";
		print GAFILE $line, "\n";
		print CTFILE $line, "\n";
	}
	else {
		for (my $i = 0; $i < length($line); $i++) {
			$pos++;
			if (substr($line, $i, 1) eq "C" and defined($CTPOS{$chr."#".$pos})) {
				print CTFILE "T";
				print GAFILE substr($line, $i, 1);
				$count_ct++;
			}
			elsif (substr($line, $i, 1) eq "G" and defined($GAPOS{$chr."#".$pos})) {
				print GAFILE "A";
                                print CTFILE substr($line, $i, 1);
				$count_ga++;
                        }
			else {
				print GAFILE substr($line, $i, 1);
				print CTFILE substr($line, $i, 1);
			}
			if ($pos % 60 == 0) {
				print GAFILE "\n";
				print CTFILE "\n";
			}
		}
	}
}

print STDERR "Converted CT:", $count_ct, "\n";
print STDERR "Converted GA:", $count_ga, "\n";


