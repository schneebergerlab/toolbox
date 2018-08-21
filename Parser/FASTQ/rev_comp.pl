#! /usr/bin/perl
use strict;
use warnings;


my $usage = "$0 fastqfile\n";
my $file = shift or die $usage;

open FILE, $file or die $usage;

while (my $line = <FILE>) {
	print $line;
	if (substr($line, 0, 1) eq "@" or substr($line, 0, 1) eq "+") { 
		my $lline = <FILE>;
		chomp($lline);
		if (substr($line, 0, 1) eq "@") {
			print rev_comp($lline), "\n";
		}
		else {
			$lline = reverse($lline);
			print $lline, "\n";
		}
	}
}

sub rev_comp {
        my ($seq) = @_;

        $seq =~ tr/ACTGactgMRVHmrvhKYBDkybd/TGACtgacKYBDkybdMRVHmrvh/;
	$seq = reverse($seq);

        return $seq;
}




